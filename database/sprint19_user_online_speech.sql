-- Sprint 19: Online speech permission flag
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS "CanUseOnlineSpeech" BOOLEAN NOT NULL DEFAULT true;

-- Mevcut kullanıcıları true yap
UPDATE users SET "CanUseOnlineSpeech" = true WHERE "CanUseOnlineSpeech" = false;
