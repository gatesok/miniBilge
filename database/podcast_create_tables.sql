-- ============================================================
-- Podcast tabloları ve indexleri — Manuel oluşturma scripti
-- Çalıştırma: psql veya pgAdmin ile doğrudan uygulayın
-- ============================================================

-- podcast_episodes tablosu
CREATE TABLE IF NOT EXISTS podcast_episodes (
    "Id"           uuid         NOT NULL DEFAULT gen_random_uuid(),
    "Title"        varchar(200) NOT NULL,
    "Description"  text         NOT NULL,
    "EnglishLevel" integer      NOT NULL,
    "DisplayOrder" integer      NOT NULL DEFAULT 0,
    "IsActive"     boolean      NOT NULL DEFAULT TRUE,
    "CreatedAt"    timestamptz  NOT NULL DEFAULT NOW(),
    "UpdatedAt"    timestamptz  NULL,
    "IsDeleted"    boolean      NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_podcast_episodes PRIMARY KEY ("Id")
);

-- podcast_lines tablosu
CREATE TABLE IF NOT EXISTS podcast_lines (
    "Id"            uuid        NOT NULL DEFAULT gen_random_uuid(),
    "EpisodeId"     uuid        NOT NULL,
    "SpeakerName"   varchar(50) NOT NULL,
    "SpeakerGender" integer     NOT NULL,
    "Text"          text        NOT NULL,
    "TranslationTr" text        NULL,
    "DisplayOrder"  integer     NOT NULL DEFAULT 0,
    "CreatedAt"     timestamptz NOT NULL DEFAULT NOW(),
    "UpdatedAt"     timestamptz NULL,
    "IsDeleted"     boolean     NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_podcast_lines PRIMARY KEY ("Id"),
    CONSTRAINT fk_podcast_lines_episode
        FOREIGN KEY ("EpisodeId")
        REFERENCES podcast_episodes ("Id")
        ON DELETE CASCADE
);

-- İndeksler
CREATE INDEX IF NOT EXISTS idx_podcast_episodes_level
    ON podcast_episodes ("EnglishLevel");

CREATE INDEX IF NOT EXISTS idx_podcast_lines_episode
    ON podcast_lines ("EpisodeId");
