-- Mevcut collectible_cards tablosuna 91-120 numaralı 30 yeni kartı ekler.
-- Yeni tablo oluşturmaz; aynı sabit kimliklerle tekrar çalıştırılabilir.

BEGIN;

-- Bu kart numaralarının daha önce farklı kimliklerle kullanılmadığını doğrular.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM collectible_cards
        WHERE "CardNumber" BETWEEN 91 AND 120
          AND "IsDeleted" = FALSE
          AND "Id" NOT IN (
              'c4000001-0000-0000-0000-000000000091'::uuid,
              'c4000001-0000-0000-0000-000000000092'::uuid,
              'c4000001-0000-0000-0000-000000000093'::uuid,
              'c4000001-0000-0000-0000-000000000094'::uuid,
              'c4000001-0000-0000-0000-000000000095'::uuid,
              'c4000001-0000-0000-0000-000000000096'::uuid,
              'c4000001-0000-0000-0000-000000000097'::uuid,
              'c4000001-0000-0000-0000-000000000098'::uuid,
              'c4000001-0000-0000-0000-000000000099'::uuid,
              'c4000001-0000-0000-0000-000000000100'::uuid,
              'c4000001-0000-0000-0000-000000000101'::uuid,
              'c4000001-0000-0000-0000-000000000102'::uuid,
              'c4000001-0000-0000-0000-000000000103'::uuid,
              'c4000001-0000-0000-0000-000000000104'::uuid,
              'c4000001-0000-0000-0000-000000000105'::uuid,
              'c4000001-0000-0000-0000-000000000106'::uuid,
              'c4000001-0000-0000-0000-000000000107'::uuid,
              'c4000001-0000-0000-0000-000000000108'::uuid,
              'c4000001-0000-0000-0000-000000000109'::uuid,
              'c4000001-0000-0000-0000-000000000110'::uuid,
              'c4000001-0000-0000-0000-000000000111'::uuid,
              'c4000001-0000-0000-0000-000000000112'::uuid,
              'c4000001-0000-0000-0000-000000000113'::uuid,
              'c4000001-0000-0000-0000-000000000114'::uuid,
              'c4000001-0000-0000-0000-000000000115'::uuid,
              'c4000001-0000-0000-0000-000000000116'::uuid,
              'c4000001-0000-0000-0000-000000000117'::uuid,
              'c4000001-0000-0000-0000-000000000118'::uuid,
              'c4000001-0000-0000-0000-000000000119'::uuid,
              'c4000001-0000-0000-0000-000000000120'::uuid
          )
    ) THEN
        RAISE EXCEPTION '91-120 aralığında farklı ID kullanan kart numarası bulundu. İşlem geri alındı.';
    END IF;
END $$;

INSERT INTO collectible_cards
    ("Id", "Name", "Description", "Series", "Rarity", "ImageAsset", "CardNumber", "IsActive", "CreatedAt", "UpdatedAt", "IsDeleted")
