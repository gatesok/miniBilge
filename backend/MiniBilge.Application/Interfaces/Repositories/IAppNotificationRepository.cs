using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IAppNotificationRepository
{
    Task SaveAsync(Guid childId, string title, string body, string type);
    Task<List<AppNotification>> GetByChildAsync(Guid childId, int limit = 50);
    Task<int> GetUnreadCountAsync(Guid childId);
    Task MarkAllReadAsync(Guid childId);
}
