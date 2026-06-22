-- Sprint 19: Provider-Agnostic TTS Pre-generation
-- podcast_lines tablosuna AudioUrl ve VoiceKey kolonları ekleme
-- Manuel çalıştırılacak — idempotent (defalarca çalıştırılabilir)

BEGIN;

-- AudioUrl: Bulut TTS tarafından üretilen ses dosyasının URL'si
-- NULL → henüz üretilmedi, Flutter fallback olarak iOS TTS kullanır
ALTER TABLE podcast_lines
    ADD COLUMN IF NOT EXISTS audio_url TEXT NULL;

-- VoiceKey: Provider-agnostic soyut ses anahtarı
-- Değerler: male_1 | male_2 | female_1 | female_2
-- Config'deki VoiceKeys tablosundan gerçek ses adına çözümlenir
ALTER TABLE podcast_lines
    ADD COLUMN IF NOT EXISTS voice_key VARCHAR(20) NULL;

-- Index: audio_url NULL olan satırları bulmak için (generate-audio endpoint)
CREATE INDEX IF NOT EXISTS IX_podcast_lines_audio_url_null
    ON podcast_lines ("EpisodeId")
    WHERE audio_url IS NULL;

COMMIT;

-- Doğrulama sorgusu (isteğe bağlı)
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_name = 'podcast_lines'
--   AND column_name IN ('audio_url', 'voice_key')
-- ORDER BY ordinal_position;