VALUES
    ('c4000001-0000-0000-0000-000000000091', 'Şefkatli Manati',          'Denizin küçük dostlarına sakinlikle yardım eder',       'animals',         'common',    'assets/cards/animals/kind_manatee.png',              91, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000092', 'Yıldızlı Semender',        'Gece göğünün ışıklarıyla yolunu bulan minik dost',      'animals',         'rare',      'assets/cards/animals/starry_salamander.png',          92, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000093', 'Cesur Porsuk',             'Orman yollarını güvenle keşfeden dikkatli rehber',      'animals',         'common',    'assets/cards/animals/brave_badger.png',               93, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000094', 'Uçurtma Balığı',           'Resiflerin arasında zarafetle süzülen deniz yolcusu',   'animals',         'rare',      'assets/cards/animals/kite_ray.png',                   94, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000095', 'Kristal Kirpi',            'Parlayan taşların sırlarını bulan meraklı kaşif',       'animals',         'epic',      'assets/cards/animals/crystal_hedgehog.png',           95, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000096', 'Çöl Feneği',               'Kocaman kulaklarıyla çölün fısıltılarını dinler',       'animals',         'common',    'assets/cards/animals/desert_fennec.png',              96, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000097', 'Meraklı Okapi',            'Orman çiçeklerini inceleyen çizgili botanikçi',         'animals',         'rare',      'assets/cards/animals/curious_okapi.png',              97, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000098', 'Efsane Deniz Ejderi',      'Yosun ormanlarının büyülü ve nazik koruyucusu',         'animals',         'legendary', 'assets/cards/animals/legendary_sea_dragon.png',       98, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000099', 'Bitki Doktoru',            'Yapraklara iyi gelecek küçük çözümler bulan kahraman',  'heroes',          'common',    'assets/cards/heroes/plant_doctor.png',                99, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000100', 'Köprü Kurucusu',           'Fikirleri güvenli geçitlere dönüştüren genç mühendis',  'heroes',          'rare',      'assets/cards/heroes/bridge_builder.png',             100, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000101', 'Ses Mühendisi',            'Sesleri uyumlu ve eğlenceli ezgilere dönüştürür',       'heroes',          'rare',      'assets/cards/heroes/sound_engineer.png',             101, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000102', 'Işık Fotoğrafçısı',        'Renklerin ışıkla yaptığı dansı yakalar',                'heroes',          'common',    'assets/cards/heroes/light_photographer.png',         102, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000103', 'Yardımsever Postacı',      'İyi dilekleri ve haberleri sevgiyle ulaştırır',          'heroes',          'common',    'assets/cards/heroes/helpful_postal_worker.png',      103, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000104', 'Sürdürülebilir Tasarımcı', 'Eski malzemelere yepyeni bir hayat verir',              'heroes',          'epic',      'assets/cards/heroes/sustainable_designer.png',        104, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000105', 'Bilge El Cezeri',          'Makinelere hayat veren yaratıcı mucit',                 'legends',         'epic',      'assets/cards/legends/al_jazari.png',                 105, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000106', 'Bilge İbn Haldun',         'Toplumları ve geçmişi anlamaya çalışan düşünür',         'legends',         'rare',      'assets/cards/legends/ibn_khaldun.png',               106, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000107', 'Denizci Zheng He',         'Uzak denizlere bilgi ve dostluk taşıyan kaşif',          'legends',         'rare',      'assets/cards/legends/zheng_he.png',                  107, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000108', 'Ressam Frida Kahlo',       'Renklerle cesur ve özgün hikâyeler anlatan sanatçı',     'legends',         'epic',      'assets/cards/legends/frida_kahlo.png',               108, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000109', 'Doğa Bilgesi Jane Goodall','Şempanzeleri sabırla gözlemleyen bilim insanı',          'legends',         'legendary', 'assets/cards/legends/jane_goodall.png',               109, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000110', 'Meteoroloji Uzmanı',       'Bulutları, rüzgârı ve yağmuru dikkatle gözlemler',      'science',         'common',    'assets/cards/science/weather_specialist.png',         110, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000111', 'Buz Kristali Araştırmacısı','Her kar tanesindeki eşsiz şekli keşfeder',              'science',         'rare',      'assets/cards/science/ice_crystal_researcher.png',     111, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000112', 'Güneş Enerjisi Ustası',    'Güneş ışığını faydalı enerjiye dönüştürür',             'science',         'rare',      'assets/cards/science/solar_energy_master.png',        112, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000113', 'Drone Kâşifi',             'Gökyüzünden yeni ayrıntılar bulan genç mucit',           'science',         'epic',      'assets/cards/science/drone_explorer.png',             113, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000114', 'Yağmur Bahçıvanı',         'Yağmur suyuyla bahçesine hayat verir',                  'nature_space',    'common',    'assets/cards/nature_space/rain_gardener.png',         114, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000115', 'Mağara Kaşifi',            'Yerin altındaki renkli taşları merakla inceler',         'nature_space',    'rare',      'assets/cards/nature_space/cave_explorer.png',         115, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000116', 'Tohum Muhafızı',           'Küçük tohumları geleceğin ormanları için saklar',        'nature_space',    'rare',      'assets/cards/nature_space/seed_keeper.png',           116, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000117', 'Kuzey Işıkları Gözlemcisi','Gökyüzündeki renkli ışıkların peşinden gider',          'nature_space',    'legendary', 'assets/cards/nature_space/aurora_observer.png',       117, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000118', 'Gölge Oyunu Ustası',       'Işık ve elleriyle eğlenceli hikâyeler kurar',            'culture_history', 'common',    'assets/cards/culture_history/shadow_play_master.png', 118, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000119', 'Seramik Sanatçısı',        'Toprağı sabırla renkli bir esere dönüştürür',            'culture_history', 'rare',      'assets/cards/culture_history/ceramic_artist.png',     119, TRUE, NOW(), NULL, FALSE),
    ('c4000001-0000-0000-0000-000000000120', 'Köprü Hikâyecisi',         'Hikâyelerle farklı kalpleri birbirine yaklaştırır',      'culture_history', 'epic',      'assets/cards/culture_history/bridge_storyteller.png', 120, TRUE, NOW(), NULL, FALSE)
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

-- Çalıştırma sonrası: toplam 120 aktif kart, bu aralıkta 30 kart beklenir.
SELECT
    COUNT(*) FILTER (WHERE "IsActive" = TRUE AND "IsDeleted" = FALSE) AS active_card_count,
    COUNT(DISTINCT "CardNumber") FILTER (WHERE "IsActive" = TRUE AND "IsDeleted" = FALSE) AS distinct_card_number_count,
    COUNT(*) FILTER (WHERE "CardNumber" BETWEEN 91 AND 120 AND "IsActive" = TRUE AND "IsDeleted" = FALSE) AS new_card_count
FROM collectible_cards;
