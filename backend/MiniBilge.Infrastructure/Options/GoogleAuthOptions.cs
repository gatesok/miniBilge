namespace MiniBilge.Infrastructure.Options;

public class GoogleAuthOptions
{
    public const string SectionName = "GoogleAuth";

    public string ServerClientId { get; set; } = string.Empty;

    public string[] AllowedClientIds { get; set; } = [];

    public IReadOnlyCollection<string> GetAllowedClientIds()
    {
        return AllowedClientIds
            .Append(ServerClientId)
            .Where(clientId => !string.IsNullOrWhiteSpace(clientId))
            .Select(clientId => clientId.Trim())
            .Distinct(StringComparer.Ordinal)
            .ToArray();
    }
}
