namespace MiniBilge.Application.Interfaces.Services;

public interface IExternalTokenProtector
{
    string Protect(string plaintext);
    string Unprotect(string protectedValue);
}
