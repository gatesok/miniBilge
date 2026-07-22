namespace MiniBilge.Domain.Enums;

/// <summary>
/// Controls which product experience is emphasized for the signed-in account.
/// Family is the backward-compatible default for existing MiniBilge accounts.
/// </summary>
public enum ExperienceMode
{
    Family = 0,
    Child = 1,
    Adult = 2
}
