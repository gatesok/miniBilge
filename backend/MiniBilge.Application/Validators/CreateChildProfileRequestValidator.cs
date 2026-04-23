using FluentValidation;
using MiniBilge.Application.DTOs.Profile;
using System.Text.RegularExpressions;

namespace MiniBilge.Application.Validators;

public class CreateChildProfileRequestValidator : AbstractValidator<CreateChildProfileRequest>
{
    // Türkçe karakterler dahil sadece harf ve boşluk
    private static readonly Regex NamePattern =
        new(@"^[a-zA-ZçÇğĞıİöÖşŞüÜ\s]+$", RegexOptions.Compiled);

    public CreateChildProfileRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Çocuk adı gereklidir")
            .MinimumLength(2).WithMessage("Ad en az 2 karakter olmalıdır")
            .MaximumLength(50).WithMessage("Ad en fazla 50 karakter olabilir")
            .Must(name => NamePattern.IsMatch(name?.Trim() ?? string.Empty))
                .WithMessage("Ad yalnızca harf içerebilir, rakam ve özel karakter kullanılamaz")
            .Must(name => (name?.Trim().Length ?? 0) >= 2)
                .WithMessage("Ad geçerli bir isim olmalıdır");

        RuleFor(x => x.DateOfBirth)
            .NotEmpty().WithMessage("Doğum tarihi gereklidir")
            .LessThan(DateTime.Today).WithMessage("Doğum tarihi bugünden önce olmalıdır")
            .GreaterThan(DateTime.Today.AddYears(-15)).WithMessage("Çocuk yaşı geçersiz");

        RuleFor(x => x.GradeLevel)
            .InclusiveBetween(0, 4).WithMessage("Sınıf seviyesi 0-4 arasında olmalıdır");
    }
}
