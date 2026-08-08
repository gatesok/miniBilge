-- Reklamsız üyelik modeli: Premium kart koleksiyonu ve Wordle günlük ipucu sıfırlaması.
-- İdempotenttir; önceki avatar taslağı uygulanmışsa onu da temizler.
BEGIN;

ALTER TABLE collectible_cards
    ADD COLUMN IF NOT EXISTS "IsPremiumExclusive" boolean NOT NULL DEFAULT FALSE;

-- Efsanevi kartlar Premium koleksiyon olarak görünür ve yalnızca Premium
-- üyeler tarafından düşürülebilir veya parçayla açılabilir.
UPDATE collectible_cards
SET "IsPremiumExclusive" = ("Rarity" = 'legendary');

ALTER TABLE avatar_items
    DROP COLUMN IF EXISTS "IsPremiumExclusive";

-- Yeni 0/20 kuralının tüm hesaplarda hemen uygulanması için bir sonraki istekte
-- üyelik durumuna göre günlük bakiye yeniden hesaplansın.
UPDATE wordle_level_progress
SET "JokerTickets" = 0,
    "LastJokerRefreshAt" = NULL;

COMMIT;
