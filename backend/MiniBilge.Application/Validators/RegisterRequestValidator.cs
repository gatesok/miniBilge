using FluentValidation;
using MiniBilge.Application.DTOs.Auth;

namespace MiniBilge.Application.Validators;

public class RegisterRequestValidator : AbstractValidator<RegisterRequest>
{
    public RegisterRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email gereklidir")
            .EmailAddress().WithMessage("Geçerli bir email adresi giriniz");
        
        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Şifre gereklidir")
            .MinimumLength(6).WithMessage("Şifre en az 6 karakter olmalıdır")
            .Matches(@"[A-Z]").WithMessage("Şifre en az bir büyük harf içermelidir")
            .Matches(@"[a-z]").WithMessage("Şifre en az bir küçük harf içermelidir")
            .Matches(@"[0-9]").WithMessage("Şifre en az bir rakam içermelidir");
        
        RuleFor(x => x.ConfirmPassword)
            .Equal(x => x.Password).WithMessage("Şifreler eşleşmiyor");
        
        RuleFor(x => x.FirstName)
            .NotEmpty().WithMessage("Ad gereklidir")
            .MaximumLength(100).WithMessage("Ad en fazla 100 karakter olabilir");
        
        RuleFor(x => x.LastName)
            .NotEmpty().WithMessage("Soyad gereklidir")
            .MaximumLength(100).WithMessage("Soyad en fazla 100 karakter olabilir");
        
        RuleFor(x => x.PhoneNumber)
            .Matches(@"^[0-9]{10}$").When(x => !string.IsNullOrEmpty(x.PhoneNumber))
            .WithMessage("Telefon numarası 10 haneli olmalıdır");
    }
}
