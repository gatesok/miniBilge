namespace MiniBilge.Application.Interfaces.Services;

public interface IOpenAiCompletionClient
{
    Task<string> CompleteJsonAsync(
        string featureKey,
        string systemPrompt,
        string userPrompt,
        int maxTokens,
        double temperature,
        Guid? childProfileId = null,
        CancellationToken cancellationToken = default);
}
