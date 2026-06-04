-- =====================================================
-- MiniBilge - LaTeX Örnek Soru Import Script
-- Sprint 10: LaTeX Matematik Gösterimi Test Soruları
-- Konu: Kesirler, Karekök, Üs, Geometri (3.-4. Sınıf)
-- HasLatex = true olan sorular
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

    -- ADIM 2: Topic - LaTeX Test Soruları
    SELECT "Id" INTO v_topic_id FROM topics WHERE "Name" = 'LaTeX Test Soruları' AND "SubjectId" = v_subject_id AND "IsDeleted" = false LIMIT 1;
    IF v_topic_id IS NULL THEN
        v_topic_id := gen_random_uuid();
        INSERT INTO topics ("Id", "SubjectId", "Name", "Description", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
        VALUES (v_topic_id, v_subject_id, 'LaTeX Test Soruları', 'Kesirler, Karekök, Üs ve Geometri - LaTeX görünüm testi', 99, true, NOW(), false);
    END IF;

    -- =====================================================
    -- LEVEL 1: Kesirler
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Kesirler', 2, 1, 3, true, NOW(), false);

    -- Soru 1: Kesir toplama
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "Explanation", "HasLatex", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '$\frac{3}{4} + \frac{1}{4}$ işleminin sonucu kaçtır?', 0, 'A', '$\frac{3}{4} + \frac{1}{4} = \frac{4}{4} = 1$', true, 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "HasLatex", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '$1$', true, 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '$\frac{3}{8}$', true, 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '$\frac{1}{2}$', true, 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '$2$', true, 3, NOW(), false);

    -- Soru 2: Kesir karşılaştırma
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "Explanation", "HasLatex", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '$\frac{2}{5}$ ile $\frac{3}{10}$ kesirlerinden hangisi büyüktür?', 0, 'A', '$\frac{2}{5} = \frac{4}{10}$, dolayısıyla $\frac{4}{10} > \frac{3}{10}$', true, 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "HasLatex", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '$\frac{2}{5}$', true, 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '$\frac{3}{10}$', true, 1, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Eşittir', false, 2, NOW(), false),
        (gen_random_uuid(), v_question_id, 'Karşılaştırılamaz', false, 3, NOW(), false);

    -- Soru 3: Kesir çıkarma
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "Explanation", "HasLatex", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '$\frac{5}{6} - \frac{1}{6}$ işleminin sonucu nedir?', 0, 'B', '$\frac{5}{6} - \frac{1}{6} = \frac{4}{6} = \frac{2}{3}$', true, 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "HasLatex", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '$\frac{5}{6}$', true, 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '$\frac{2}{3}$', true, 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '$\frac{4}{6}$', true, 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '$\frac{1}{3}$', true, 3, NOW(), false);

    -- =====================================================
    -- LEVEL 2: Karekök ve Üs
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Karekök ve Üs', 3, 2, 3, true, NOW(), false);

    -- Soru 4: Karekök
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "Explanation", "HasLatex", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '$\sqrt{144}$ ifadesinin değeri kaçtır?', 0, 'C', '$\sqrt{144} = 12$, çünkü $12 \times 12 = 144$', true, 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "HasLatex", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '$10$', true, 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '$11$', true, 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '$12$', true, 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '$14$', true, 3, NOW(), false);

    -- Soru 5: Üs alma
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "Explanation", "HasLatex", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '$5^2$ ifadesinin değeri nedir?', 0, 'B', '$5^2 = 5 \times 5 = 25$', true, 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "HasLatex", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '$10$', true, 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '$25$', true, 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '$15$', true, 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '$30$', true, 3, NOW(), false);

    -- Soru 6: Karekök + Üs
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "Explanation", "HasLatex", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, '$\sqrt{36} + 2^3$ işleminin sonucu kaçtır?', 0, 'D', '$\sqrt{36} = 6$ ve $2^3 = 8$, dolayısıyla $6 + 8 = 14$', true, 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "HasLatex", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '$10$', true, 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '$12$', true, 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '$18$', true, 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '$14$', true, 3, NOW(), false);

    -- =====================================================
    -- LEVEL 3: Geometri (Açılar)
    -- =====================================================
    v_level_id := gen_random_uuid();
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_level_id, v_topic_id, 'Geometri - Açılar', 2, 3, 3, true, NOW(), false);

    -- Soru 7: Dik açı
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "Explanation", "HasLatex", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir dik açının ölçüsü kaç derecedir? $\angle A = ?$', 0, 'B', 'Dik açı $90°$ dir.', true, 1, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "HasLatex", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '$45°$', true, 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '$90°$', true, 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '$180°$', true, 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '$360°$', true, 3, NOW(), false);

    -- Soru 8: Açı toplamı
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "Explanation", "HasLatex", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Bir üçgende açıların toplamı kaç derecedir? $\angle A + \angle B + \angle C = ?$', 0, 'C', 'Üçgenin iç açıları toplamı $180°$dir.', true, 2, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "HasLatex", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '$90°$', true, 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '$270°$', true, 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '$180°$', true, 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '$360°$', true, 3, NOW(), false);

    -- Soru 9: Alan formülü
    v_question_id := gen_random_uuid();
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "Explanation", "HasLatex", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (v_question_id, v_level_id, 'Tabanı $6$ cm, yüksekliği $4$ cm olan dikdörtgenin alanı nedir? $A = t \times y$', 0, 'A', '$A = 6 \times 4 = 24$ cm$^2$', true, 3, true, NOW(), false);
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "HasLatex", "DisplayOrder", "CreatedAt", "IsDeleted") VALUES
        (gen_random_uuid(), v_question_id, '$24$ cm$^2$', true, 0, NOW(), false),
        (gen_random_uuid(), v_question_id, '$20$ cm$^2$', true, 1, NOW(), false),
        (gen_random_uuid(), v_question_id, '$10$ cm', true, 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '$48$ cm$^2$', true, 3, NOW(), false);

END $$;
