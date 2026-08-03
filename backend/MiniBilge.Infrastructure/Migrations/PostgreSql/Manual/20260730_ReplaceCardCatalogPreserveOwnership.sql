-- MiniBilge kart kataloğunu yeni 40 görselle değiştirir.
--
-- Güvenlik özellikleri:
--   * child_cards üzerindeki kazanılmış adetleri toplar.
--   * İlk/son kazanılma tarihlerini korur.
--   * card_drop_log geçmişini korur.
--   * Aynı CardNumber ile yanlışlıkla eklenmiş kopyaları birleştirir.
--   * Kullanıcılara ait profil veya ilerleme verisini silmez.

BEGIN;

CREATE TEMP TABLE "_new_card_catalog"
(
    "CardNumber" integer PRIMARY KEY,
    "Name" text NOT NULL,
    "Description" text NOT NULL,
    "Series" text NOT NULL,
    "Rarity" text NOT NULL,
    "ImageAsset" text NOT NULL
) ON COMMIT DROP;

INSERT INTO "_new_card_catalog"
    ("CardNumber", "Name", "Description", "Series", "Rarity", "ImageAsset")
VALUES
    (1,  'Bilge Baykuş',       'Kitap okuyan akıllı baykuş',         'animals', 'common',    'assets/cards/animals/owl.png'),
    (2,  'Cesur Aslan',        'Ormandaki kral',                     'animals', 'rare',      'assets/cards/animals/lion.png'),
    (3,  'Hızlı Kaplan',       'Rüzgar gibi koşan',                  'animals', 'rare',      'assets/cards/animals/tiger.png'),
    (4,  'Kurnaz Tilki',       'Her şeyi bilen kızıl dost',          'animals', 'common',    'assets/cards/animals/fox.png'),
    (5,  'Sevimli Penguen',    'Soğuktan korkmayan',                 'animals', 'common',    'assets/cards/animals/penguin.png'),
    (6,  'Şakacı Maymun',      'Dal daldan atlayan',                 'animals', 'common',    'assets/cards/animals/monkey.png'),
    (7,  'Çalışkan Arı',       'Bal yapan küçük dost',               'animals', 'common',    'assets/cards/animals/bee.png'),
    (8,  'Meraklı Kirpi',      'Her şeyi inceleyen',                 'animals', 'common',    'assets/cards/animals/hedgehog.png'),
    (9,  'Güçlü Fil',          'Hafızası güçlü dev',                 'animals', 'rare',      'assets/cards/animals/elephant.png'),
    (10, 'Uçan Kartal',        'Gökyüzünün efendisi',                'animals', 'epic',      'assets/cards/animals/eagle.png'),
    (11, 'Renkli Papağan',     'Kelime ustası',                      'animals', 'rare',      'assets/cards/animals/parrot.png'),
    (12, 'Gizli Kaplumbağa',   'Yavaş ama kararlı',                  'animals', 'common',    'assets/cards/animals/turtle.png'),
    (13, 'Sihirli Unicorn',    'Efsanevi at',                        'animals', 'legendary', 'assets/cards/animals/unicorn.png'),
    (14, 'Akıllı Yunus',       'Denizin zekası',                     'animals', 'epic',      'assets/cards/animals/dolphin.png'),
    (15, 'Kutup Ayısı',        'Buz ülkesinin bekçisi',              'animals', 'rare',      'assets/cards/animals/polar_bear.png'),
    (16, 'Mini Bilim İnsanı',  'Deney yapan küçük dahi',             'heroes',  'common',    'assets/cards/heroes/scientist.png'),
    (17, 'Küçük Kaşif',        'Haritası her zaman yanında',         'heroes',  'common',    'assets/cards/heroes/explorer.png'),
    (18, 'Genç Doktor',        'İyi hissettiren kahraman',           'heroes',  'rare',      'assets/cards/heroes/doctor.png'),
    (19, 'Mini Astronot',      'Yıldızlara yolculuk',                'heroes',  'epic',      'assets/cards/heroes/astronaut.png'),
    (20, 'Küçük Mühendis',     'Her şeyi yapabilen',                 'heroes',  'rare',      'assets/cards/heroes/engineer.png'),
    (21, 'Mini Şef',           'Mutfağın yıldızı',                   'heroes',  'common',    'assets/cards/heroes/chef.png'),
    (22, 'Genç Ressam',        'Renklerin ustası',                   'heroes',  'common',    'assets/cards/heroes/artist.png'),
    (23, 'Küçük Müzisyen',     'Notalar onun dili',                  'heroes',  'rare',      'assets/cards/heroes/musician.png'),
    (24, 'Mini Sporcu',        'Ter döken şampiyon',                 'heroes',  'common',    'assets/cards/heroes/athlete.png'),
    (25, 'Genç Öğretmen',      'Bilgiyi paylaşan',                   'heroes',  'rare',      'assets/cards/heroes/teacher.png'),
    (26, 'Küçük Pilot',        'Gökyüzünde özgür',                   'heroes',  'epic',      'assets/cards/heroes/pilot.png'),
    (27, 'Mini Dalgıç',        'Denizin derinliklerinde',            'heroes',  'rare',      'assets/cards/heroes/diver.png'),
    (28, 'Genç Arkeolog',      'Tarihin izinde',                     'heroes',  'epic',      'assets/cards/heroes/archaeologist.png'),
    (29, 'Süper Kahraman',     'Maskeli kurtarıcı',                  'heroes',  'legendary', 'assets/cards/heroes/superhero.png'),
    (30, 'Mini Sihirbaz',      'Sihirli şapkalı dost',               'heroes',  'epic',      'assets/cards/heroes/magician.png'),
    (31, 'Bilge Newton',       'Elmayı düşüren dahi',                'legends', 'rare',      'assets/cards/legends/newton.png'),
    (32, 'Meraklı Curie',      'Radyumu keşfeden kahraman',          'legends', 'epic',      'assets/cards/legends/curie.png'),
    (33, 'Yaratıcı Einstein',  'Göreceli dahi',                      'legends', 'legendary', 'assets/cards/legends/einstein.png'),
    (34, 'Kaşif Kolomb',       'Yeni dünyaları bulan',               'legends', 'rare',      'assets/cards/legends/columbus.png'),
    (35, 'Mucitçi Edison',     'Ampulü yakan dahi',                  'legends', 'epic',      'assets/cards/legends/edison.png'),
    (36, 'Uçan Bernoulli',     'Uçuşu anlayan bilge',                'legends', 'rare',      'assets/cards/legends/bernoulli.png'),
    (37, 'Matematikçi Öklid',  'Geometrinin babası',                 'legends', 'epic',      'assets/cards/legends/euclid.png'),
    (38, 'Dahi da Vinci',      'Her şeyi yapabilen sanatçı',         'legends', 'legendary', 'assets/cards/legends/da_vinci.png'),
    (39, 'Yıldız Hawking',     'Evrenin sırlarını çözen',            'legends', 'legendary', 'assets/cards/legends/hawking.png'),
    (40, 'Bilge Atatürk',      'Cumhuriyetin kurucusu',              'legends', 'legendary', 'assets/cards/legends/ataturk.png');

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM "_new_card_catalog" catalog
        LEFT JOIN collectible_cards card
          ON card."CardNumber" = catalog."CardNumber"
         AND card."IsDeleted" = FALSE
        WHERE card."Id" IS NULL
    ) THEN
        RAISE EXCEPTION
          'Mevcut katalogda 1-40 arasındaki bazı kart numaraları bulunamadı. İşlem geri alındı.';
    END IF;
