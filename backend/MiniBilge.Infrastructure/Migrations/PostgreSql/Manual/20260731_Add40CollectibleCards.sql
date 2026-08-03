-- MiniBilge kart kataloğuna 41-80 numaralı 40 yeni kart ekler.
--
-- Bu script:
--   * Mevcut 1-40 kartı değiştirmez.
--   * child_cards ve card_drop_log verilerine dokunmaz.
--   * Aynı sabit ID'lerle tekrar çalıştırılabilir.

BEGIN;

CREATE TEMP TABLE "_additional_card_catalog"
(
    "Id" uuid PRIMARY KEY,
    "CardNumber" integer UNIQUE NOT NULL,
    "Name" text NOT NULL,
    "Description" text NOT NULL,
    "Series" text NOT NULL,
    "Rarity" text NOT NULL,
    "ImageAsset" text NOT NULL
) ON COMMIT DROP;

INSERT INTO "_additional_card_catalog"
    ("Id", "CardNumber", "Name", "Description", "Series", "Rarity", "ImageAsset")
VALUES
    ('c2000001-0000-0000-0000-000000000041', 41, 'Panda Matematikçi',       'Bambu kadar sayıları da seven panda',          'animals',         'common',    'assets/cards/animals/math_panda.png'),
    ('c2000001-0000-0000-0000-000000000042', 42, 'Neşeli Su Samuru',        'Suda oyun kuran neşeli dost',                  'animals',         'common',    'assets/cards/animals/happy_otter.png'),
    ('c2000001-0000-0000-0000-000000000043', 43, 'Maceracı Rakun',          'Her patikada yeni bir sır bulan rakun',         'animals',         'common',    'assets/cards/animals/adventurer_raccoon.png'),
    ('c2000001-0000-0000-0000-000000000044', 44, 'Zarif Zürafa',            'Uzakları gören uzun boylu dost',                'animals',         'common',    'assets/cards/animals/graceful_giraffe.png'),
    ('c2000001-0000-0000-0000-000000000045', 45, 'Hızlı Çita',              'Savananın yıldırım gibi koşucusu',              'animals',         'rare',      'assets/cards/animals/fast_cheetah.png'),
    ('c2000001-0000-0000-0000-000000000046', 46, 'Bilge Ahtapot',           'Sekiz koluyla sekiz çözüm bulan bilge',          'animals',         'epic',      'assets/cards/animals/wise_octopus.png'),
    ('c2000001-0000-0000-0000-000000000047', 47, 'Koruyucu Kurt',           'Ormanın sessiz ve cesur koruyucusu',             'animals',         'rare',      'assets/cards/animals/guardian_wolf.png'),
    ('c2000001-0000-0000-0000-000000000048', 48, 'Renkli Bukalemun',        'Her ortama renk katan küçük usta',               'animals',         'common',    'assets/cards/animals/colorful_chameleon.png'),
    ('c2000001-0000-0000-0000-000000000049', 49, 'Kızıl Panda',             'Ormanın meraklı ve sevimli gezgini',             'animals',         'common',    'assets/cards/animals/red_panda.png'),
    ('c2000001-0000-0000-0000-000000000050', 50, 'Efsanevi Anka',           'Küllerinden yeniden doğan ateş kuşu',            'animals',         'legendary', 'assets/cards/animals/phoenix.png'),

    ('c2000001-0000-0000-0000-000000000051', 51, 'Genç Kodlayıcı',          'Fikirlerini kodla gerçeğe dönüştüren',           'heroes',          'common',    'assets/cards/heroes/young_coder.png'),
    ('c2000001-0000-0000-0000-000000000052', 52, 'Mini Veteriner',          'Hayvan dostlarını iyileştiren kahraman',         'heroes',          'common',    'assets/cards/heroes/veterinarian.png'),
    ('c2000001-0000-0000-0000-000000000053', 53, 'Küçük Mimar',             'Hayallerden yapılar tasarlayan',                  'heroes',          'common',    'assets/cards/heroes/architect.png'),
    ('c2000001-0000-0000-0000-000000000054', 54, 'Genç Denizci',            'Dalgaları pusulasıyla aşan',                     'heroes',          'rare',      'assets/cards/heroes/young_sailor.png'),
    ('c2000001-0000-0000-0000-000000000055', 55, 'Doğa Koruyucusu',         'Yeşil dünyayı sevgiyle savunan',                 'heroes',          'rare',      'assets/cards/heroes/nature_guardian.png'),
    ('c2000001-0000-0000-0000-000000000056', 56, 'Robot Ustası',            'Akıllı makineler yapan genç mucit',              'heroes',          'epic',      'assets/cards/heroes/robot_master.png'),
    ('c2000001-0000-0000-0000-000000000057', 57, 'Cesur İtfaiyeci',         'Alevlere karşı cesaretle koşan',                 'heroes',          'rare',      'assets/cards/heroes/firefighter.png'),
    ('c2000001-0000-0000-0000-000000000058', 58, 'Zaman Gezgini',           'Çağlar arasında bilgi peşinde',                  'heroes',          'legendary', 'assets/cards/heroes/time_traveler.png'),

    ('c2000001-0000-0000-0000-000000000059', 59, 'Bilge İbn Sina',          'Bilim ve tıbbın izini süren bilge',               'legends',         'rare',      'assets/cards/legends/ibn_sina.png'),
    ('c2000001-0000-0000-0000-000000000060', 60, 'Gökyüzü Hezarfen',        'Kanatlarıyla göğe uzanan öncü',                  'legends',         'rare',      'assets/cards/legends/hezarfen.png'),
    ('c2000001-0000-0000-0000-000000000061', 61, 'Sayıların Ustası Harezmi','Cebirin yollarını açan bilgin',                  'legends',         'epic',      'assets/cards/legends/al_khwarizmi.png'),
    ('c2000001-0000-0000-0000-000000000062', 62, 'Yıldız Kaşifi Galileo',   'Gökyüzünü teleskobuyla keşfeden',                'legends',         'epic',      'assets/cards/legends/galileo.png'),
    ('c2000001-0000-0000-0000-000000000063', 63, 'Meraklı Ada Lovelace',    'İlk algoritmanın yaratıcı öncüsü',               'legends',         'legendary', 'assets/cards/legends/ada_lovelace.png'),
    ('c2000001-0000-0000-0000-000000000064', 64, 'Bilge Mimar Sinan',       'Yüzyıllara meydan okuyan yapılar kuran',          'legends',         'rare',      'assets/cards/legends/mimar_sinan.png'),
    ('c2000001-0000-0000-0000-000000000065', 65, 'Denizci Piri Reis',       'Dünyayı haritalara taşıyan kaptan',              'legends',         'legendary', 'assets/cards/legends/piri_reis.png'),

    ('c2000001-0000-0000-0000-000000000066', 66, 'Atom Kaşifi',             'Maddenin en küçük sırlarını araştıran',           'science',         'common',    'assets/cards/science/atom_explorer.png'),
    ('c2000001-0000-0000-0000-000000000067', 67, 'Dinozor Dedektifi',       'Fosillerden geçmişi okuyan araştırmacı',          'science',         'common',    'assets/cards/science/dinosaur_detective.png'),
    ('c2000001-0000-0000-0000-000000000068', 68, 'Mikroskop Ustası',        'Görünmeyen dünyaları keşfeden',                  'science',         'rare',      'assets/cards/science/microscope_master.png'),
    ('c2000001-0000-0000-0000-000000000069', 69, 'Roket Tasarımcısı',       'Yıldızlara ulaşan araçlar tasarlayan',            'science',         'epic',      'assets/cards/science/rocket_designer.png'),
    ('c2000001-0000-0000-0000-000000000070', 70, 'Okyanus Araştırmacısı',   'Derin denizlerin gizemini çözen',                 'science',         'epic',      'assets/cards/science/ocean_researcher.png'),
    ('c2000001-0000-0000-0000-000000000071', 71, 'Gelecek Mucidi',          'Yarının dünyasını bugünden kuran',                'science',         'legendary', 'assets/cards/science/future_inventor.png'),

    ('c2000001-0000-0000-0000-000000000072', 72, 'Bulut Gözlemcisi',        'Gökyüzündeki şekilleri ve havayı okuyan',         'nature_space',    'common',    'assets/cards/nature_space/cloud_watcher.png'),
    ('c2000001-0000-0000-0000-000000000073', 73, 'Orman Koruyucusu',        'Ağaçların ve canlıların dostu',                   'nature_space',    'common',    'assets/cards/nature_space/forest_keeper.png'),
    ('c2000001-0000-0000-0000-000000000074', 74, 'Gezegen Gezgini',         'Uzak dünyalarda iz süren',                        'nature_space',    'rare',      'assets/cards/nature_space/planet_rover.png'),
    ('c2000001-0000-0000-0000-000000000075', 75, 'Kutup Kaşifi',            'Buzulların gizemli yollarını aşan',               'nature_space',    'epic',      'assets/cards/nature_space/polar_explorer.png'),
    ('c2000001-0000-0000-0000-000000000076', 76, 'Galaksi Rehberi',         'Yıldızlar arasında doğru yolu bulan',             'nature_space',    'legendary', 'assets/cards/nature_space/galaxy_guide.png'),

    ('c2000001-0000-0000-0000-000000000077', 77, 'Masal Anlatıcısı',        'Kültürleri renkli hikâyelerle buluşturan',        'culture_history', 'common',    'assets/cards/culture_history/storyteller.png'),
    ('c2000001-0000-0000-0000-000000000078', 78, 'Ritim Ustası',            'Dünyanın ritimlerini bir araya getiren',          'culture_history', 'rare',      'assets/cards/culture_history/rhythm_master.png'),
    ('c2000001-0000-0000-0000-000000000079', 79, 'Tarih Dedektifi',         'Geçmişin ipuçlarını birleştiren',                 'culture_history', 'epic',      'assets/cards/culture_history/history_detective.png'),
    ('c2000001-0000-0000-0000-000000000080', 80, 'Dünya Gezgini',           'Farklı kültürleri tanıyıp dostluk kuran',         'culture_history', 'epic',      'assets/cards/culture_history/world_traveler.png');

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM collectible_cards existing
        JOIN "_additional_card_catalog" catalog
          ON existing."CardNumber" = catalog."CardNumber"
        WHERE existing."Id" <> catalog."Id"
          AND existing."IsDeleted" = FALSE
    ) THEN
        RAISE EXCEPTION
          '41-80 aralığında farklı ID kullanan kart numarası bulundu. İşlem geri alındı.';
    END IF;
