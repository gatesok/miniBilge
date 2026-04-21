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
            DateOfBirth = request.DateOfBirth,
            GradeLevel = (GradeLevel)request.GradeLevel,
            AvatarImageUrl = request.AvatarImageUrl ?? "default-avatar.png",
            TotalCoins = 100  // Başlangıç puanı
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
        child.DateOfBirth = request.DateOfBirth;
        child.GradeLevel = (GradeLevel)request.GradeLevel;
        child.AvatarImageUrl = request.AvatarImageUrl ?? child.AvatarImageUrl;

        await _childProfileRepository.UpdateAsync(child, cancellationToken);
        return MapToDto(child);
    }

    public async Task DeleteChildAsync(Guid id, CancellationToken cancellationToken = default)
    {
        await _childProfileRepository.DeleteAsync(id, cancellationToken);
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
            AvatarImageUrl = child.AvatarImageUrl,
            TotalCoins = child.TotalCoins,
            TotalStars = child.TotalStars
        };
    }

    private string GetGradeLevelText(GradeLevel level)
    {
        return level switch
        {
            GradeLevel.PreSchool => "Okul Öncesi",
            GradeLevel.Grade1 => "1. Sınıf",
            GradeLevel.Grade2 => "2. Sınıf",
            GradeLevel.Grade3 => "3. Sınıf",
            GradeLevel.Grade4 => "4. Sınıf",
            _ => "Bilinmeyen"
        };
    }
}
