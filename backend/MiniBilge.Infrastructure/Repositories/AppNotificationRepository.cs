using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class AppNotificationRepository : IAppNotificationRepository
{
    private readonly ApplicationDbContext _db;

    public AppNotificationRepository(ApplicationDbContext db) => _db = db;

    public async Task SaveAsync(Guid childId, string title, string body, string type)
    {
        _db.AppNotifications.Add(new AppNotification
        {
            ChildProfileId   = childId,
            Title            = title,
            Body             = body,
            NotificationType = type,
            IsRead           = false,
            CreatedAt        = DateTime.UtcNow,
        });
        await _db.SaveChangesAsync();
    }

    public Task<List<AppNotification>> GetByChildAsync(Guid childId, int limit = 50)
        => _db.AppNotifications
            .Where(n => n.ChildProfileId == childId && !n.IsDeleted)
            .OrderByDescending(n => n.CreatedAt)
            .Take(limit)
            .ToListAsync();

    public Task<int> GetUnreadCountAsync(Guid childId)
        => _db.AppNotifications
            .CountAsync(n => n.ChildProfileId == childId && !n.IsRead && !n.IsDeleted);

    public async Task MarkAllReadAsync(Guid childId)
    {
        await _db.AppNotifications
            .Where(n => n.ChildProfileId == childId && !n.IsRead && !n.IsDeleted)
            .ExecuteUpdateAsync(s => s
                .SetProperty(n => n.IsRead, true)
                .SetProperty(n => n.UpdatedAt, DateTime.UtcNow));
    }

    public async Task DeleteAsync(Guid id)
    {
        await _db.AppNotifications
            .Where(n => n.Id == id)
            .ExecuteUpdateAsync(s => s
                .SetProperty(n => n.IsDeleted, true)
                .SetProperty(n => n.UpdatedAt, DateTime.UtcNow));
    }
}
