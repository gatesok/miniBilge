using Google.Cloud.Storage.V1;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.Interfaces;

namespace MiniBilge.Infrastructure.Services;

public class GcsStorageService : IStorageService
{
    private readonly StorageClient _client;
    private readonly string _bucketName;
    private readonly ILogger<GcsStorageService> _logger;

    public GcsStorageService(IConfiguration config, ILogger<GcsStorageService> logger)
    {
        _logger = logger;
        _bucketName = config["GCS:BucketName"]
            ?? throw new InvalidOperationException("GCS:BucketName is not configured.");
        // Cloud Run'da Application Default Credentials otomatik çalışır.
        _client = StorageClient.Create();
    }

    public async Task<string> UploadAsync(
        Stream fileStream,
        string fileName,
        string contentType,
        string folder = "avatars")
    {
        var objectName = $"{folder}/{fileName}";

        await _client.UploadObjectAsync(
            bucket: _bucketName,
            objectName: objectName,
            contentType: contentType,
            source: fileStream,
            options: new UploadObjectOptions
            {
                PredefinedAcl = PredefinedObjectAcl.PublicRead,
            });

        var publicUrl = $"https://storage.googleapis.com/{_bucketName}/{objectName}";
        _logger.LogInformation("[GCS] Uploaded: {Url}", publicUrl);
        return publicUrl;
    }

    public async Task DeleteAsync(string objectName)
    {
        try
        {
            await _client.DeleteObjectAsync(_bucketName, objectName);
            _logger.LogInformation("[GCS] Deleted: {ObjectName}", objectName);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "[GCS] Delete failed for {ObjectName}", objectName);
        }
    }
}
