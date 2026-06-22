using Google.Cloud.Storage.V1;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Options;

namespace MiniBilge.Infrastructure.Services;

public class GoogleCloudStorageProvider : ITtsAudioStorage
{
    private readonly StorageClient _storageClient;
    private readonly TtsProviderOptions _options;
    private readonly ILogger<GoogleCloudStorageProvider> _logger;

    public GoogleCloudStorageProvider(
        StorageClient storageClient,
        IOptions<TtsProviderOptions> options,
        ILogger<GoogleCloudStorageProvider> logger)
    {
        _storageClient = storageClient;
        _options = options.Value;
        _logger = logger;
    }

    public async Task<string> UploadAsync(byte[] audioData, string objectPath, CancellationToken ct = default)
    {
        var bucketName = _options.AudioStorage.BucketName;

        using var stream = new MemoryStream(audioData);

        await _storageClient.UploadObjectAsync(
            bucket: bucketName,
            objectName: objectPath,
            contentType: "audio/mpeg",
            source: stream,
            cancellationToken: ct);

        var url = $"{_options.AudioStorage.BaseUrl.TrimEnd('/')}/{objectPath}";

        _logger.LogDebug("GoogleCloudStorageProvider: yüklendi → {Url}", url);

        return url;
    }
}
