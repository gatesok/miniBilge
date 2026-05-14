# Soru & Cevap Import Rehberi

Bu döküman, PostgreSQL veritabanına soru ve cevapların nasıl import edileceğini adım adım açıklar.

> **Önemli:** Tablo adları `snake_case` (küçük harf), kolon adları `PascalCase` (büyük harfle başlayan).
> PostgreSQL case-sensitive olduğu için kolon adları çift tırnak (`"Id"`, `"Name"` vb.) içinde yazılmalıdır.

---

## Tablo İlişkisi (Sıra Önemli!)

```
subjects → topics → levels → questions → question_options
```

Her üst tablo oluşturulmadan alt tabloya kayıt eklenemez. Import sırası bu zincire göre yapılmalıdır.

---

## Adım 1: Subject (Ders) Oluştur

Eğer "Matematik" dersi yoksa ekle. Zaten varsa bu adımı atla.

```sql
INSERT INTO subjects ("Id", "Name", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
VALUES (gen_random_uuid(), 'Matematik', 1, true, NOW(), false);
```

Mevcut subject'i bulmak için:
```sql
SELECT "Id", "Name" FROM subjects WHERE "Name" = 'Matematik';
```

---

## Adım 2: Topic (Konu) Oluştur

Her konu bir subject'e bağlıdır. `"SubjectId"` önceki adımdan alınan UUID olmalıdır.

```sql
INSERT INTO topics ("Id", "SubjectId", "Name", "Description", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
VALUES (
    gen_random_uuid(),
    '<subject_id>',        -- Matematik'in ID'si
    'Doğal Sayılar',       -- Konu adı
    NULL,                  -- Açıklama (opsiyonel)
    1,                     -- Sıra
    true,
    NOW(),
    false
);
```

Mevcut topic'leri görmek için:
```sql
SELECT "Id", "Name" FROM topics WHERE "SubjectId" = '<subject_id>';
```

---

## Adım 3: Level (Seviye) Oluştur

Her level bir topic'e bağlıdır. Bir topic altında birden fazla level olabilir (Seviye 1, Seviye 2 gibi).

```sql
INSERT INTO levels ("Id", "TopicId", "Name", "Description", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
VALUES (
    gen_random_uuid(),
    '<topic_id>',          -- Konunun ID'si
    'Seviye 1',            -- Level adı
    NULL,                  -- Açıklama (opsiyonel)
    2,                     -- Zorluk (1-10 arası)
    1,                     -- Sıra
    7,                     -- Geçmek için minimum doğru sayısı (10 soruda 7)
    true,
    NOW(),
    false
);
```

> **Not:** `"MinCorrectToPass"` varsayılan olarak 7'dir. Her level'da 10 soru olması beklenir.

---

## Adım 4: Question (Soru) Ekle

Her soru bir level'a bağlıdır. `"CorrectAnswer"` değeri şık harfi olmalıdır: `'A'`, `'B'`, `'C'` veya `'D'`.

```sql
INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "Explanation", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
VALUES (
    gen_random_uuid(),
    '<level_id>',                          -- Level'ın ID'si
    '125 sayısının basamak değerleri toplamı kaçtır?',  -- Soru metni
    0,                                     -- QuestionType: 0 = MultipleChoice
    'B',                                   -- Doğru şık (A/B/C/D)
    NULL,                                  -- Açıklama (opsiyonel)
    1,                                     -- Sorular içindeki sıra
    true,
    NOW(),
    false
);
```

---

## Adım 5: QuestionOption (Şıklar) Ekle

Her soru için **4 şık** eklenmelidir. `"DisplayOrder"` değerleri: `0=A`, `1=B`, `2=C`, `3=D`.

```sql
-- Aynı sorunun 4 şıkkı tek seferde:
INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted")
VALUES
    (gen_random_uuid(), '<question_id>', '7',   0, NOW(), false),  -- A
    (gen_random_uuid(), '<question_id>', '8',   1, NOW(), false),  -- B
    (gen_random_uuid(), '<question_id>', '12',  2, NOW(), false),  -- C
    (gen_random_uuid(), '<question_id>', '15',  3, NOW(), false);  -- D
```

