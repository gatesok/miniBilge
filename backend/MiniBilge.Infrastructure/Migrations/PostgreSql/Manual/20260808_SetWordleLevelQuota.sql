-- Wordle seviye ilerleme kotası: ücretsiz günde 5, Premium sınırsız.
-- İdempotenttir. Aktif bir usage_quotas override'ı varsa onu da doğru değerlerle günceller.
BEGIN;

INSERT INTO usage_quotas (
    "Id", "FeatureKey", "FreeLimit", "PremiumLimit",
    "RewardedBonusLimit", "IsActive", "IsDeleted", "CreatedAt", "UpdatedAt"
)
VALUES (
    gen_random_uuid(), 'wordle_level', 5, -1,
    0, TRUE, FALSE, NOW(), NOW()
)
ON CONFLICT ("FeatureKey") DO UPDATE SET
    "FreeLimit" = EXCLUDED."FreeLimit",
    "PremiumLimit" = EXCLUDED."PremiumLimit",
    "RewardedBonusLimit" = EXCLUDED."RewardedBonusLimit",
    "IsActive" = TRUE,
    "IsDeleted" = FALSE,
    "UpdatedAt" = NOW();

COMMIT;
