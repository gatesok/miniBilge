-- Sprint 19: Online speech permission flag
ALTER TABLE users
    ADD COLUMN "CanUseOnlineSpeech" BOOLEAN NOT NULL DEFAULT false;
