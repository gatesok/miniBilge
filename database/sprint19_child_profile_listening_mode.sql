-- Sprint 19: PodcastListeningMode profil tercihi
-- child_profiles tablosuna PodcastListeningMode kolonu ekleme
-- Manuel çalıştırılacak — idempotent

BEGIN;

-- 0 = Offline (cihaz TTS — varsayılan)
-- 1 = Online (Google TTS pre-generated ses dosyaları)
ALTER TABLE child_profiles
    ADD COLUMN IF NOT EXISTS "PodcastListeningMode" INT NOT NULL DEFAULT 0;

COMMIT;

-- Doğrulama
-- SELECT column_name, data_type, column_default
-- FROM information_schema.columns
-- WHERE table_name = 'child_profiles' AND column_name = 'PodcastListeningMode';
