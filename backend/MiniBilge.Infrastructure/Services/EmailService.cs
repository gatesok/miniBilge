using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Configuration;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.Infrastructure.Services;

public class EmailService : IEmailService
{
    private readonly string _host;
    private readonly int _port;
    private readonly string _fromEmail;
    private readonly string _appPassword;

    public EmailService(IConfiguration configuration)
    {
        _host = configuration["EmailSettings:Host"] ?? "smtp.gmail.com";
        _port = int.Parse(configuration["EmailSettings:Port"] ?? "587");
        _fromEmail = configuration["EmailSettings:FromEmail"]!;
        _appPassword = configuration["EmailSettings:AppPassword"]!;
    }

    public async Task SendPasswordResetCodeAsync(string toEmail, string code, CancellationToken cancellationToken = default)
    {
        var subject = "Mini Bilge - Şifre Sıfırlama Kodunuz";
        var body = $"""
            <html>
            <body style="font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;">
              <div style="max-width: 480px; margin: 0 auto; background: #fff; border-radius: 12px; padding: 32px; box-shadow: 0 2px 8px rgba(0,0,0,0.08);">
                <h2 style="color: #5B4FCF; text-align: center; margin-bottom: 8px;">🎓 Mini Bilge</h2>
                <h3 style="text-align: center; color: #333; margin-bottom: 24px;">Şifre Sıfırlama</h3>
                <p style="color: #555;">Şifrenizi sıfırlamak için aşağıdaki kodu kullanın:</p>
                <div style="text-align: center; margin: 24px 0;">
                  <span style="font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #5B4FCF; background: #F0EEFF; padding: 12px 24px; border-radius: 8px;">{code}</span>
                </div>
                <p style="color: #888; font-size: 13px;">Bu kod <strong>15 dakika</strong> geçerlidir.</p>
                <p style="color: #888; font-size: 13px;">Eğer bu isteği siz yapmadıysanız bu e-postayı dikkate almayın.</p>
              </div>
            </body>
            </html>
            """;

        using var smtpClient = new SmtpClient(_host, _port)
        {
            Credentials = new NetworkCredential(_fromEmail, _appPassword),
            EnableSsl = true,
        };

        using var message = new MailMessage(_fromEmail, toEmail, subject, body)
        {
            IsBodyHtml = true,
        };

        await smtpClient.SendMailAsync(message, cancellationToken);
    }
}
