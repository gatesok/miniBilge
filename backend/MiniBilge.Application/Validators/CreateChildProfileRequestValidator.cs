using FluentValidation;
using MiniBilge.Application.DTOs.Profile;

namespace MiniBilge.Application.Validators;

public class CreateChildProfileRequestValidator : AbstractValidator<CreateChildProfileRequest>
{
    public CreateChildProfileRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Çocuk adı gereklidir")
            .MaximumLength(100).WithMessage("Ad en fazla 100 karakter olabilir");
        
        RuleFor(x => x.DateOfBirth)
            .NotEmpty().WithMessage("Doğum tarihi gereklidir")
            .LessThan(DateTime.Today).WithMessage("Doğum tarihi bugünden önce olmalıdır")
            .GreaterThan(DateTime.Today.AddYears(-15)).WithMessage("Çocuk yaşı geçersiz");
        
        RuleFor(x => x.GradeLevel)
            .InclusiveBetween(0, 4).WithMessage("Sınıf seviyesi 0-4 arasında olmalıdır");
    }
}