---

## Tam Örnek (Tek Soru, Tek Seferde)

```sql
DO $$
DECLARE
    v_subject_id  UUID;
    v_topic_id    UUID;
    v_level_id    UUID;
    v_question_id UUID;
BEGIN
    -- Subject al
    SELECT "Id" INTO v_subject_id
    FROM subjects
    WHERE "Name" = 'Matematik' AND "IsDeleted" = false
    LIMIT 1;

    -- Topic oluştur (yoksa)
    INSERT INTO topics ("Id", "SubjectId", "Name", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (gen_random_uuid(), v_subject_id, 'Doğal Sayılar', 1, true, NOW(), false)
    ON CONFLICT DO NOTHING
    RETURNING "Id" INTO v_topic_id;

    -- Zaten varsa al
    IF v_topic_id IS NULL THEN
        SELECT "Id" INTO v_topic_id
        FROM topics
        WHERE "SubjectId" = v_subject_id AND "Name" = 'Doğal Sayılar'
        LIMIT 1;
    END IF;

    -- Level oluştur
    INSERT INTO levels ("Id", "TopicId", "Name", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (gen_random_uuid(), v_topic_id, 'Seviye 1', 2, 1, 7, true, NOW(), false)
    RETURNING "Id" INTO v_level_id;

    -- Soru ekle
    INSERT INTO questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "DisplayOrder", "IsActive", "CreatedAt", "IsDeleted")
    VALUES (gen_random_uuid(), v_level_id, '125 sayısının basamak değerleri toplamı kaçtır?', 0, 'B', 1, true, NOW(), false)
    RETURNING "Id" INTO v_question_id;

    -- Şıklar ekle
    INSERT INTO question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "IsDeleted")
    VALUES
        (gen_random_uuid(), v_question_id, '7',  0, NOW(), false),
        (gen_random_uuid(), v_question_id, '8',  1, NOW(), false),
        (gen_random_uuid(), v_question_id, '12', 2, NOW(), false),
        (gen_random_uuid(), v_question_id, '15', 3, NOW(), false);
END $$;
```

---

## Kontrol Sorguları

Eklenen verileri doğrulamak için:

```sql
-- Tüm soruları seviye ve konu adıyla listele
SELECT
    s."Name" AS subject,
    t."Name" AS topic,
    l."Name" AS level,
    q."DisplayOrder" AS sira,
    q."QuestionText",
    q."CorrectAnswer"
FROM questions q
JOIN levels l ON q."LevelId" = l."Id"
JOIN topics t ON l."TopicId" = t."Id"
JOIN subjects s ON t."SubjectId" = s."Id"
WHERE q."IsDeleted" = false
ORDER BY s."Name", t."Name", l."DisplayOrder", q."DisplayOrder";

-- Bir sorunun şıklarını görüntüle
SELECT
    CASE "DisplayOrder" WHEN 0 THEN 'A' WHEN 1 THEN 'B' WHEN 2 THEN 'C' WHEN 3 THEN 'D' END AS sik,
    "OptionText"
FROM question_options
WHERE "QuestionId" = '<question_id>'
ORDER BY "DisplayOrder";
```

---

## Özet Akış

```
1. subjects tablosunda Matematik var mı? → yoksa ekle
2. topics tablosuna konu ekle (Doğal Sayılar, Toplama, Çıkarma vb.)
3. levels tablosuna seviye ekle (Seviye 1, Seviye 2 vb.)
4. questions tablosuna her soruyu ekle ("CorrectAnswer": 'A'/'B'/'C'/'D')
5. question_options tablosuna her soru için 4 şık ekle ("DisplayOrder": 0/1/2/3)
```

> **Cloud SQL'e bağlanmak için:**
> ```bash
> psql "host=REDACTED_IP port=5432 dbname=postgres user=postgres sslmode=require"
> ```
