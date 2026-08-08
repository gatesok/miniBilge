-- 14 yeni efsanevi kart ekler. Mevcut 16 efsanevi kartla birlikte
-- aktif Premium'a özel kart sayısını 30'a çıkarır.
-- Güvenle tekrar çalıştırılabilir.

BEGIN;

ALTER TABLE collectible_cards
    ADD COLUMN IF NOT EXISTS "IsPremiumExclusive" BOOLEAN NOT NULL DEFAULT FALSE;

-- Daha önce eklenmiş efsanevi kartlar da Premium'a özeldir. Bu sayede
-- önceki premium-kart migration'ı çalıştırılmamış olsa bile katalog tutarlı kalır.
UPDATE collectible_cards
SET "IsPremiumExclusive" = TRUE
WHERE "Rarity" = 'legendary'
  AND "IsPremiumExclusive" = FALSE;

INSERT INTO collectible_cards
    ("Id", "Name", "Description", "Series", "Rarity", "ImageAsset", "CardNumber", "IsPremiumExclusive", "IsActive", "CreatedAt", "UpdatedAt", "IsDeleted")
VALUES
    ('c5000001-0000-0000-0000-000000000121', 'Yıldız Balinası', 'Takımyıldızlarının ışığında derin denizlere yol gösteren nazik dev.', 'animals', 'legendary', 'assets/cards/animals/celestial_whale_guardian.png', 121, TRUE, TRUE, NOW(), NULL, FALSE),
    ('c5000001-0000-0000-0000-000000000122', 'İnci Feneri Kaplumbağası', 'Mercan sarayının kayıp yollarını inci feneriyle aydınlatır.', 'animals', 'legendary', 'assets/cards/animals/pearl_lantern_turtle.png', 122, TRUE, TRUE, NOW(), NULL, FALSE),
    ('c5000001-0000-0000-0000-000000000123', 'Ateş Kanatlı Kütüphaneci', 'Bilgeliğin kıvılcımlarını her kitaba taşıyan efsanevi koruyucu.', 'heroes', 'legendary', 'assets/cards/heroes/firewing_librarian.png', 123, TRUE, TRUE, NOW(), NULL, FALSE),
    ('c5000001-0000-0000-0000-000000000124', 'Kuyruklu Yıldız Kâşifi', 'Uzak galaksileri meraklı gözlerle keşfeden cesur yolcu.', 'heroes', 'legendary', 'assets/cards/heroes/comet_stargazer.png', 124, TRUE, TRUE, NOW(), NULL, FALSE),
    ('c5000001-0000-0000-0000-000000000125', 'Yıldız Dişli Pegasus', 'Bulutların üstünde hayalleri yıldızlara taşıyan mekanik dost.', 'heroes', 'legendary', 'assets/cards/heroes/clockwork_pegasus.png', 125, TRUE, TRUE, NOW(), NULL, FALSE),
    ('c5000001-0000-0000-0000-000000000126', 'Kristal Saat Baykuşu', 'Zamanın sırlarını mavi kristallerle koruyan bilge.', 'science', 'legendary', 'assets/cards/science/crystal_clock_owl.png', 126, TRUE, TRUE, NOW(), NULL, FALSE),
    ('c5000001-0000-0000-0000-000000000127', 'Gökkuşağı Roket Ustası', 'Renkli enerji kristalleriyle yeni dünyalara rota çizer.', 'science', 'legendary', 'assets/cards/science/rainbow_rocket_inventor.png', 127, TRUE, TRUE, NOW(), NULL, FALSE),
    ('c5000001-0000-0000-0000-000000000128', 'Galaksi Teraryumu Bilgesi', 'Avucundaki küçük evrenlerle yıldızların hikâyesini anlatır.', 'science', 'legendary', 'assets/cards/science/galaxy_terrarium_sage.png', 128, TRUE, TRUE, NOW(), NULL, FALSE),
    ('c5000001-0000-0000-0000-000000000129', 'Şimşek Bulutu Ejderi', 'Gökyüzünü neşeli şimşekleriyle güvenle aydınlatan bulut dostu.', 'nature_space', 'legendary', 'assets/cards/nature_space/thundercloud_dragon.png', 129, TRUE, TRUE, NOW(), NULL, FALSE),
    ('c5000001-0000-0000-0000-000000000130', 'Kristal Orman Devi', 'Parlayan çiçekleri ve kadim ormanları sevgiyle korur.', 'nature_space', 'legendary', 'assets/cards/nature_space/crystal_forest_golem.png', 130, TRUE, TRUE, NOW(), NULL, FALSE),
    ('c5000001-0000-0000-0000-000000000131', 'Zaman Muhafızı Tilki', 'Kum saatlerinin akışında geçmişle geleceği birleştirir.', 'nature_space', 'legendary', 'assets/cards/nature_space/timekeeper_fox.png', 131, TRUE, TRUE, NOW(), NULL, FALSE),
    ('c5000001-0000-0000-0000-000000000132', 'Kuzey Işıkları Tilkisi', 'Kutup gecelerinde ışık saçan kristal patikaları korur.', 'nature_space', 'legendary', 'assets/cards/nature_space/aurora_fox.png', 132, TRUE, TRUE, NOW(), NULL, FALSE),
    ('c5000001-0000-0000-0000-000000000133', 'Mozaik Anka', 'Renkli taşlardan doğan kanatlarıyla sanatın gücünü taşır.', 'culture_history', 'legendary', 'assets/cards/culture_history/mosaic_phoenix.png', 133, TRUE, TRUE, NOW(), NULL, FALSE),
    ('c5000001-0000-0000-0000-000000000134', 'Volkan Kristali Bekçisi', 'Sıcak kalpli ışığıyla adasının doğasını güvenle korur.', 'nature_space', 'legendary', 'assets/cards/nature_space/volcano_crystal_guardian.png', 134, TRUE, TRUE, NOW(), NULL, FALSE)
ON CONFLICT ("Id") DO UPDATE SET
    "Name" = EXCLUDED."Name",
    "Description" = EXCLUDED."Description",
    "Series" = EXCLUDED."Series",
    "Rarity" = EXCLUDED."Rarity",
    "ImageAsset" = EXCLUDED."ImageAsset",
    "CardNumber" = EXCLUDED."CardNumber",
    "IsPremiumExclusive" = TRUE,
    "IsActive" = TRUE,
    "UpdatedAt" = NOW(),
    "IsDeleted" = FALSE;

COMMIT;

-- Kontrol: Bu script sonrasında sonuç en az 30 olmalıdır.
SELECT COUNT(*) AS active_premium_legendary_card_count
FROM collectible_cards
WHERE "IsActive" = TRUE
  AND "IsDeleted" = FALSE
  AND "IsPremiumExclusive" = TRUE
  AND "Rarity" = 'legendary';