END $$;

INSERT INTO collectible_cards
    ("Id", "Name", "Description", "Series", "Rarity", "ImageAsset",
     "CardNumber", "IsActive", "CreatedAt", "UpdatedAt", "IsDeleted")
SELECT
    catalog."Id",
    catalog."Name",
    catalog."Description",
    catalog."Series",
    catalog."Rarity",
    catalog."ImageAsset",
    catalog."CardNumber",
    TRUE,
    NOW(),
    NULL,
    FALSE
FROM "_additional_card_catalog" catalog
ON CONFLICT ("Id") DO UPDATE
SET
    "Name" = EXCLUDED."Name",
    "Description" = EXCLUDED."Description",
    "Series" = EXCLUDED."Series",
    "Rarity" = EXCLUDED."Rarity",
    "ImageAsset" = EXCLUDED."ImageAsset",
    "CardNumber" = EXCLUDED."CardNumber",
    "IsActive" = TRUE,
    "IsDeleted" = FALSE,
    "UpdatedAt" = NOW();

COMMIT;

-- Beklenen toplam: 80 aktif kart ve 80 farklı kart numarası.
SELECT
    COUNT(*) AS active_card_count,
    COUNT(DISTINCT "CardNumber") AS distinct_card_number_count
FROM collectible_cards
WHERE "IsActive" = TRUE
  AND "IsDeleted" = FALSE;

-- Yeni 40 kart için beklenen nadirlik dağılımı:
-- common=14, rare=11, epic=9, legendary=6
SELECT "Rarity", COUNT(*) AS card_count
FROM collectible_cards
WHERE "CardNumber" BETWEEN 41 AND 80
  AND "IsActive" = TRUE
  AND "IsDeleted" = FALSE
GROUP BY "Rarity"
ORDER BY "Rarity";

-- Yeni seri dağılımını doğrular.
SELECT "Series", COUNT(*) AS card_count
FROM collectible_cards
WHERE "CardNumber" BETWEEN 41 AND 80
  AND "IsActive" = TRUE
  AND "IsDeleted" = FALSE
GROUP BY "Series"
ORDER BY "Series";

