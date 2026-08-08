# MiniBilge üyelik hakları

| Özellik | Ücretsiz | Premium |
|---|---:|---:|
| Standart matematik / İngilizce quizleri | Günde 5 | Sınırsız |
| Kişisel AI quiz | Günde 1 | Günde 10 |
| İngilizce AI araçları (kartlar, yazma, kelime meydan okuması, rol yapma, telaffuz) | Tüm araçlarda toplam günde 2 | Araç başına günde 3 |
| Podcast | İlk 20 saniye | Tam ve sınırsız |
| Wordle ipucu | Yok | Günde 20 |
| Wordle seviye ilerlemesi | Günde 5 | Sınırsız |
| Çocuk profili | 1 | 3 |
| Geçmiş | Son 7 gün | Son 90 gün |
| Gelişim raporu | Haftalık özet | 90 günlük ayrıntılı analiz ve öneriler |
| Günlük plan | Standart plan | Seviyeye göre kişiselleştirilmiş plan |
| Ebeveyn önerileri | Genel özet | Haftalık çalışılacak konu önerileri |
| Kart / rozet | Temel koleksiyon | Özel ve yüksek nadirlikli koleksiyon |
| Sertifika | Temel başarı | Seviye ve dönem başarı sertifikası |

Uygulamada hiçbir üyelik katmanında reklam gösterilmez.

## Veritabanı geçişi

Dağıtımdan önce aşağıdaki idempotent PostgreSQL scripti çalıştırılmalıdır:

`backend/MiniBilge.Infrastructure/Migrations/PostgreSql/Manual/20260808_AddPremiumCardsAndResetWordleHints.sql`

Script `collectible_cards` tablosuna `IsPremiumExclusive` alanını ekler, efsanevi
kartları Premium olarak işaretler ve Wordle ipuçlarını yeni günlük 0/20 kuralına geçirir.

## Yayın sırası

Önerilen güvenli sıra:

1. Manuel PostgreSQL scriptini çalıştır.
2. Yeni iOS/Android sürümü mağaza onayı alıncaya kadar mevcut backend sürümünü koru.
3. Mobil sürüm yayına hazır olduğunda backend ve mobili aynı yayın penceresinde çıkar.

Backend önce yayınlanırsa eski mobil sürüm reklam göstermeye devam eder fakat reklam
ödülleri artık hak kazandırmaz; Wordle ipucu ve AI konu anlatımı gibi akışlarda eski
arayüz ile yeni sunucu kuralları birbiriyle uyuşmaz. Standart quiz endpoint'i eski
istemciler için geriye uyumludur, ancak ürün davranışındaki bu farklar nedeniyle
backend'in tek başına erken yayınlanması önerilmez.
