-- Sprint 2: profil bazlı kart ekonomisi, garanti sayaçları, parçalar ve ölçüm.
-- İdempotenttir; mevcut kart ve kazanım kayıtlarını değiştirmez.
BEGIN;

CREATE TABLE IF NOT EXISTS card_economy_states (
    "Id" uuid PRIMARY KEY,
    "ChildProfileId" uuid NOT NULL REFERENCES child_profiles("Id") ON DELETE CASCADE,
    "ShardBalance" integer NOT NULL DEFAULT 0,
    "AttemptsSinceDrop" integer NOT NULL DEFAULT 0,
    "DuplicatesSinceNew" integer NOT NULL DEFAULT 0,
    "DailyDate" date NOT NULL DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC')::date,
    "DailyCardsEarned" integer NOT NULL DEFAULT 0,
    "UpdatedAt" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE UNIQUE INDEX IF NOT EXISTS "IX_card_economy_states_ChildProfileId"
    ON card_economy_states ("ChildProfileId");

CREATE TABLE IF NOT EXISTS card_economy_events (
    "Id" uuid PRIMARY KEY,
    "ChildProfileId" uuid NOT NULL REFERENCES child_profiles("Id") ON DELETE CASCADE,
    "CardId" uuid NULL REFERENCES collectible_cards("Id") ON DELETE SET NULL,
    "Source" varchar(40) NOT NULL,
    "Stage" varchar(20) NOT NULL,
    "Outcome" varchar(30) NOT NULL,
    "DropRate" double precision NOT NULL,
    "WasGuaranteed" boolean NOT NULL DEFAULT FALSE,
    "WasDuplicate" boolean NOT NULL DEFAULT FALSE,
    "ShardsAwarded" integer NOT NULL DEFAULT 0,
    "IdempotencyKey" varchar(120) NULL,
    "CreatedAt" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE UNIQUE INDEX IF NOT EXISTS "IX_card_economy_events_Profile_Key"
    ON card_economy_events ("ChildProfileId", "IdempotencyKey")
    WHERE "IdempotencyKey" IS NOT NULL;
CREATE INDEX IF NOT EXISTS "IX_card_economy_events_Profile_CreatedAt"
    ON card_economy_events ("ChildProfileId", "CreatedAt");

COMMIT;

SELECT table_name
FROM information_schema.tables
WHERE table_name IN ('card_economy_states', 'card_economy_events')
ORDER BY table_name;