END $$;

-- Her kart numarası için en çok sahiplik kaydı olan mevcut kartı ana kayıt seç.
CREATE TEMP TABLE "_card_id_map" ON COMMIT DROP AS
WITH ownership AS
(
    SELECT
        card."Id",
        COUNT(child_card."Id") AS owned_profiles
    FROM collectible_cards card
    LEFT JOIN child_cards child_card ON child_card."CardId" = card."Id"
    WHERE card."CardNumber" BETWEEN 1 AND 40
      AND card."IsDeleted" = FALSE
    GROUP BY card."Id"
),
ranked AS
(
    SELECT
        card."Id" AS source_id,
        card."CardNumber" AS card_number,
        FIRST_VALUE(card."Id") OVER
        (
            PARTITION BY card."CardNumber"
            ORDER BY ownership.owned_profiles DESC,
                     card."CreatedAt" ASC,
                     card."Id" ASC
        ) AS target_id
    FROM collectible_cards card
    JOIN ownership ON ownership."Id" = card."Id"
    WHERE card."CardNumber" BETWEEN 1 AND 40
      AND card."IsDeleted" = FALSE
)
SELECT source_id, target_id, card_number
FROM ranked;

-- Aynı profilin aynı kart numarasındaki bütün kazanımlarını birleştir.
CREATE TEMP TABLE "_merged_child_cards" ON COMMIT DROP AS
SELECT
    child_card."ChildProfileId",
    map.target_id AS "CardId",
    SUM(child_card."Count")::integer AS "Count",
    MIN(child_card."FirstEarnedAt") AS "FirstEarnedAt",
    MAX(child_card."LastEarnedAt") AS "LastEarnedAt"
