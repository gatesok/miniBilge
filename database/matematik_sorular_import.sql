-- =====================================================
-- MiniBilge - 4. Sınıf Matematik Soru Import Script
-- 18 Test, 236 Soru - Tek Topic: '4.sınıf Deneme Sorular'
-- =====================================================

DO $$
DECLARE
    v_subject_id  UUID;
    v_topic_id    UUID;
    v_level_id    UUID;
    v_question_id UUID;
BEGIN

    -- ADIM 1: Subject - Matematik
    SELECT "Id" INTO v_subject_id FROM subjects WHERE "Name" = 'Matematik' AND "IsDeleted" = false LIMIT 1;
    IF v_subject_id IS NULL THEN
        v_subject_id := gen_random_uuid();
        INSERT INTO subjects ("Id", "Name", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
        VALUES (v_subject_id, 'Matematik', 1, true, NOW(), false);
    END IF;

    -- ADIM 2: Topic - 4.sınıf Deneme Sorular (tek topic)
    SELECT "Id" INTO v_topic_id FROM topics WHERE "Name" = '4.sınıf Deneme Sorular' AND "SubjectId" = v_subject_id AND "IsDeleted" = false LIMIT 1;
    IF v_topic_id IS NULL THEN
        v_topic_id := gen_random_uuid();
        INSERT INTO topics ("Id", "SubjectId", "Name", "Description", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
        VALUES (v_topic_id, v_subject_id, '4.sınıf Deneme Sorular', '4. Sınıf Matematik Deneme Testleri', 1, true, NOW(), false);
    END IF;

    -- =====================================================
    -- TEST 1: Doğal Sayılar - Test 1
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Doğal Sayılar - Test 1', 1, 1, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'dokuz yüz bin beş yüz altı Yandaki kartın üze rinde okunuşu yazı lan sayının rakamla yazılışı aşağıdaki lerden hangisidir?', 0, 'B', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '950 506', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '900 506', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '900 056', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '905 056', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '1200-1300- -1500- Yukarıdaki ritmik saymada kutulara yazılması gereken sayılar sırayla hangileridir?', 0, 'B', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1400 - 1500 	 B.	1400 - 1600', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '1500 - 1600 	 D.	1700 - 1600', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '"485 579" sayısının çözümlenmiş şekli aşağıdakilerden hangisidir?', 0, 'D', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '(4 x 100 000) + (8 x 1000) + (5 x 100) + (7 x 10) + (9 x 1)', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '(4 x 10 000) + (8 x 10 000) + (5 x 1000) + (5 x 100) + (7 x 10) + (9 x 1)', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '(4 x 100 000) + (8 x 10 000) + (5 x 100) + (7 x 10) + (9 x 1)', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '(4 x 100 000) + (8 x 10 000) + (5 x 1000) + (5 x 100) + (7 x 10) + (9 x 1)', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '1500 sayısından başlayarak biner ritmik saydığımızda dördüncü sırada söylediğimiz sayı hangisi olur?', 0, 'C', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '3000', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '3500', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '4500', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '5500', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '80 008 80 800 80 080 88 000 8 on binlik ve 8 yüzlükten oluşan sayıyı kelebeklerden hangisi taşı maktadır?', 0, 'B', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Abaküsle modelle- nen sayı aşağıdakiler den hangisidir?', 0, 'C', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '50 224', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '552 134', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '502 134', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '501 234 2 kitap&kitap', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '"On bin beş yüz iki" sayısının binler bölüğünde hangi sayı bulunur?', 0, 'B', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '100', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '10', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '500', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '502', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '"67 ■ 53 < 67 837" eşitsizliğinin doğru olması için ■ yerine yazılabi lecek kaç tane rakam vardır?', 0, 'C', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '6', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '7', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '8', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '9', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '"854 206" doğal sayısında on binler ile yüzler basamağındaki rakamların basamak değeri farkı kaçtır?', 0, 'A', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '49 800', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '59 800', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '490 800', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '590 800', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '"ADALAR" kelimesini oluşturan rakamlar hangi seçenekte doğru verilmiştir?', 0, 'B', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '565 721', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '525 854', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '876 652', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '327 891', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'En yakın yüzlüğe 4500 olarak yuvarlanan en küçük doğal sayı hangisidir?', 0, 'B', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '4439', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '4450', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '4451', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '4455', 3, NOW(), false);

    -- Soru 12
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Yüzler basamağında 4, binler basa mağında 7 bulunan altı basamaklı en büyük doğal sayı kaçtır?', 0, 'D', 12, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '994 799', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '794 999', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '979 499', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '997 499', 3, NOW(), false);

    -- Soru 13
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '950-1050-1150- -1350 Yukarıdaki sayı örüntüsünde kutu içine yazılması gereken sayı aşağı dakilerden hangisidir?', 0, 'B', 13, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1200  B. 1250  C. 1300   D. 1450', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 14
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '35 042 - 35 142 - 35 242 - - 35 442 - 35 542 Yukarıdaki örüntüde kutu içine yazıl ması gereken sayı aşağıdakilerden hangisidir?', 0, 'D', 14, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '35 240', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '35 244', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '35 344', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '35 342', 3, NOW(), false);

    RAISE NOTICE 'Test 1 eklendi: 14 soru';

    -- =====================================================
    -- TEST 2: Doğal Sayılarla Toplama - Test 2
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Doğal Sayılarla Toplama - Test 2', 2, 2, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Aşağıdaki toplama işlemlerinden hangisinin sonucu yanlıştır?', 0, 'C', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '3 5 1 6 + 2 5 6 9 6 0 8 5', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '4 2 3 6 + 1 5 9 6 5 8 3 2', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '3 6 7 4 + 2 4 8 6 6 0 6 0', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '5 2 6 3 + 1 4 2 3 6 6 8 6', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '1 3 2 4 4354 + 3924 2523 + 5474 1281 + 6007 3458 + 3900 Yukarıdaki tırtıllardan hangisinin toplamı 8000’e yuvarlanır?', 0, 'A', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '2', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '3', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '4', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '"(5 x 100 000)+(7 x 1000)+(6 x 10)+ (3 x 1)" şeklinde çözümlenen sayının 4 basamaklı en küçük doğal sayı ile toplamı kaçtır?', 0, 'B', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '506 600', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '507 063', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '508 063', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '606 061', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Tabloya göre hangi işlemin sonucu en büyüktür?', 0, 'D', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '◆', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '♥', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '●', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '■ 4, 5 ve 6. soruları yukarıdaki işlem­ lere göre cevaplayalım. ◆ 2365 + 1652 ♥ 1568 + 3241 ● 2152 + 2643 ■ 3658 + 1987', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Tabloya göre sonucu en küçük olan işlemin en yakın yüzlüğe yuvarlan mış hâli aşağıdakilerden hangisidir?', 0, 'A', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '4000', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '4100', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '4200', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '4300', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Tablodaki işlemlerin sonuçlarını büyükten küçüğe doğru sıralarsak hangisi doğru olur?', 0, 'B', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '♥ > ■ > ◆ > ●', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '■ > ♥ > ● > ◆', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '■ > ● > ♥ > ◆', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '♥ > ■ > ● > ◆ 4 kitap&kitap', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '1460 - 1560 - - - 1860 Yukarıdaki sayı örüntüsünde ve yerine gelecek sayıların toplamı kaçtır?', 0, 'D', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '3320', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '4320', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '4420', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '3420', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Dört basamaklı en büyük doğal sayı, üç basamaklı en küçük doğal sayı dan kaç fazladır?', 0, 'C', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '9800', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '9898', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '9899', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '9900', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '5642 + 3054 Yukarıdaki toplama işleminde ceva bın onlar basamağında hangi rakam vardır?', 0, 'D', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '6', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '8', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '6', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '9', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '3561 + 6852 Yukarıdaki toplama işleminin sonu cunun birler bölüğünde aşağıdaki lerden hangisi bulunur?', 0, 'B', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '104', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '413', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '10', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '10 413', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Binler, yüzler ve birler basamağında 8 bulunan dört basamaklı en büyük doğal sayının 814 fazlası kaçtır?', 0, 'D', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '10 712', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '10 512', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '9912', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '9712', 3, NOW(), false);

    -- Soru 12
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '7425 + 3256 3652 + 4986 5986 + 4108 8638 10 681 10 094 Yukarıdaki çıkarma işlemleri cevap larıyla eşleştirdiğimizde sonuç nasıl olur?', 0, 'D', 12, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 13
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '8, 1, 3, 0 rakamlarını kullanarak yazı labilecek dört basamaklı en büyük ve en küçük sayıların toplamı kaçtır?', 0, 'A', 13, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '9348', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '9510', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '9186', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '9386', 3, NOW(), false);

    -- Soru 14
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '589 624 Yukarıdaki sayının birler bölüğü ile binler bölüğündeki sayıların toplamı kaçtır?', 0, 'C', 14, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1013', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '5833', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '1213', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '9682', 3, NOW(), false);

    RAISE NOTICE 'Test 2 eklendi: 14 soru';

    -- =====================================================
    -- TEST 3: Doğal Sayılarla Çıkarma - Test 3
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Doğal Sayılarla Çıkarma - Test 3', 3, 3, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Aşağıdaki işlemlerden hangisi yan lıştır?', 0, 'C', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '5 4 0 2 – 2 8 0 3 2 5 9 9', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '7 6 3 5 – 7 8 5 6 8 5 0', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '6 3 2 1 – 3 4 0 5 2 9 2 6', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '3 0 0 7 – 1 0 2 5 1 9 8 2', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Abaküste gösterilen sayıdan 895 çıkarırsak sonuç kaç olur?', 0, 'C', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '5847', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '5853', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '5147', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '6147 6 kitap&kitap', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '✮ 3480 – 2420 = 1060 ✮ 9403 – 2015 = 7388 ✮ 6000 – 2982 = 3098 ✮ 5080 – 125 = 4955 Yukarıdaki işlemlerden hangisinin sonucu yanlıştır?', 0, 'A', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '✮', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '✮', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '✮', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '✮', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '◆ 3000 - 1532 = ♥ 3250 - 2345 = ● 3500 - 2456 = Yukarıdaki çıkarma işlemlerinin sonuçlarını küçükten büyüğe doğru sıralarsak sonuç hangisi olur?', 0, 'C', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '♥ < ◆ < ●', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '◆ < ♥ < ●', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '♥ < ● < ◆', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '● < ◆ < ♥', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '6000 - 2683 6152 - 2896 5600 - 1840 3256 3317 3760 Yukarıdaki çıkarma işlemlerini fark larıyla eşleştirdiğimizde sonuç nasıl olur?', 0, 'B', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '5 Adı - Soyadı: ...........................................................................................    Sınıfı - Numarası: ................................................. DOĞAL SAYILARLA ÇIKARMA İŞLEMİ', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '▲ 5463 - 2890 = ★ 6069 - 3410 = ❀ 5549 - 3015 = ■ 6740 - 3640 = Yukarıdaki çıkarma işlemlerinden hangisinin sonucunu en yakın yüz lüğe yuvarladığımızda sonuç 2500 olur?', 0, 'D', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '▲', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '★', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '■', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '❀', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '4385 - 1998 = 2387 5000 - 1305 = 3695 3230 - 1835 = 1405 Yukarıdaki işlemlerin sonuçları doğru ise D, yanlış ise Y yazdığı mızda sonuç aşağıdakilerden hangisi gibi olur?', 0, 'A', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, 'D D Y', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, 'D Y D', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'D Y Y', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Y D D', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '3850 - 3950 - - 4150 - Yukarıdaki sayı örüntüsünde ve yerine gelecek sayıların farkı kaçtır?', 0, 'C', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '100', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '150', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '200', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '250', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '9, 0, 5, 3 rakamlarını kullanarak yazılabilecek 4 basamaklı en büyük ve en küçük sayıların farkı kaçtır?', 0, 'B', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '5471', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '6471', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '5479', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '6571', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '◆ 900 - 10 = 890 ♥ 800 - 100 = 600 ● 900 - 50 = 850 ■ 700 - 300 = 400 Yukarıdaki zihinden çıkarma işlem lerinden hangisi yanlıştır?', 0, 'B', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '◆', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '♥', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '■', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '●', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '400 - 20 300 - 70 500 - 80 230 420 380 Yukarıdaki işlemleri zihinden yapa rak sonuçlarıyla eşleştirdiğimizde cevap hangisi gibi olur?', 0, 'B', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    RAISE NOTICE 'Test 3 eklendi: 11 soru';

    -- =====================================================
    -- TEST 4: Doğal Sayılarla Toplama - Test 4
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Doğal Sayılarla Toplama - Test 4', 4, 4, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '1200 + 200 1500 + 400 1300 + 300 1600 1900 1400 Yukarıdaki toplama işlemlerini zihin den yaparak sonuçlarıyla eşleştirdi ğimizde cevap hangisi gibi olur?', 0, 'D', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'gün 3625 kilo fındık, 3. gün ise 3278 kilo fındık gelmiştir. Üç günde toplam kaç kilo fındık gelmiştir?', 0, 'D', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '9703', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '9803', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '9800', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '8803', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '1280 + 250 Yukarıdaki toplama işlemini tahmi nen yaparsak sonuç aşağıdakilerden hangisi olur?', 0, 'C', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1400', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '1500', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '1600', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '1700 7 Adı - Soyadı: ...........................................................................................    Sınıfı - Numarası: ................................................. DOĞAL SAYILARLA TOPLAMA İŞLEMİ', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '1642 fazlası 3455 olan sayının 550 fazlası kaçtır?', 0, 'B', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1813', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '2363', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '1863', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '2905', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir trende 250 bayan, bayanlardan 102 fazla erkek ve erkeklerden 73 fazla da çocuk yolcu vardır. Bu tren de toplam kaç yolcu vardır?', 0, 'A', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1027', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '937', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '930', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '830 8 kitap&kitap', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir okulda 1437 erkek öğrenci, 1109 tane de kız öğrenci vardır. Bu okulda toplam kaç öğrenci vardır?', 0, 'A', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '2546', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '2646', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '2345', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '2506', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Melike''nin ve Mehmet''in yaşları top lamı 49''dur. Mehmet, 38 yaşında olduğuna göre 10 yıl sonra Melike’nin yaşı kaç olur?', 0, 'A', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '21', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '28', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '31', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '38', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Ablam ve ağabeyim para biriktirerek bisiklet aldılar. Ablam 785 TL, ağa beyim ise 823 TL verdi. Buna göre bisikletin fiyatı kaç TL''dir?', 0, 'B', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1508', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '1608', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '1600', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '1618', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Rakamları birbirinden farklı dört basa maklı en küçük sayının 1289 fazlası kaçtır?', 0, 'C', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '2200', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '2519', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '2312', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '2523', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir limana 1. gün 2900 kilo fındık,', 0, 'B', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Emre her gün bir önceki günden 700 metre fazla yürüyerek 3 gün yürüyüş yapmıştır. İlk gün 500 metre yürüdüğüne göre üç günün sonunda toplam kaç metre yürümüş olur?', 0, 'A', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '3600', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '3000', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '2400', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '1900', 3, NOW(), false);

    -- Soru 12
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir çiftlikte 255 koyun, koyunlardan 127 fazla tavuk ve 135 tane de inek vardır. Bu çiftlikte toplam kaç tane hayvan vardır?', 0, 'B', 12, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '637', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '772', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '780', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '517', 3, NOW(), false);

    -- Soru 13
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Her biri diğerinden 285 fazla olan üç sayının en küçüğü 95 olduğuna göre bu sayıların toplamı kaçtır?', 0, 'D', 13, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '380', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '665', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '1045', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '1140', 3, NOW(), false);

    RAISE NOTICE 'Test 4 eklendi: 13 soru';

    -- =====================================================
    -- TEST 5: Doğal Sayılarla Çıkarma - Test 5
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Doğal Sayılarla Çıkarma - Test 5', 5, 5, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '3270 - 150 Yukarıdaki çıkarma işlemini tahmi nen yaparsak sonuç aşağıdakilerden hangisi olur?', 0, 'C', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '3000', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '3150', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '3100', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '3200', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '830 - 120 680 - 190 750 - 150 600 700 500 Yukarıdaki çıkarma işlemlerini tah minen yapıp sonuçlarıyla eşleştirdi ğimizde cevap hangisi olur?', 0, 'C', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'kitap 142 silgi 98 kalem 223 defter 189 çanta 54 cetvel 102 Yukarıda­ki tab­lo­da bir kır­ta­si­ye­de bu­lu­nan eş­ya­la­rın tür­le­ri sa­yı­la­rı­na gö­re be­lir­til­miş­tir. 3 ve 4. so­ru­ları tab­lo­ya gö­re ce­vap­la­yı­nız.', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Kırtasiyede sayısı en fazla olan ürün, en az olan üründen kaç fazla dır?', 0, 'C', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '277', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '189', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '169', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '156', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Kırtasiyeye kaç çanta alınırsa çanta ların sayısı, kitapların sayısından 14 eksik olur?', 0, 'D', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '179', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '156', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '128', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '74 10 kitap&kitap', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Melih 2008 yılında 19 yaşındaydı. Melih kaç yılında doğmuştur?', 0, 'B', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1998', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '1989', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '1986', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '1899', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir ekmek fabrikasında bir günde üretilen 4800 ekmeğin sabah 3125 tanesi öğleden sonra ise kalan ekmekler satılmıştır. Öğleden sonra kaç ekmek satılmıştır?', 0, 'C', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1500', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '1565', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '1675', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '1685', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'İki doğal sayının farkı 15 600''dür. Eksilene 400 ekleyip çıkanı 200 eksiltirsek yeni fark kaç olur?', 0, 'A', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '16 200', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '15 400', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '15 200', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '15 000', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '"(820 – 120) + (560 – 263)" işlemi nin sonucu kaçtır?', 0, 'B', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '998', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '997', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '996', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '897', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '3780 TL''ye aldığımız televizyonun 1895 TL''sini ödedik. Kalan borcumuz kaç TL''dir?', 0, 'A', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1885', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '2885', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '2880', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '1880', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '2018 yılında Atatürk''ün vefatının kaçıncı yıl dönümünü saygıyla andık?', 0, 'C', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '78', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '79', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '80', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '81', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Babamın maaşı 3200 TL''dir Babam 1450 TL kira ve 780 TL de fatura lara ödemektedir. Babamın maaşın dan kalan para kaç TL''dir?', 0, 'D', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1750', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '1250', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '950', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '970', 3, NOW(), false);

    -- Soru 12
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Ali İstanbul''dan Rize''ye gitmek üzere yola çıktı. İstanbul - Rize arası yol 1142 kilometredir. Ali yolun 565 kilometresini gittiğinde geriye kaç kilometre yol kalır?', 0, 'A', 12, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '577', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '575', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '675', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '715', 3, NOW(), false);

    RAISE NOTICE 'Test 5 eklendi: 12 soru';

    -- =====================================================
    -- TEST 6: Doğal Sayılarla Çarpma - Test 6
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Doğal Sayılarla Çarpma - Test 6', 6, 6, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Yandaki çarpma işleminin sonucu kaçtır?', 0, 'B', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '3500', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '4000', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '4200', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '4300', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '(12 x 10) x 3 = ? Yukarıdaki işlemin sonucu kaçtır?', 0, 'A', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '360  B. 240  C. 120  D. 380', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '◆ 12 x 25 ➙ 12 ÷ 4 = 3 3 x 100 = 300 ♥ 16 x 25 ➙ 16 ÷ 4 = 4 4 x 100 = 400 ■ 28 x 25 ➙ 28 ÷ 4 = 6 6 x 100 = 600 ● 20 x 25 ➙ 20 ÷ 4 = 5 5 x 100 = 500 Yukarıdaki çarpma işlemleri 25 ile kısa yoldan çarpılmıştır. Hangisinin sonucu yanlıştır?', 0, 'C', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '◆', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '♥', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '■', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '●', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '800 x 50 = ? Yukarıdaki çarpma işleminin kısa yoldan doğru yapılışı hangi seçenek te verilmiştir?', 0, 'B', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '800 x 2 = 1600 1600 ÷ 10 = 160', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '800 ÷ 2 = 400 400 x 100 = 40 000', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '800 ÷ 10 = 80 80 x 5 = 400', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '800 ÷ 4 = 200 200 x 10 = 2000', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '89 x 100 250 x 10 180 x 10 2500 8900 1800 Yukarıdaki çarpma işlemlerini zihin den yaparak cevaplarıyla eşleştirdi ğimizde sonuç hangisi gibi olur?', 0, 'B', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '1 2 5 x 3 2 ............... ............... ............... + 12 kitap&kitap', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Aşağıdaki zihinden çarpma işlemle rinden hangisinin sonucu yanlıştır?', 0, 'C', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '32 x 100 = 3200', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '58 x 1000 = 58 000', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '175 x 100 = 1750', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '103 x 100 = 10300', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Mehmet ve ailesi bir haftada 12 ekmek tüketiyor. Buna göre Mehmet ve ailesi bir yıl içinde kaç ekmek tüketirler?', 0, 'D', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1024', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '365', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '462', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '624', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '48 sayısını 5 ile kısa yoldan çarp mak için aşağıdaki işlemlerden han gisi yapılmalıdır?', 0, 'D', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '(48 x 5) ÷ 2  	 B.	 (48 x 5) ÷ 10', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '(48 ÷ 2) x 5  	 D.	 (48 ÷ 2) x 10', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir okulda 12 sınıf, her sınıfta 18 sıra ve her sırada üçer öğrenci oldu ğuna göre bu okulda kaç öğrenci vardır?', 0, 'C', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '815', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '725', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '648', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '512', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '2 basamaklı en büyük doğal sayının 16 katı kaçtır?', 0, 'A', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1584', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '1470', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '1450', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '1284', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Ece 15 yaşındadır. Dedesinin yaşı Ece''nin yaşının 5 katından 4 eksiktir. Ece''nin dedesi kaç yaşındadır?', 0, 'A', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '71', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '75', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '81', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '85', 3, NOW(), false);

    -- Soru 12
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '(16 x 21) + (25 x 34) – (13 x 10) işleminin sonucu kaçtır?', 0, 'B', 12, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '336', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '1056', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '850', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '1186', 3, NOW(), false);

    RAISE NOTICE 'Test 6 eklendi: 12 soru';

    -- =====================================================
    -- TEST 7: Doğal Sayılarla Bölme - Test 7
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Doğal Sayılarla Bölme - Test 7', 7, 7, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '824 ÷ 8 işleminde bölüm kaçtır?', 0, 'C', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '10', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '13', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '103', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '130', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Yanda verilen bölme ....... 23 16 işlemine göre kalan aşağıdakilerden han gisi olamaz?', 0, 'A', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '23', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '22', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '21', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '16', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Yandaki bölme işlemi nin sonucu kaçtır?', 0, 'B', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '250', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '251', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '255', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '300 1255  5 14 kitap&kitap', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Yandaki bölme iş- 456 – 38 0 leminde bölen sayı kaçtır?', 0, 'A', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '12', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '15', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '18', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '22', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '645 5 – Yukarıdaki bölme işleminde bölümün basamak sayısı aşağıdakilerden han gisidir?', 0, 'C', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '2', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '3', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '4', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir bölme işleminde bölen 8, bölüm bölenin 2 katından 5 eksiktir. Kalan sayı ise 6 olduğuna göre bölü nen sayı kaçtır?', 0, 'D', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '86', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '88', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '90', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '94', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'a. 12 500 ÷ 10 = 125 b. 23 000 ÷ 100 = 230 c. 18 300 ÷ 10 = 1830 d. 20 000 ÷ 1000 = 20 Yukarıdaki zihinden bölme işlemle rinden hangisinin sonucu yanlıştır?', 0, 'B', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, 'b', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, 'a', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'd', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'c', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'a x 13 = 58 + 46 Kutudaki işleme göre a kaç olma lıdır?', 0, 'B', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '9', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '8', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '7', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '6', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '30 kg''ı 450 TL olan pirinçten 55 kg alırsam kaç TL ödemem gerekir?', 0, 'D', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '150', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '450', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '725', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '825', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Kalanlı bir bölme işleminde bölen 23, bölüm 18 ise bölünen sayı en fazla kaç olabilir?', 0, 'C', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '414', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '424', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '436', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '450', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '60 x 8 = 4800 ÷ 10 2500 ÷ 100 = 100 ÷ 4 25 x 6 = 1500 ÷ 100 7000 ÷ 10 = 2800 ÷ 4 Tahtadaki her doğru işlem için 10 puan alan Özge''nin kaç puanı olmuş tur?', 0, 'C', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '10', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '20', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '30', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '40', 3, NOW(), false);

    -- Soru 12
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Her gün kitabından eşit sayfa oku yan Ece 126 sayfalık kitabı 6 günde bitirmiştir. Ece günde kaç sayfa kitap okumuş tur?', 0, 'D', 12, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '18', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '. 19', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '20', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '21', 3, NOW(), false);

    -- Soru 13
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Yandaki kalanlı bölme işlemi için aşağıdaki ifadelerden hangisi yanlıştır?', 0, 'D', 13, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '14 –       32 B', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, 'A en az 448 olur.', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'A en çok 461 olur.', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'A en faz­la 462 olur.', 3, NOW(), false);

    -- Soru 14
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir bahçenin çevresine 4 sıra tel çekilerek 956 metre tel kullanılmıştır. Bahçenin çevresi kaç metredir?', 0, 'A', 14, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '239', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '259', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '219', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '248', 3, NOW(), false);

    -- Soru 15
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir okuldaki 5 sınıfta toplam 190 öğrenci vardır. Geriye kalan 9 sını fın her birinde öğrenci sayısı eşittir. Bu okulda 514 öğrenci olduğuna göre 9 sınıfın her birinde kaçar öğrenci vardır?', 0, 'C', 15, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '38', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '37', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '36', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '35', 3, NOW(), false);

    RAISE NOTICE 'Test 7 eklendi: 15 soru';

    -- =====================================================
    -- TEST 8: Dört İşlem Problemleri - Test 8
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Dört İşlem Problemleri - Test 8', 8, 8, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir çiftlikteki ineklerin ve tavukların ayak sayıları toplamı 428''dir. Tavukların sayısı 78 olduğuna göre ineklerin sayısı kaçtır?', 0, 'C', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '56', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '64', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '68', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '70', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir sinema salonunda 128 erkek seyirci, erkeklerden 35 fazla bayan seyirci vardır. Sinema salonunda toplam kaç seyirci vardır?', 0, 'D', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '163', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '237', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '280', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '291', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Tanesi 3 TL olan çikolatadan 18 tane alan Sinan satıcıya 100 TL verdi. Para üstü kaç TL alır?', 0, 'C', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '54', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '50', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '46', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '45', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir çiftçi ürettiği 2820 kilo patatesi 5 kiloluk poşetlere koyacaktır. Bunun için kaç tane poşete ihtiyacı vardır?', 0, 'B', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '504', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '564', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '575', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '664 16 kitap&kitap', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'İstanbul - Antalya arası 696 kilo metredir. İki şehir arasını 8 saatte giden bir otomobilin saatteki hızı kaç kilomet redir?', 0, 'A', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '87', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '89', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '90', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '92', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Babam ayda 180 TL ödemek üzere 9 taksitle bir bilgisayar aldı. Bugüne kadar 5 taksitini ödediğine göre geriye ödenecek kaç TL kalmış tır?', 0, 'A', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '720', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '900', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '1250', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '1620', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Üç basamaklı en büyük sayının 2 katının 350 eksiği kaçtır?', 0, 'B', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1450', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '1648', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '1998', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '2000', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir trendeki 308 yolcunun 129''u erkek, 98''i bayan geri kalanlar çocuktur. Trende kaç tane çocuk yolcu vardır?', 0, 'C', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '78', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '79', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '81', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '85', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Ali''nin harçlığının yarısının 5 TL fazlası 25 TL''dir. Ali harçlığının 15 lirasıyla annesine bir demet gül aldı. Ali''nin geriye kaç lirası kalır?', 0, 'C', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '35', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '30', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '25', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '15', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Zeynep 18 tane armut ağacının her birinden yirmi beşer kilo armut top ladı. Bu armutları onar kiloluk kasalara koymak isterse kaç kasaya ihtiyaç duyar?', 0, 'D', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '25', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '30', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '35', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '45', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Hasan bir saatte 120 tane soru çözüyor. Hasan''ın 3 saatte çözdü ğü soruları Ayla 4 saatte çözüyor. Ayla bir saatte kaç soru çözmüştür?', 0, 'A', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '90', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '110', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '120', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '130', 3, NOW(), false);

    -- Soru 12
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Sena kırtasiyeden 3 tane defter aldı. Kırtasiyeciye 100 TL verdi. Para üstü 34 TL aldığına göre bir defterin fiyatı kaç TL''dir?', 0, 'B', 12, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '20', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '22', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '23', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '24', 3, NOW(), false);

    -- Soru 13
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir haftada 91 TL biriktiren bir öğrenci 702 TL''yi kaç günde birikti rir?', 0, 'A', 13, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '54', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '45', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '43', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '42', 3, NOW(), false);

    -- Soru 14
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Üç doğal sayının toplamı 2385''tir. Birinci sayı üç basamaklı en küçük sayı, ikinci sayı ise üç basamak lı rakamları birbirinden farklı en büyük sayıdır. Bu işlemde üçüncü sayı kaçtır?', 0, 'C', 14, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '987', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '1087', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '1298', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '1287', 3, NOW(), false);

    RAISE NOTICE 'Test 8 eklendi: 14 soru';

    -- =====================================================
    -- TEST 9: Kesirler - Test 9
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Kesirler - Test 9', 9, 9, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '[Test 9 - Soru 1 - Görsel soru]', 0, 'D', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '[Test 9 - Soru 2 - Görsel soru]', 0, 'D', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '[Test 9 - Soru 3 - Görsel soru]', 0, 'D', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '3 9 3 7 3 8 3 6 Üzerinde en büyük kesir yazan kap lumbağa yarışı kazanmıştır. Buna göre hangi kaplumbağa yarışı kazanmıştır?', 0, 'C', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '2', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '3', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '4', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'A B Yandaki A ve', 0, 'A', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1 5', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '1 10', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '2 5', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '3 10 18 kitap&kitap', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '▲ 2 7 < 3 7 < 4 7 5 7 < 6 7 < ▲ 6 7 < 4 7 < 5 7 3 7 < 2 7 < ▲ 6 7 < 5 7 < 4 7 3 7 < 2 7 < ▲ 2 7 < 3 7 < 5 7 4 7 < 6 7 < 3 7 < 6 7 < 5 7 2 7 < 4 7 < Yukarıdaki kesirlerin küçükten büyü ğe doğru sıralanışı aşağıdakilerden hangisidir?', 0, 'B', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '▲', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '▲', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '▲', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '▲', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'b + 6 12 kesri basit bir kesirdir. "b" nin alabileceği en büyük değer aşağıdakilerden hangisidir?', 0, 'A', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '5', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '6', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '7', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '8', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '13 18 A 13 15 A 13 12 S 13 20 T 13 16 K Yukarıdaki kesirleri küçükten büyü ğe sıraladığımızda oluşan kelime hangisi olur?', 0, 'B', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, 'SAKAT', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, 'TAKAS', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'KATAS', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'KASAT', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '4 8 7 8 3 2 < 4 5 < 2 5 17 8 < 12 8 3 5 2 < 10 5 ★ ★ ★ ★ Yukarıdakilerden hangisi doğrudur?', 0, 'D', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '★', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '★', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '★', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '★', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Aşağıdaki kesirlerden hangisi diğer lerinden daha küçüktür?', 0, 'A', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1 3 1', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '12 3', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '2 3 2', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '15 3', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '[Test 9 - Soru 11 - Görsel soru]', 0, 'D', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    RAISE NOTICE 'Test 9 eklendi: 11 soru';

    -- =====================================================
    -- TEST 10: Kesirlerle İşlemler - Test 10
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Kesirlerle İşlemler - Test 10', 10, 10, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '2 5 + 1 5 + 2 5 İşleminin sonucu aşağıdakilerden hangisi ile ifade edilebilir?', 0, 'B', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '2 8 + 3 8 - 1 8 İşleminin sonucu kaçtır?', 0, 'A', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '4 8', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '3 8', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '2 8', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '1 8', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '8 düzine kalemin 1 4 ''ini arkadaş- larıma verdim. Kaç tane kalemim kaldı?', 0, 'B', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '96', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '72', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '48', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '36', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir manav sebzelerin önce 2 9''sini, sonra 4 9''ünü sattı. Manav sebzelerin kaçta kaçını sattı?', 0, 'C', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '3 9', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '5 9', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '6 9', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '8 9', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir kasa kayısının önce 3 16''ünü, son ra da 5 16 ''ini tükettik. Geriye toplam kayısı miktarının kaçta kaçı kalmıştır?', 0, 'A', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '8 16', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '7 16', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '5 16', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '9 16', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '‘si ile de çanta ald›m. 2 7 350 TL paranın ‘ü ile ayakkabı aldım. 3 7 Ayça kaç TL harcamıştır?', 0, 'C', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '100', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '210', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '250', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '310 20 kitap&kitap', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir otobüs gideceği yolun önce 2 15 ''si ni, sonra da 7 15 ''sini gitmiştir. Geriye yolun kaçta kaçı kalmıştır?', 0, 'D', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '9 15', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '10 15', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '8 15', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '6 15', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '7 20 + 3 20 + 13 20 İşleminin sonucu kaçtır?', 0, 'D', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '48 10', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '34 8', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '43 40', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '23 20', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Kaç tane 1 12 ''i toplarsak 1 elde ede riz?', 0, 'C', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '9', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '10', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '12', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '13', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '400 sayfalık kitabın ‘ini okudum. 1 8 Seçil''in geriye okuyacağı kaç sayfası kalmıştır?', 0, 'A', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '350  B. 300  C. 250  D. 150', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '2 7 + ❒ 7 + = 1 7 6 7 İşleminde ❒ yerine hangi sayı yazıl malıdır?', 0, 'C', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '7', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '4', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '3', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '2', 3, NOW(), false);

    -- Soru 12
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '4 2 4 1 4 4 4 2 ? + + - = c c m m İşleminin sonucu kaçtır?', 0, 'B', 12, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '4 4', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '5 4', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '3 4', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '2 4', 3, NOW(), false);

    -- Soru 13
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '16 deste kalemin 1 8 ''ini kullandım. Geriye kaç kalemim kaldı?', 0, 'A', 13, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '140', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '120', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '100', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '80', 3, NOW(), false);

    -- Soru 14
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '16 5 - A', 0, 'C', 14, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '13', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '16', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '17', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '19', 3, NOW(), false);

    RAISE NOTICE 'Test 10 eklendi: 14 soru';

    -- =====================================================
    -- TEST 11: Zamanı Ölçme - Test 11
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Zamanı Ölçme - Test 11', 10, 11, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '14 400 saniye kaç dakikadır?', 0, 'A', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '240', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '60', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '40', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '4', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '48 hafta kaç gün eder?', 0, 'B', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '230', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '336', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '250', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '330', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Aşağıdaki dönüşümlerden hangisi yanlıştır?', 0, 'D', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '3 sa­at 42 da­ki­ka = 222 da­ki­ka', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '10 da­ki­ka 21 sa­ni­ye = 621 sa­ni­ ye', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '192 sa­ni­ye = 3 da­ki­ka 12 sa­ni­ye', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '10 sa­at 10 da­ki­ka = 610 sa­ni­ye', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Yarım gün kaç saniye eder?', 0, 'A', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '43 200', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '720', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '18 000', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '2540', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '[Test 11 - Soru 5 - Görsel soru]', 0, 'A', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '840 saat kaç gün eder?', 0, 'C', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '42', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '40', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '35', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '32', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '12.2019 yılında kaç yıl, kaç ay ve kaç günlük olur?', 0, 'A', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '24 yıl, 9 ay, 19 gün', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '15 yıl, 10 ay, 11 gün', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '18 yıl, 5 ay, 19 gün', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '17 yıl, 11 ay, 11 gün', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '3 ay 2 hafta 17 gün kaç gün eder? (1 ay = 30 gün)', 0, 'C', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '90', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '105', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '121', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '130 22 kitap&kitap', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Günün 1 4 ’ini spor yaparak geçiren bir kişinin geriye kaç saatlik zamanı kalır?', 0, 'A', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '18', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '20', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '22', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '24', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '03.50''yi gösteren saat 20 dakika sonra kaçı gösterir?', 0, 'C', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '04.00', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '04.05', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '04.10', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '04.20', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '4200 dakika kaç saat eder?', 0, 'C', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '600', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '80', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '70', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '60', 3, NOW(), false);

    -- Soru 12
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '7 yarım 5 çeyrek saat kaç dakika dır?', 0, 'B', 12, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '300', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '285', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '185', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '125', 3, NOW(), false);

    -- Soru 13
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '8 saatin ''i kaç dakika eder? 1 4 Öğretmenin sorduğu soruyu hangi öğrenci doğru cevaplamıştır?', 0, 'A', 13, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '120', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '150', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '240', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '220', 3, NOW(), false);

    -- Soru 14
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Günde 9 saat çalışan bir işçi 2 ayda kaç saat çalışmış olur? (1 ay 30 gün)', 0, 'D', 14, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '140', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '270', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '340', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '540', 3, NOW(), false);

    -- Soru 15
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '20''ye kadar sürmüştür. Ahmet kaç dakika yolculuk yapmış tır?', 0, 'C', 15, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '280', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '320', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '350', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '360', 3, NOW(), false);

    -- Soru 16
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir günün 2 6 ''si kaç saat eder?', 0, 'D', 16, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '4', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '5', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '7', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '8', 3, NOW(), false);

    RAISE NOTICE 'Test 11 eklendi: 16 soru';

    -- =====================================================
    -- TEST 12: Veri Toplama ve Değerlendirme - Test 12
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Veri Toplama ve Değerlendirme - Test 12', 10, 12, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'En az üretilen ürün hangisidir?', 0, 'B', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, 'Haşhaş', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Mısır', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Ay­çi­çe­ği', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Ar­pa', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Eşit miktarda üretilen ürünler han gileridir?', 0, 'D', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, 'Buğ­day – Ar­pa', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Ar­pa – Mı­sır', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Buğ­day – Ay­çi­çe­ği', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Ar­pa – Haşhaş', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Üretilen buğday ve arpa toplam kaç tondur?', 0, 'A', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '18', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '16', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '14', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '12', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Üretilen haşhaş ve buğday, mısır ve ayçiçeğinden kaç ton fazladır?', 0, 'A', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '8', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '6', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '7', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '5 Miktar(kg) doma- tes biber pat- lıcan salatal›k 250 200 150 100 balkabağı Yu­ka­rıda­ki sü­tun gra­fi­ğin­de bir seb­ ze bah­çe­sin­de yetiştirilen ürün­ler ve mik­tar­la­rı ve­ril­miştir. (5, 6, 7, ve 8. so­ru­la­rı gra­fi­ğe gö­re cevaplayınız.)', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Sebze bahçesinde eşit miktarda yetiştirilen ürünler hangileridir?', 0, 'A', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '–', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '–', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '–', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '– 24 kitap&kitap Zaman (saat) 8 7 6 5 4 3 2 1 0 Pzt. Sal. Çrﬂ. Prﬂ. Cm. Cmt. Pz. Günler Yukarıda­ki gra­fik­te Es­ra''nın bir haf­ ta­lık ders ça­lış­ma planı ve­ri­lmiş­tir. (9, 10, 11, ve 12. so­ru­la­rı grafiğe gö­re ce­vap­la­yınız.)', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Grafiğe göre en az üretilen ürün hangisidir?', 0, 'D', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Sebze bahçesinde en fazla üretilen ürün hangisidir?', 0, 'B', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Üretilen balkabaklarının ve biberle rin toplamı kaç kg''dır?', 0, 'A', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '450  B. 400  C. 350  D. 200', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Esra en fazla hangi gün ders çalış mıştır?', 0, 'D', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, 'Sa­lı', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Pa­zar', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Cu­ma', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Perşem­be', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Esra hafta sonu kaç saat ders çalış mıştır?', 0, 'C', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '8', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '10', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '11', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '12', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'En fazla çalıştığı gün, en az çalıştığı günden kaç saat fazladır?', 0, 'A', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '6', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '4', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '3', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '2', 3, NOW(), false);

    -- Soru 12
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Esra hangi günler eşit saatte ders çalışmıştır?', 0, 'C', 12, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, 'Sa­lı – Çar­şam­ba', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Per­şem­be – Çar­şam­ba', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Pa­zar­te­si – Pa­zar', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Cu­mar­te­si – Pa­zar Öğrenci Sayısı 4-A 20 18 16 4-B 4-C ﬁubeler Erkek K›z Yu­ka­rıda­ki sü­tun gra­fi­ğin­de bir oku­ lun 4. sınıf şu­be­le­rin­de­ki kız ve er­kek öğ­ren­ci­le­rin da­ğılım­la­rı ve­ril­miştir. (13, 14, 15, ve 16. so­ru­la­rı gra­fi­ğe gö­re cevaplayınız.)', 3, NOW(), false);

    -- Soru 13
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '4. sınıf şubelerinde toplam kaç erkek öğrenci vardır?', 0, 'D', 13, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '25', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '32', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '36', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '56', 3, NOW(), false);

    -- Soru 14
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '4. sınıf şubelerinde toplam kaç kız öğrenci vardır?', 0, 'B', 14, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '45', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '52', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '56', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '60', 3, NOW(), false);

    -- Soru 15
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '4-A ve 4-B''deki toplam kız öğrenci sayısı, 4-C''deki kız öğrenci sayısın dan kaç fazladır?', 0, 'D', 15, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '10', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '12', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '16', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '20', 3, NOW(), false);

    -- Soru 16
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '4-B ve 4-C''deki toplam erkek öğren ci sayısı, 4-A''daki kız öğrenci sayı sından kaç fazladır?', 0, 'B', 16, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '20', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '22', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '25', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '27', 3, NOW(), false);

    RAISE NOTICE 'Test 12 eklendi: 16 soru';

    -- =====================================================
    -- TEST 13: Geometri - Test 13
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Geometri - Test 13', 10, 13, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Aşağıdakilerden hangisi karenin özelliklerinden değildir?', 0, 'D', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, 'Dört ke­narı var­dır.', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Dört köşesi vardır.', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Ke­nar uzun­luk­la­rı bir­bi­ri­ne eşit­ tir.', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Bütün kenarları birbirlerine dik değildir.', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'İkizkenar üçgen Eşkenar üçgen Çeşitkenar üçgen Yukarıdaki üçgenleri kenar özellikle rine göre çeşitleriyle eşleştirdiğimiz de sonuç hangisi gibi olur?', 0, 'C', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '3 cm 3 cm 3 cm 3 cm 3 cm 3 cm 4 cm 1 cm 2 cm', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'P T R S Yukarıdaki kareyi isimlendirirsek hangisi yanlış olur?', 0, 'B', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, 'PRST karesi', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, 'TRPS karesi', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'STPR karesi', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'RSTP karesi', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Aşağıdaki yapılardan hangisi 10 eş küple oluşturulmamıştır?', 0, 'C', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Yukarıdaki yapıda kaç tane eş küp kullanılmıştır?', 0, 'A', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '12', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '10', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '9', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '8 26 kitap&kitap', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Aşağıdaki düzlemsel şekillerden hangisi simetriktir?', 0, 'A', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Aşağıdaki sayılardan hangisi simet rik değildir?', 0, 'C', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '83', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '30', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '96', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '80', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Yukarıdaki şeklin simetri doğrusuna göre simetriği aşağıdakilerden han gisidir?', 0, 'D', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'A D B C Aşağıdakilerden hangisi yukarıdaki şeklin özelliklerinden değildir?', 0, 'B', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, 'Köşeleri büyük harflerle adlandı­ rılır.', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Uzun kenarı kısa kenarının her zaman iki katı uzunluğundadır.', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Karşılıklı kenar uzunlukları birbi­ rine eşittir.', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Dört kenarı vardır.', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Aşağıdakilerden hangisi verilen doğ ruya göre simetrik değildir?', 0, 'D', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Aşağıdaki kelimelerden hangisinde kullanılan tüm harfler simetriktir?', 0, 'C', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, 'IRMAK', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, 'DAĞ', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'OVA', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'NEHİR', 3, NOW(), false);

    RAISE NOTICE 'Test 13 eklendi: 11 soru';

    -- =====================================================
    -- TEST 14: Geometride Temel Kavramlar - Test 14
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Geometride Temel Kavramlar - Test 14', 10, 14, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Aşağıdaki şekillerden hangisinin yüzeyi düzleme örnek olamaz?', 0, 'B', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Aşağıdakilerden hangisi bir açı belir tir?', 0, 'C', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Yukarıdaki açılar sırasıyla hangisi dir?', 0, 'C', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, 'ge­niş, dik, doğ­ru, dar', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, 'dar, dik, ge­niş, doğ­ru', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'doğ­ru, dik, ge­niş, dar', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'dik, doğ­ru, ge­niş, dar', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '◆ Açı ölçmeye yarayan aracın adı iletkidir. ■ Aynı ölçüye sahip açıların duruş larındaki farklılık açının ölçüsünü değiştirmez. ♥ Açıları büyük harfle isimlendirir ve (^) sembolüyle gösteririz. ● 90°den büyük açılar dik açıdır. Yukarıdaki bilgilerden hangisi yan lıştır?', 0, 'D', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '◆', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '■', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '♥', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '●', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Şekildeki geniş, dik ve dar açıla rın sayıları sıra sıyla hangi seçe nekte verilmiştir? Geniş Dik Dar Açı Açı Açı', 0, 'A', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '3 2 4', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '4 2 3', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '3 4 2', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '2 3 4 28 kitap&kitap', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Yandaki şekilde hangi harf açının köşesini göstermek tedir?', 0, 'C', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, 'D', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, 'C', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'B', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'A •D C A B•', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Şekilde kaç tane dik açı bulunmakta dır?', 0, 'A', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '4', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '3', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '2', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '1', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Şekilde kaç tane geniş açı bulunmak tadır?', 0, 'A', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '3', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '4', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '5', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '6', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Şekilde kaç tane dar açı bulunmak tadır?', 0, 'D', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '3', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '4', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '5', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '6', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Yukarıdaki resimde kaç tane geniş açı vardır?', 0, 'A', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '2', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '3', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '4', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '5', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'B Yukarıdaki ëB açısının ölçüsü kaç derecedir?', 0, 'C', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '140° 	B.	50° 	 C.	40° 	 D.	180°', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 12
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Aşağıdaki şekillerden hangisinin tüm açıları dar açılıdır?', 0, 'B', 12, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '(7, 8 ve 9. so­ru­la­rı yu­ka­rı­da­ki şek­le gö­re ce­vap­la­yınız.)', 3, NOW(), false);

    RAISE NOTICE 'Test 14 eklendi: 12 soru';

    -- =====================================================
    -- TEST 15: Uzunluk Ölçme - Test 15
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Uzunluk Ölçme - Test 15', 10, 15, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Zımba telinin uzunluğu 15 m Kurşun kale- min uzunluğu 1 cm Bir apartma- nın uzunluğu 15 cm Yukarıdaki uzunlukları eşleştirdiği mizde sonuç hangisi gibi olur?', 0, 'A', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '◆ 2400 mm = 2400 cm = 24 m ● 5 m = 500 cm = 5000 mm ■ 70 000 m = 7 km ♥ 9 km = 9000 m Yukarıdaki dönüşümlerden hangisi yanlıştır?', 0, 'C', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '◆', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '♥', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '■', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '●', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '5 cm = 50 mm 120 mm = 12 m 2 m = 200 cm 300 m = 3 km 400 mm = 4 cm 8 km = 8000 m Yukarıdaki tabloda doğru olan dönü şümlerin kutusunu boyadığımızda sonuç hangisi gibi olur?', 0, 'A', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '[Görsel seçenek A]', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir kitabın kalınlığı 2 cm''dir. Kaç kitap üst üste konursa yükseklik 1 metreye ulaşır?', 0, 'D', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '5', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '10', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '25', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '50 30 kitap&kitap', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '28 metrelik bir halat dört eş parça ya ayrılıyor. Her bir parçanın uzunluğu kaç cm olur?', 0, 'B', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '7', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '700', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '17', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '70', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '12 500 metrelik bir yolun 3 kilomet resi asfaltlanmıştır. Geriye asfaltlanmayan kaç metre yol kalmıştır?', 0, 'C', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '8500', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '9000', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '9500', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '10 000', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir araç 135 km''lik bir yolun önce 80 000 metresini daha sonra 13 kilometresini gitti. Kalan yolu kaç km''dir?', 0, 'C', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '30', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '35', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '42', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '53', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir sporcu 3200 metre koşmuştur. Parkurun tamamı 5 km''dir. Parkurun tamamlanması için kaç m daha koşmalıdır?', 0, 'D', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1200', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '1400', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '1500', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '1800', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir adımı 45 cm olan Can okulun koridorunu 80 adımda yürümüştür. Okulun koridorunun uzunluğu kaç metredir?', 0, 'A', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '36', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '38', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '42', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '50', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '150 metre yükseklikteki bir apart man duvarının 1700 cm''si boyandı. Geriye boyanmayan kaç metre duvar kalmıştır?', 0, 'B', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1330', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '133', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '170', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '1350', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Annemin boyu ablamın boyundan 38 cm uzundur. Benim boyum ise ablamın boyundan 15 cm kısadır. Boyum 1 m 23 cm olduğuna göre annemin boyu kaç cm''dir?', 0, 'D', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '138', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '158', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '161', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '176', 3, NOW(), false);

    -- Soru 12
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir terzi 6 metrelik kumaşın önce 2 m 15 cm''sini daha sonra da 1 m 8 cm''sini kullandı. Terzinin geriye kaç cm kumaşı kal mıştır?', 0, 'A', 12, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '277', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '323', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '325', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '377', 3, NOW(), false);

    RAISE NOTICE 'Test 15 eklendi: 12 soru';

    -- =====================================================
    -- TEST 16: Çevre ve Alan Ölçme - Test 16
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Çevre ve Alan Ölçme - Test 16', 10, 16, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Kısa kenarı 40 cm, uzun kenarı 55 cm olan bir dikdörtgenin çevre uzunluğu kaç cm''dir?', 0, 'C', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '120 	 B.	180 	 C.	190 	 D.	200', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Uzun kenarı kısa kenarının 4 katı olan dikdörtgen şeklindeki bir bah çenin kısa kenarı 12 m''dir. Bu bahçenin etrafına 2 sıra tel çek mek için kaç m tel gerekmektedir?', 0, 'A', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '240 	 B.	200 	 C.	120 	 D.	250', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek C]', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Çevresi 60 cm olan bir dikdörtgenin kısa kenarı 10 cm ise uzun kenarı kaç cm’dir?', 0, 'C', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '10', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '15', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '20', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '40', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '10 cm 2 cm 3 cm 4 cm Yukarıdaki düzlemsel şeklin çevresi kaç cm''dir?', 0, 'C', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '78', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '56', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '28', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '19', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '60 m 40 m Yukarıdaki bahçeye bir yüzme havu zu yapılmak isteniyor. Havuzun çevresi aşağıdakilerden hangisi olamaz?', 0, 'D', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '105 m', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '120 m', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '190 m', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '210 m', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Alanı 140 birimkare olan bir dik dörtgenin kısa kenarı 10 birim ise uzun kenarı kaç birimdir?', 0, 'A', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '14', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '12', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '10', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '8 32 kitap&kitap', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Alanı 100 birimkare olan karenin bir kenarının uzunluğu, eş kenar üçgenin bir kenarının uzunluğuna eşittir. Buna göre eşkenar üçgenin çevresi kaç birimdir?', 0, 'D', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '90', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '75', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '60', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '30', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Yukarıdaki boyalı bölgenin alanı kaç birimkaredir?', 0, 'D', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '12', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '14', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '16', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '18', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Yukarıdaki boyalı bölgenin alanının 3 5 ''ü kaç birimkaredir?', 0, 'C', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '10', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '8', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '6', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '4', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Yukarıdaki karelerden bir tanesinin bir kenarı 6 birimkare olduğuna göre büyük dikdörtgenin alanı ne kadardır?', 0, 'B', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '24 birimkare', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '144 birimkare', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '124 birimkare', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '48 birimkare', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Yukarıdaki boyalı şeklin alanı kaç birimkaredir?', 0, 'B', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '17', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '21', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '18', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '24', 3, NOW(), false);

    -- Soru 12
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Kenar uzunlukları 14, 16 ve 18 cm olan bir üçgenin çevresi karenin çevresine eşittir. Karenin bir kenarı kaç cm''dir?', 0, 'A', 12, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '12', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '10', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '14', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '16', 3, NOW(), false);

    RAISE NOTICE 'Test 16 eklendi: 12 soru';

    -- =====================================================
    -- TEST 17: Tartma - Test 17
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Tartma - Test 17', 10, 17, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '3 kg 3000 mg kaç gramdır?', 0, 'A', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '3003', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '3300', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '3030', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '3033', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Aşağıdakilerden hangisi yanlıştır?', 0, 'C', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '3 t = 3000 kg', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '4200 kg = 4 t 200 kg', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '1 t 1 kg = 1000 kg', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '6390 kg = 6 t 390 kg', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'baba anne abla kardeﬂ 21 kg ? 57 kg 84 kg Yukarıdaki ailenin toplam ağırlı ğı 203 kg ise ablanın ağırlığı kaç kg''dır?', 0, 'D', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '35', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '38', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '40', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '41', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '100 gramı 8 TL olan fındığın 250 gramı kaç TL''dir?', 0, 'C', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '12', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '16', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '20 	 D.	18', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek D]', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Markette en fazla hangi ürün bu- lunmaktadır?', 0, 'D', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, 'Pey­nir', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Zey­tin', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Sa­lam', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'De­ter­jan', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Markette bulunan ürünlerin toplamı kaç ton kaç kg''dır?', 0, 'A', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '26 t 500 kg', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '22 t 500 kg', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '15 t 500 kg', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '13 t 500 kg Yan­da­ki tab­ lo­da bir mar­ ket­te bu­lu­ nan ürün­ler ve mik­tar­la­rı ki­log­ram cin­ sin­den ve­ril­ miştir. (5, 6, 7, 8, ve 9. so­ru­la­rı tab­lo­ya gö­re ce­vap­la­yınız.) pey­nir 7500 kg zeytin 3500 kg salam 5000 kg deterjan 8000 kg mercimek 2500 kg 34 kitap&kitap', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Markette bulunan kahvaltı ürünleri nin toplamı kaç tondur?', 0, 'B', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '15', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '16', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '17', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '18', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Markette en az bulunan ürünün miktarı ne kadardır?', 0, 'D', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '8 ton', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '5 ton', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '3500 kg', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '2500 kg', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Markette bulunan deterjan, merci mekten kaç ton kaç kg fazladır?', 0, 'B', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '7 t 500 kg', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '5 t 500 kg', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '4 t 500 kg', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '3 t 500 kg', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '3 kg çilekten 1000 g reçel yapılıyor. 6 kg reçel yapmak için kaç kg çileğe ihtiyacımız vardır?', 0, 'D', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '12', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '14', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '16', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '18', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '? Kek yapmak için 60 kg un aldım. Her kek için 500 g un gerekiyor. Mine Cem Melike Mine Mine, Cem ve Melike problem kur mak istiyorlar. Bu durumda Cem''in konuşma balo nuna ne yazmamız gerekiyor?', 0, 'B', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, 'Kaç kg un ge­rek­mek­te­dir?', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Kaç ta­ne kek ya­pa­bi­li­riz?', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Kaç kg şe­ker ge­rek­mek­te­dir?', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Kaç pa­ket un ge­rek­mek­te­dir?', 3, NOW(), false);

    -- Soru 12
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Tonu 600 TL olan kömürün, 600 kg''ı kaç TL''dir?', 0, 'A', 12, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '360', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '550', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '480', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '790', 3, NOW(), false);

    -- Soru 13
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir günde 250 g zeytin tüketen bir aile, 12 günde kaç kg zeytin tüket mektedir?', 0, 'A', 13, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '3', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '6', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '9', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '10', 3, NOW(), false);

    RAISE NOTICE 'Test 17 eklendi: 13 soru';

    -- =====================================================
    -- TEST 18: Sıvı Ölçme - Test 18
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Sıvı Ölçme - Test 18', 10, 18, 7, true, NOW(), false);

    -- Soru 1
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '❤ 125 ❤ 12 500 ❤ 125 000 ❤ 1250 12,5 l sütün kaç mililitre olduğu hangi renk kalple belirtilmiştir?', 0, 'B', 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '❤', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '❤', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '❤', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '❤', 3, NOW(), false);

    -- Soru 2
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Aşağıdaki ölçülerden hangisi daha küçüktür?', 0, 'A', 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '3 l', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '3700 ml', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '5000 ml', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '5,5 l', 3, NOW(), false);

    -- Soru 3
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '6 l 1 2 19 l l Yukarıdaki kovaya 2 sürahi ve 6 bardak su boşaltıldıktan sonra kovada kaç litrelik boşluk kalmıştır?', 0, 'B', 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '5', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '4', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '3', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '2', 3, NOW(), false);

    -- Soru 4
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '"5 l + 1750 ml + 2250 ml" kaç litre dir?', 0, 'D', 4, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '6', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '7', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '8', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '9', 3, NOW(), false);

    -- Soru 5
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir çiftlikte 10 koyun ve 12 inek vardır. Bir inek bir koyunun 2 katı kadar süt vermektedir. Bir koyun günde 3 l süt verdiğine göre 1 hafta sonunda toplam kaç l süt elde edilir?', 0, 'B', 5, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '600', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '714', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '750', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '800', 3, NOW(), false);

    -- Soru 6
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '1 2 2 4 3 5 1 l 2 l 2 l Yukarıdaki kaplar verilen kesir değerleri kadar suyla doludur. Bu kaplarda toplam kaç ml su var dır?', 0, 'C', 6, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1600', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '2000', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '2700', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '2750 36 kitap&kitap', 3, NOW(), false);

    -- Soru 7
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '"(40 x 100 ml) + (2 x 25 ml)" kaç ml''dir?', 0, 'A', 7, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '4050', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '4150', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '4350', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '4500', 3, NOW(), false);

    -- Soru 8
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir kutuda her biri 25 ml olan 15 adet parfüm bulun maktadır. 3 kutu parfüm alırsam kaç ml parfüm almış olurum?', 0, 'A', 8, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '1125 ml', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '545 ml', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '375 ml', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '125 ml', 3, NOW(), false);

    -- Soru 9
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '4 litrenin 3 5 ''ü ile 1 5 ''inin toplamı kaç mililitredir?', 0, 'A', 9, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '3200', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '3400', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '3600', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '4000', 3, NOW(), false);

    -- Soru 10
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '120 l kolonya, 3000 ml''lik kaç şişe ye doldurulabilir?', 0, 'D', 10, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '4000 B.	400', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '[Görsel seçenek B]', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '80', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '40', 3, NOW(), false);

    -- Soru 11
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '18 l yağın 1 6 ''ini kullandım. Geriye kaç l yağ kalmıştır?', 0, 'B', 11, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '16', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '15', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '13', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '10', 3, NOW(), false);

    -- Soru 12
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '4 l süt alırsam kaç lira öderim? 350 kr.', 0, 'C', 12, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '12', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '13', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '14', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '15', 3, NOW(), false);

    -- Soru 13
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Can 2 günde yarım litre süt içiyor. 24 litre sütü kaç günde içer?', 0, 'B', 13, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '6', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '96', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '12', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '98', 3, NOW(), false);

    -- Soru 14
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '2 litre benzinle 40 km yol giden bir otomobil 240 km yol giderse kaç litre benzin harca mış olur?', 0, 'C', 14, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '6 l', 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '8 l', 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '12 l', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '16 l', 3, NOW(), false);

    RAISE NOTICE 'Test 18 eklendi: 14 soru';

    RAISE NOTICE 'Tüm matematik soruları başarıyla eklendi!';
END $$;