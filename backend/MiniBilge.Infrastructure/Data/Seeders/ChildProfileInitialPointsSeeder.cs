using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Data.Seeders;

public static class ChildProfileInitialPointsSeeder
{
    public static async Task SeedAsync(ApplicationDbContext context)
    {
        // Mevcut çocuk profillere 100 başlangıç puanı ekle (eğer 0 ise)
        var childrenWithZeroPoints = context.ChildProfiles
            .Where(c => c.TotalCoins == 0 && !c.IsDeleted)
            .ToList();

        if (childrenWithZeroPoints.Any())
        {
            foreach (var child in childrenWithZeroPoints)
            {
                child.TotalCoins = 100;
            }

            await context.SaveChangesAsync();
            Console.WriteLine($"✅ {childrenWithZeroPoints.Count} çocuk profile 100 başlangıç puanı eklendi");
        }
        else
        {
            Console.WriteLine("ℹ️  Tüm çocuk profillerde puan mevcut, seeding atlandı");
        }
    }
}
