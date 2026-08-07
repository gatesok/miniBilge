-- Mevcut collectible_cards tablosuna 81-90 numaralı yeni kartları ekler.
-- Yeni bir kalıcı veya geçici tablo oluşturmaz.
-- Aynı ID'lerle tekrar çalıştırılabilir; mevcut child_cards ve card_drop_log
-- kayıtlarına dokunmaz.

BEGIN;

-- Aynı kart numarasının daha önce farklı bir ID ile kullanılmış olması veri
-- çakışmasıdır; bu durumda hiçbir değişiklik yapmadan işlemi durdur.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM collectible_cards existing
        JOIN (
            VALUES
                ('c3000001-0000-0000-0000-000000000081'::uuid, 81),
                ('c3000001-0000-0000-0000-000000000082'::uuid, 82),
                ('c3000001-0000-0000-0000-000000000083'::uuid, 83),
                ('c3000001-0000-0000-0000-000000000084'::uuid, 84),
                ('c3000001-0000-0000-0000-000000000085'::uuid, 85),
                ('c3000001-0000-0000-0000-000000000086'::uuid, 86),
                ('c3000001-0000-0000-0000-000000000087'::uuid, 87),
                ('c3000001-0000-0000-0000-000000000088'::uuid, 88),
                ('c3000001-0000-0000-0000-000000000089'::uuid, 89),
                ('c3000001-0000-0000-0000-000000000090'::uuid, 90)
        ) AS catalog("Id", "CardNumber")
          ON existing."CardNumber" = catalog."CardNumber"
        WHERE existing."Id" <> catalog."Id"
          AND existing."IsDeleted" = FALSE
    ) THEN
        RAISE EXCEPTION
          '81-90 aralığında farklı ID kullanan kart numarası bulundu. İşlem geri alındı.';
    END IF;
END $$;

INSERT INTO collectible_cards
    ("Id", "Name", "Description", "Series", "Rarity", "ImageAsset",
     "CardNumber", "IsActive", "CreatedAt", "UpdatedAt", "IsDeleted")
VALUES
    ('c3000001-0000-0000-0000-000000000081', 'Meraklı Kapibara',       'Her kıyıda yeni bir ipucu bulan sakin kaşif',       'animals',         'common',    'assets/cards/animals/curious_capybara.png',      81, TRUE, NOW(), NULL, FALSE),
    ('c3000001-0000-0000-0000-000000000082', 'Ay Işığı Vaşağı',       'Ormanın gece sırlarını iz süren sessiz dost',       'animals',         'rare',      'assets/cards/animals/moonlight_lynx.png',        82, TRUE, NOW(), NULL, FALSE),
    ('c3000001-0000-0000-0000-000000000083', 'Geri Dönüşüm Mühendisi','Eski eşyaları yeni fikirlere dönüştüren kahraman',   'heroes',          'common',    'assets/cards/heroes/recycling_engineer.png',     83, TRUE, NOW(), NULL, FALSE),
    ('c3000001-0000-0000-0000-000000000084', 'Genç Oyun Tasarımcısı', 'Hayal gücüyle eğlenceli dünyalar kuran yaratıcı',    'heroes',          'rare',      'assets/cards/heroes/young_game_designer.png',    84, TRUE, NOW(), NULL, FALSE),
    ('c3000001-0000-0000-0000-000000000085', 'Bilge Hypatia',         'Yıldızları ve şekilleri merakla inceleyen bilgin',  'legends',         'epic',      'assets/cards/legends/hypatia.png',               85, TRUE, NOW(), NULL, FALSE),
    ('c3000001-0000-0000-0000-000000000086', 'Müzik Bilgesi Farabi',  'Bilgiyi ve ezgileri bir araya getiren düşünür',     'legends',         'rare',      'assets/cards/legends/al_farabi.png',             86, TRUE, NOW(), NULL, FALSE),
    ('c3000001-0000-0000-0000-000000000087', 'Volkan Araştırmacısı',  'Kayaların anlattığı yeryüzü öykülerini dinleyen',    'science',         'common',    'assets/cards/science/volcano_researcher.png',    87, TRUE, NOW(), NULL, FALSE),
    ('c3000001-0000-0000-0000-000000000088', 'Kuantum Mucidi',        'Görünmeyen dünyadan parlak fikirler üreten mucit',  'science',         'legendary', 'assets/cards/science/quantum_inventor.png',      88, TRUE, NOW(), NULL, FALSE),
    ('c3000001-0000-0000-0000-000000000089', 'Mercan Koruyucusu',     'Renkli resiflerin canlı kalması için çalışan dost',  'nature_space',    'rare',      'assets/cards/nature_space/coral_guardian.png',   89, TRUE, NOW(), NULL, FALSE),
    ('c3000001-0000-0000-0000-000000000090', 'Kültür Elçisi',         'Farklı sesleri ve hikâyeleri dostlukla buluşturan',  'culture_history', 'epic',      'assets/cards/culture_history/culture_ambassador.png', 90, TRUE, NOW(), NULL, FALSE)
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

-- Çalıştırma sonrası kontrol: toplamın 90'a, yeni eklenen kart aralığının ise 10'a ulaşması beklenir.
SELECT
    COUNT(*) FILTER (WHERE "IsActive" = TRUE AND "IsDeleted" = FALSE) AS active_card_count,
    COUNT(DISTINCT "CardNumber") FILTER (WHERE "IsActive" = TRUE AND "IsDeleted" = FALSE) AS distinct_card_number_count,
    COUNT(*) FILTER (WHERE "CardNumber" BETWEEN 81 AND 90 AND "IsActive" = TRUE AND "IsDeleted" = FALSE) AS new_card_count
FROM collectible_cards;
