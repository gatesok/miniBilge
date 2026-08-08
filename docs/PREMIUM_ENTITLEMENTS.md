# MiniBilge üyelik hakları

| Özellik | Ücretsiz | Premium |
|---|---:|---:|
| Standart matematik / İngilizce quizleri | Günde 5 | Sınırsız |
| Kişisel AI quiz | Günde 1 | Günde 10 |
| Yazma ve telaffuz analizi | Günde 1 | Sınırsız |
| Podcast | İlk 20 saniye | Tam ve sınırsız |
| Podcast indirme | Yok | Çevrimdışı TTS için indirilebilir |
| Wordle ipucu | Yok | Günde 20 |
| Çocuk profili | 1 | 3 |
| Geçmiş | Son 7 gün | Son 90 gün |
| Gelişim raporu | Haftalık özet | 90 günlük ayrıntılı analiz ve öneriler |
| Günlük plan | Standart plan | Seviyeye göre kişiselleştirilmiş plan |
| Ebeveyn önerileri | Genel özet | Haftalık çalışılacak konu önerileri |
| Kart / avatar / rozet | Temel koleksiyon | Özel ve yüksek nadirlikli koleksiyon |
| Sertifika | Temel başarı | Seviye ve dönem başarı sertifikası |

Uygulamada hiçbir üyelik katmanında reklam gösterilmez.

## Veritabanı geçişi

Dağıtımdan önce aşağıdaki idempotent PostgreSQL scripti çalıştırılmalıdır:

`backend/MiniBilge.Infrastructure/Migrations/PostgreSql/Manual/20260808_AddPremiumCosmeticsAndResetWordleHints.sql`

Script `avatar_items` tablosuna `IsPremiumExclusive` alanını ekler, Premium avatar
öğelerini işaretler ve Wordle ipuçlarını yeni günlük 0/20 kuralına geçirir.