FROM child_cards child_card
JOIN "_card_id_map" map ON map.source_id = child_card."CardId"
GROUP BY child_card."ChildProfileId", map.target_id;

DELETE FROM child_cards
WHERE "CardId" IN (SELECT source_id FROM "_card_id_map");

INSERT INTO child_cards
    ("Id", "ChildProfileId", "CardId", "Count", "FirstEarnedAt", "LastEarnedAt")
SELECT
    gen_random_uuid(),
    "ChildProfileId",
    "CardId",
    "Count",
    "FirstEarnedAt",
    "LastEarnedAt"
FROM "_merged_child_cards";

-- Kazanma geçmişini ana kart kayıtlarına taşı.
UPDATE card_drop_log log
SET "CardId" = map.target_id
FROM "_card_id_map" map
WHERE log."CardId" = map.source_id
  AND map.source_id <> map.target_id;

-- Artık ilişkisi kalmayan kopya kart tanımlarını kaldır.
DELETE FROM collectible_cards card
USING "_card_id_map" map
WHERE card."Id" = map.source_id
  AND map.source_id <> map.target_id;

-- Ana kayıtların ID'lerini koruyarak yeni kataloğa dönüştür.
UPDATE collectible_cards card
SET
    "Name" = catalog."Name",
    "Description" = catalog."Description",
    "Series" = catalog."Series",
    "Rarity" = catalog."Rarity",
    "ImageAsset" = catalog."ImageAsset",
    "IsActive" = TRUE,
    "IsDeleted" = FALSE,
    "UpdatedAt" = NOW()
FROM "_new_card_catalog" catalog
WHERE card."CardNumber" = catalog."CardNumber"
  AND card."Id" IN (SELECT DISTINCT target_id FROM "_card_id_map");

COMMIT;

-- Beklenen sonuç: 40 aktif kart ve CardNumber başına tek kayıt.
SELECT
    COUNT(*) AS active_card_count,
    COUNT(DISTINCT "CardNumber") AS distinct_card_number_count
FROM collectible_cards
WHERE "IsActive" = TRUE
  AND "IsDeleted" = FALSE;

SELECT "Series", COUNT(*) AS card_count
FROM collectible_cards
WHERE "IsActive" = TRUE
  AND "IsDeleted" = FALSE
GROUP BY "Series"
ORDER BY "Series";
