-- ============================================================
-- Migration kaydını EF history tablosuna ekle
-- Tabloları elle oluşturduktan sonra çalıştırın
-- Böylece MigrateAsync() bu migration'ı tekrar çalıştırmaz
-- ============================================================

INSERT INTO "__EFMigrationsHistory_PostgreSQL" ("MigrationId", "ProductVersion")
VALUES ('20260622120232_AddPodcastEntities', '8.0.0')
ON CONFLICT ("MigrationId") DO NOTHING;
