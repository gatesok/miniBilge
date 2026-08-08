-- Reklamsız üyelik modeli: Premium avatar kozmetikleri ve Wordle günlük ipucu sıfırlaması.
-- İdempotenttir.
BEGIN;

ALTER TABLE avatar_items
    ADD COLUMN IF NOT EXISTS "IsPremiumExclusive" boolean NOT NULL DEFAULT FALSE;

UPDATE avatar_items
SET "IsPremiumExclusive" = TRUE
WHERE "Name" IN (
    '👑 Altın Taç',
    '🦸 Süper Kahraman Kostümü',
    '🌈 Gökkuşağı Arka Plan',
    '🌌 Uzay Arka Planı'
);

-- Yeni 0/20 kuralının tüm hesaplarda hemen uygulanması için bir sonraki istekte
-- üyelik durumuna göre günlük bakiye yeniden hesaplansın.
UPDATE wordle_level_progress
SET "JokerTickets" = 0,
    "LastJokerRefreshAt" = NULL;

COMMIT;
