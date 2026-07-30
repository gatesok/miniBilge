-- MiniBilge rozet adlarını canlı veritabanında güvenli biçimde günceller.
-- Yalnızca sabit rozet anahtarlarını hedefler; kazanılmış rozet ilişkileri etkilenmez.

BEGIN;

UPDATE badges
SET "Name" = 'Alev Ustası'
WHERE "Key" = 'streak_30'
  AND "IsDeleted" = FALSE;

UPDATE badges
SET "Name" = 'Zafer Serisi'
WHERE "Key" = 'win_streak_5'
  AND "IsDeleted" = FALSE;

COMMIT;

SELECT "Key", "Name"
FROM badges
WHERE "Key" IN ('streak_30', 'win_streak_5')
ORDER BY "Key";
