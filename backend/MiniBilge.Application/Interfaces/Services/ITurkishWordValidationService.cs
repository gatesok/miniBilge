namespace MiniBilge.Application.Interfaces.Services;

/// <summary>Bir kelimenin geçerli bir Türkçe sözcük olup olmadığını doğrular (pool → cache → TDK sırasıyla).</summary>
public interface ITurkishWordValidationService
{
    /// <summary>
    /// Kelime geçerli mi? TDK servisine ulaşılamazsa fail-open: true döner.
    /// <paramref name="normalizedWord"/> zaten ToUpperInvariant().Trim() ile normalize edilmiş olmalı.
    /// </summary>
    Task<bool> IsValidWordAsync(string normalizedWord, CancellationToken ct = default);
}
