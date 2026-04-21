using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Data.Seeders;

public static class AvatarItemsDataSeeder
{
    public static async Task SeedAsync(ApplicationDbContext context)
    {
        if (!context.AvatarItems.Any())
        {
            var items = new List<AvatarItem>();

            // ========== ŞAPKALAR (Hat = 1) ==========
            items.Add(new AvatarItem
            {
                Id = Guid.NewGuid(),
                Name = "🧢 Kırmızı Şapka",
                ItemType = ItemType.Hat,
                PointCost = 50,
                ImageUrl = "/assets/items/hats/red-cap.png",
                Category = "Şapka",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            });

            items.Add(new AvatarItem
            {
                Id = Guid.NewGuid(),
                Name = "🎩 Silindir Şapka",
                ItemType = ItemType.Hat,
                PointCost = 100,
                ImageUrl = "/assets/items/hats/top-hat.png",
                Category = "Şapka",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            });

            items.Add(new AvatarItem
            {
                Id = Guid.NewGuid(),
                Name = "👑 Altın Taç",
                ItemType = ItemType.Hat,
                PointCost = 100,
                ImageUrl = "/assets/items/hats/crown.png",
                Category = "Şapka",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            });

            // ========== GÖZLÜKLER (Glasses = 2) ==========
            items.Add(new AvatarItem
            {
                Id = Guid.NewGuid(),
                Name = "🕶️ Güneş Gözlüğü",
                ItemType = ItemType.Glasses,
                PointCost = 75,
                ImageUrl = "/assets/items/glasses/sunglasses.png",
                Category = "Gözlük",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            });

            items.Add(new AvatarItem
            {
                Id = Guid.NewGuid(),
                Name = "👓 Okuma Gözlüğü",
                ItemType = ItemType.Glasses,
                PointCost = 75,
                ImageUrl = "/assets/items/glasses/reading-glasses.png",
                Category = "Gözlük",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            });

            // ========== KIYAFETLER (Outfit = 3) ==========
            items.Add(new AvatarItem
            {
                Id = Guid.NewGuid(),
                Name = "👕 Mavi Tişört",
                ItemType = ItemType.Outfit,
                PointCost = 150,
                ImageUrl = "/assets/items/outfits/blue-tshirt.png",
                Category = "Kıyafet",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            });

            items.Add(new AvatarItem
            {
                Id = Guid.NewGuid(),
                Name = "🦸 Süper Kahraman Kostümü",
                ItemType = ItemType.Outfit,
                PointCost = 200,
                ImageUrl = "/assets/items/outfits/superhero.png",
                Category = "Kıyafet",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            });

            items.Add(new AvatarItem
            {
                Id = Guid.NewGuid(),
                Name = "🎽 Spor Forması",
                ItemType = ItemType.Outfit,
                PointCost = 150,
                ImageUrl = "/assets/items/outfits/sports-jersey.png",
                Category = "Kıyafet",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            });

            // ========== AKSESUARLAR (Accessory = 4) ==========
            items.Add(new AvatarItem
            {
                Id = Guid.NewGuid(),
                Name = "⭐ Parlayan Yıldız",
                ItemType = ItemType.Accessory,
                PointCost = 100,
                ImageUrl = "/assets/items/accessories/star.png",
                Category = "Aksesuar",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            });

            items.Add(new AvatarItem
            {
                Id = Guid.NewGuid(),
                Name = "🎒 Renkli Sırt Çantası",
                ItemType = ItemType.Accessory,
                PointCost = 100,
                ImageUrl = "/assets/items/accessories/backpack.png",
                Category = "Aksesuar",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            });

            // ========== ARKA PLANLAR (Background = 5) ==========
            items.Add(new AvatarItem
            {
                Id = Guid.NewGuid(),
                Name = "🌈 Gökkuşağı Arka Plan",
                ItemType = ItemType.Background,
                PointCost = 250,
                ImageUrl = "/assets/items/backgrounds/rainbow.png",
                Category = "Arka Plan",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            });

            items.Add(new AvatarItem
            {
                Id = Guid.NewGuid(),
                Name = "🌌 Uzay Arka Planı",
                ItemType = ItemType.Background,
                PointCost = 250,
                ImageUrl = "/assets/items/backgrounds/space.png",
                Category = "Arka Plan",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            });

            context.AvatarItems.AddRange(items);
            await context.SaveChangesAsync();
            
            Console.WriteLine($"✅ {items.Count} avatar item oluşturuldu:");
            Console.WriteLine($"   - {items.Count(i => i.ItemType == ItemType.Hat)} Şapka");
            Console.WriteLine($"   - {items.Count(i => i.ItemType == ItemType.Glasses)} Gözlük");
            Console.WriteLine($"   - {items.Count(i => i.ItemType == ItemType.Outfit)} Kıyafet");
            Console.WriteLine($"   - {items.Count(i => i.ItemType == ItemType.Accessory)} Aksesuar");
            Console.WriteLine($"   - {items.Count(i => i.ItemType == ItemType.Background)} Arka Plan");
        }
        else
        {
            Console.WriteLine("ℹ️  Avatar items zaten mevcut, seeding atlandı");
        }
    }
}
