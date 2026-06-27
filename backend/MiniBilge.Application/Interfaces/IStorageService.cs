namespace MiniBilge.Application.Interfaces;

public interface IStorageService
{
    /// <summary>
    /// Uploads a file stream to cloud storage and returns the public URL.
    /// </summary>
    Task<string> UploadAsync(
        Stream fileStream,
        string fileName,
        string contentType,
        string folder = "avatars");

    /// <summary>
    /// Deletes a file by its storage object name (not full URL).
    /// </summary>
    Task DeleteAsync(string objectName);
}
