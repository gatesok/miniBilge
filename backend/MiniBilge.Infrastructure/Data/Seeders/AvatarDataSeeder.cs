using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Data.Seeders;

public static class AvatarDataSeeder
{
    public static async Task SeedAsync(ApplicationDbContext context)
    {
        // Default avatar oluştur
        if (!context.Avatars.Any())
        {
            var defaultAvatar = new Avatar
            {
                Id = Guid.NewGuid(),
                Name = "Varsayılan Avatar",
                ImageUrl = "/assets/avatars/default-avatar.png",
                IsDefault = true,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            context.Avatars.Add(defaultAvatar);
            await context.SaveChangesAsync();
            
            Console.WriteLine("✅ Default avatar oluşturuldu");
        }
        else
        {
            Console.WriteLine("ℹ️  Avatar zaten mevcut, seeding atlandı");
        }
    }
}
