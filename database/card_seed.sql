-- ============================================================
-- MiniBilge — collectible_cards INSERT scripti
-- Hazırlanma: Sprint 17
-- 
-- ÇALIŞTIRILACAK ADIMLAR:
--   psql "host=34.58.178.7 port=5432 dbname=postgres user=postgres" -f card_seed.sql
--
-- Görsel durumu:
--   ✅ assets/sprites/male_hero-design.png  → gerçek görsel mevcut
--   ⏳ assets/cards/heroes/hero_XXX.png    → henüz yok, emoji fallback gösterir
--   ⏳ assets/cards/animals/animal_XXX.png → henüz yok, emoji fallback gösterir
--   ⏳ assets/cards/legends/legend_XXX.png → henüz yok, emoji fallback gösterir
-- ============================================================

-- Önceki veri varsa temizle (isteğe bağlı)
-- TRUNCATE TABLE card_drop_log, child_cards, collectible_cards RESTART IDENTITY CASCADE;

INSERT INTO collectible_cards
  ("Id", "Name", "Description", "Series", "Rarity", "ImageAsset", "CardNumber", "IsActive", "CreatedAt", "IsDeleted")
VALUES

-- ───────────────────────────────────────────────
-- KAHRAMANlar SERİSİ (15 kart, #001-#015)
-- ───────────────────────────────────────────────

-- Common (7 kart)
(gen_random_uuid(), 'Cesur Kahraman',   'Hiçbir zorluğa boyun eğmez!',         'Kahramanlar', 'common',    'assets/sprites/male_hero-design.png',      1,  true, NOW(), false),
(gen_random_uuid(), 'Genç Savaşçı',     'Henüz tecrübe kazanıyor ama azimli.',  'Kahramanlar', 'common',    'assets/cards/heroes/hero_002.png',          2,  true, NOW(), false),
(gen_random_uuid(), 'Devriye Askeri',   'Köyü her gece korur.',                 'Kahramanlar', 'common',    'assets/cards/heroes/hero_003.png',          3,  true, NOW(), false),
(gen_random_uuid(), 'Kalkan Taşıyıcı',  'Savunma onun uzmanlığı.',              'Kahramanlar', 'common',    'assets/cards/heroes/hero_004.png',          4,  true, NOW(), false),
(gen_random_uuid(), 'Ok Atıcı',         'Hedefi asla kaçırmaz.',                'Kahramanlar', 'common',    'assets/cards/heroes/hero_005.png',          5,  true, NOW(), false),
(gen_random_uuid(), 'Kılıç Ustası',     'Yılların emekle kazandığı beceri.',    'Kahramanlar', 'common',    'assets/cards/heroes/hero_006.png',          6,  true, NOW(), false),
(gen_random_uuid(), 'Hazine Avcısı',    'Kayıp hazinelerin izini sürer.',       'Kahramanlar', 'common',    'assets/cards/heroes/hero_007.png',          7,  true, NOW(), false),

-- Rare (4 kart)
(gen_random_uuid(), 'Zırhlı Şövalye',   'Krallığın en güvenilir şövalyesi.',    'Kahramanlar', 'rare',      'assets/cards/heroes/hero_008.png',          8,  true, NOW(), false),
(gen_random_uuid(), 'Büyü Öğrencisi',   'Sihrin gizemine adanmış bir ruh.',     'Kahramanlar', 'rare',      'assets/cards/heroes/hero_009.png',          9,  true, NOW(), false),
(gen_random_uuid(), 'Gölge Savaşçısı',  'Karanlıkta iz bırakmadan ilerler.',    'Kahramanlar', 'rare',      'assets/cards/heroes/hero_010.png',          10, true, NOW(), false),
(gen_random_uuid(), 'Işık Kılıcı',      'Kötülüğe karşı ışığı taşır.',         'Kahramanlar', 'rare',      'assets/cards/heroes/hero_011.png',          11, true, NOW(), false),

-- Epic (3 kart)
(gen_random_uuid(), 'Kahraman Kaptan',  'Ordusuna ilham veren lider.',          'Kahramanlar', 'epic',      'assets/cards/heroes/hero_012.png',          12, true, NOW(), false),
(gen_random_uuid(), 'Alev Kılıcı',      'Kılıcından ateş fışkırır.',            'Kahramanlar', 'epic',      'assets/cards/heroes/hero_013.png',          13, true, NOW(), false),
(gen_random_uuid(), 'Kutsal Şövalye',   'Tanrıların lütfuyla donanmış.',        'Kahramanlar', 'epic',      'assets/cards/heroes/hero_014.png',          14, true, NOW(), false),

-- Legendary (1 kart)
(gen_random_uuid(), 'Efsane Kahraman',  'Adı tarihe geçmiş tek savaşçı.',      'Kahramanlar', 'legendary', 'assets/cards/heroes/hero_015.png',          15, true, NOW(), false),

-- ───────────────────────────────────────────────
-- HAYVANLAR SERİSİ (15 kart, #016-#030)
-- ───────────────────────────────────────────────

-- Common (7 kart)
(gen_random_uuid(), 'Neşeli Tavşan',    'Her zaman zıplar, hiç durmaz!',        'Hayvanlar',   'common',    'assets/cards/animals/animal_001.png',       16, true, NOW(), false),
(gen_random_uuid(), 'Meraklı Tilki',    'Her şeyi merak eder, araştırır.',      'Hayvanlar',   'common',    'assets/cards/animals/animal_002.png',       17, true, NOW(), false),
(gen_random_uuid(), 'Tembel Panda',     'Bambu yer, uyur, mutlu olur.',         'Hayvanlar',   'common',    'assets/cards/animals/animal_003.png',       18, true, NOW(), false),
(gen_random_uuid(), 'Hızlı Kaplumbağa','Yavaş ama kararlı!',                   'Hayvanlar',   'common',    'assets/cards/animals/animal_004.png',       19, true, NOW(), false),
(gen_random_uuid(), 'Şakacı Maymun',   'Her fırsatta oyun oynamaya hazır.',    'Hayvanlar',   'common',    'assets/cards/animals/animal_005.png',       20, true, NOW(), false),
(gen_random_uuid(), 'Akıllı Baykuş',   'Geceleri uyanık, her şeyi bilir.',     'Hayvanlar',   'common',    'assets/cards/animals/animal_006.png',       21, true, NOW(), false),
(gen_random_uuid(), 'Cesur Fare',       'Küçük ama yürekli.',                   'Hayvanlar',   'common',    'assets/cards/animals/animal_007.png',       22, true, NOW(), false),

-- Rare (4 kart)
(gen_random_uuid(), 'Aslan Yürekli',    'Ormanın hükümdarı.',                   'Hayvanlar',   'rare',      'assets/cards/animals/animal_008.png',       23, true, NOW(), false),
(gen_random_uuid(), 'Kar Leoparı',      'Dağların sessiz avcısı.',              'Hayvanlar',   'rare',      'assets/cards/animals/animal_009.png',       24, true, NOW(), false),
(gen_random_uuid(), 'Deniz Atı',        'Okyanusun zarif dansçısı.',            'Hayvanlar',   'rare',      'assets/cards/animals/animal_010.png',       25, true, NOW(), false),
(gen_random_uuid(), 'Anka Kuşu',        'Küllerinden yeniden doğar.',           'Hayvanlar',   'rare',      'assets/cards/animals/animal_011.png',       26, true, NOW(), false),

-- Epic (3 kart)
(gen_random_uuid(), 'Ejder Kertenkele', 'Ateş soluklu küçük ejder.',            'Hayvanlar',   'epic',      'assets/cards/animals/animal_012.png',       27, true, NOW(), false),
(gen_random_uuid(), 'Kutup Ayısı',      'Soğukta bile gülümser.',               'Hayvanlar',   'epic',      'assets/cards/animals/animal_013.png',       28, true, NOW(), false),
(gen_random_uuid(), 'Gök Kartalı',      'Bulutların üzerinde süzülür.',         'Hayvanlar',   'epic',      'assets/cards/animals/animal_014.png',       29, true, NOW(), false),

-- Legendary (1 kart)
(gen_random_uuid(), 'Efsane Ejderha',   'Binlerce yıl yaşayan kadim varlık.',   'Hayvanlar',   'legendary', 'assets/cards/animals/animal_015.png',       30, true, NOW(), false),

-- ───────────────────────────────────────────────
-- EFSANELER SERİSİ (10 kart, #031-#040)
-- ───────────────────────────────────────────────

-- Common (3 kart)
(gen_random_uuid(), 'Orman Perisi',     'Ağaçlar arasında dans eder.',          'Efsaneler',   'common',    'assets/cards/legends/legend_001.png',       31, true, NOW(), false),
(gen_random_uuid(), 'Su Ruhu',          'Pınarları koruyan kadim ruh.',         'Efsaneler',   'common',    'assets/cards/legends/legend_002.png',       32, true, NOW(), false),
(gen_random_uuid(), 'Ateş Cini',        'Alevlerin içinde yaşar.',              'Efsaneler',   'common',    'assets/cards/legends/legend_003.png',       33, true, NOW(), false),

-- Rare (3 kart)
(gen_random_uuid(), 'Ay Tanrıçası',     'Geceleri gökyüzünü aydınlatır.',       'Efsaneler',   'rare',      'assets/cards/legends/legend_004.png',       34, true, NOW(), false),
(gen_random_uuid(), 'Rüzgar Efendisi',  'Fırtınaları yönetir.',                 'Efsaneler',   'rare',      'assets/cards/legends/legend_005.png',       35, true, NOW(), false),
(gen_random_uuid(), 'Toprak Devi',      'Dağları tek eliyle taşır.',            'Efsaneler',   'rare',      'assets/cards/legends/legend_006.png',       36, true, NOW(), false),

-- Epic (3 kart)
(gen_random_uuid(), 'Zaman Büyücüsü',   'Zamanı ileri geri sarabilir.',         'Efsaneler',   'epic',      'assets/cards/legends/legend_007.png',       37, true, NOW(), false),
(gen_random_uuid(), 'Işık Tanrısı',     'Evrenin ilk ışığını yarattı.',         'Efsaneler',   'epic',      'assets/cards/legends/legend_008.png',       38, true, NOW(), false),
(gen_random_uuid(), 'Ölümsüz Kral',     'Ölümü bile yenmiş kadim hükümdar.',   'Efsaneler',   'epic',      'assets/cards/legends/legend_009.png',       39, true, NOW(), false),

-- Legendary (1 kart)
(gen_random_uuid(), 'Yaratıcı Tanrı',   'Her şeyi yoktan var etmiş.',           'Efsaneler',   'legendary', 'assets/cards/legends/legend_010.png',       40, true, NOW(), false)

ON CONFLICT DO NOTHING;

-- Sonucu kontrol et
SELECT "Series", "Rarity", COUNT(*) as kart_sayisi
FROM collectible_cards
GROUP BY "Series", "Rarity"
ORDER BY "Series",
  CASE "Rarity" WHEN 'common' THEN 1 WHEN 'rare' THEN 2 WHEN 'epic' THEN 3 WHEN 'legendary' THEN 4 END;
