using MiniBilge.Application.DTOs.Profile;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

public class ChildProfileService : IChildProfileService
{
    private readonly IChildProfileRepository _childProfileRepository;
    private readonly IUserRepository _userRepository;

    public ChildProfileService(
        IChildProfileRepository childProfileRepository,
        IUserRepository userRepository)
    {
        _childProfileRepository = childProfileRepository;
        _userRepository = userRepository;
    }

    public async Task<List<ChildProfileDto>> GetChildrenByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user?.ParentProfile == null)
        {
            throw new Exception("Parent profili bulunamadı");
        }

        var children = await _childProfileRepository.GetByParentIdAsync(user.ParentProfile.Id, cancellationToken);
        return children.Select(MapToDto).ToList();
    }

    public async Task<ChildProfileDto> GetChildByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var child = await _childProfileRepository.GetByIdAsync(id, cancellationToken);
        if (child == null)
        {
            throw new Exception("Çocuk profili bulunamadı");
        }
        return MapToDto(child);
    }

    public async Task<ChildProfileDto> CreateChildAsync(Guid userId, CreateChildProfileRequest request, CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user?.ParentProfile == null)
        {
            throw new Exception("Parent profili bulunamadı");
        }

        var childProfile = new ChildProfile
        {
            ParentProfileId = user.ParentProfile.Id,
            Name = request.Name,
            DateOfBirth = DateTime.SpecifyKind(request.DateOfBirth, DateTimeKind.Utc),
            GradeLevel = (GradeLevel)request.GradeLevel,
            EnglishLevel = request.EnglishLevel.HasValue ? (EnglishLevel)request.EnglishLevel.Value : null,
            AvatarImageUrl = request.AvatarImageUrl ?? "default-avatar.png",
            TotalCoins = 100,  // Başlangıç puanı
            PodcastListeningMode = (PodcastListeningMode)request.PodcastListeningMode,
            FriendCode = await GenerateUniqueFriendCodeAsync(cancellationToken),
        };

        var created = await _childProfileRepository.CreateAsync(childProfile, cancellationToken);
        return MapToDto(created);
    }

    public async Task<ChildProfileDto> UpdateChildAsync(Guid id, CreateChildProfileRequest request, CancellationToken cancellationToken = default)
    {
        var child = await _childProfileRepository.GetByIdAsync(id, cancellationToken);
        if (child == null)
        {
            throw new Exception("Çocuk profili bulunamadı");
        }

        child.Name = request.Name;
        child.DateOfBirth = DateTime.SpecifyKind(request.DateOfBirth, DateTimeKind.Utc);
        child.GradeLevel = (GradeLevel)request.GradeLevel;
        child.EnglishLevel = request.EnglishLevel.HasValue ? (EnglishLevel)request.EnglishLevel.Value : null;
        child.AvatarImageUrl = request.AvatarImageUrl ?? child.AvatarImageUrl;
        child.PodcastListeningMode = (PodcastListeningMode)request.PodcastListeningMode;

        await _childProfileRepository.UpdateAsync(child, cancellationToken);
        return MapToDto(child);
    }

    public async Task DeleteChildAsync(Guid id, CancellationToken cancellationToken = default)
    {
        await _childProfileRepository.DeleteAsync(id, cancellationToken);
    }

    public async Task UpdatePhotoAsync(Guid childId, string photoUrl)
    {
        var child = await _childProfileRepository.GetByIdAsync(childId)
            ?? throw new Exception("Profil bulunamadı.");
        child.AvatarImageUrl = photoUrl;
        await _childProfileRepository.UpdateAsync(child);
    }

    private ChildProfileDto MapToDto(ChildProfile child)
    {
        var age = DateTime.Today.Year - child.DateOfBirth.Year;
        if (child.DateOfBirth.Date > DateTime.Today.AddYears(-age)) age--;

        return new ChildProfileDto
        {
            Id = child.Id,
            Name = child.Name,
            DateOfBirth = child.DateOfBirth,
            Age = age,
            GradeLevel = GetGradeLevelText(child.GradeLevel),
            EnglishLevel = child.EnglishLevel.HasValue ? GetEnglishLevelText(child.EnglishLevel.Value) : null,
            AvatarImageUrl = child.AvatarImageUrl,
            TotalCoins = child.TotalCoins,
            TotalStars = child.TotalStars,
            PodcastListeningMode = (int)child.PodcastListeningMode,
            FriendCode = child.FriendCode,
        };
    }

    private string GetGradeLevelText(GradeLevel level)
    {
        return level switch
        {
            GradeLevel.PreSchool => "Okul Öncesi",
            GradeLevel.Grade1    => "1. Sınıf",
            GradeLevel.Grade2    => "2. Sınıf",
            GradeLevel.Grade3    => "3. Sınıf",
            GradeLevel.Grade4    => "4. Sınıf",
            GradeLevel.Grade5    => "5. Sınıf",
            GradeLevel.Grade6    => "6. Sınıf",
            GradeLevel.Grade7    => "7. Sınıf",
            GradeLevel.Grade8    => "8. Sınıf",
            GradeLevel.Grade9    => "9. Sınıf",
            GradeLevel.Grade10   => "10. Sınıf",
            GradeLevel.Grade11   => "11. Sınıf",
            GradeLevel.Grade12   => "12. Sınıf",
            GradeLevel.Adult     => "Yetişkin",
            _                    => "Okul Öncesi"
        };
    }

    private string GetEnglishLevelText(EnglishLevel level)
    {
        return level switch
        {
            EnglishLevel.A1 => "A1 - Başlangıç",
            EnglishLevel.A2 => "A2 - Temel",
            EnglishLevel.B1 => "B1 - Orta Altı",
            EnglishLevel.B2 => "B2 - Orta",
            EnglishLevel.C1 => "C1 - Orta Üstü",
            EnglishLevel.C2 => "C2 - Ustalık",
            _ => "Bilinmeyen"
        };
    }

    /// <summary>
    /// MB-XXXXXX formatında, veritabanında benzersiz bir kod üretir.
    /// Çakışma olasılığı düşüktür (36^6 ≈ 2.2 milyar kombinasyon).
    /// </summary>
    private async Task<string> GenerateUniqueFriendCodeAsync(CancellationToken ct = default)
    {
        const string chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // ambiguous chars removed
        for (int attempt = 0; attempt < 10; attempt++)
        {
            var suffix = new string(Enumerable.Range(0, 6)
                .Select(_ => chars[Random.Shared.Next(chars.Length)])
                .ToArray());
            var code = $"MB-{suffix}";
            if (!await _childProfileRepository.FriendCodeExistsAsync(code, ct))
                return code;
        }
        throw new InvalidOperationException("Benzersiz FriendCode üretilemedi, lütfen tekrar deneyin.");
    }
}
