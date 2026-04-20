# MiniBilge - Eğitici Oyun Mobil Uygulaması

MiniBilge, okul öncesi ve ilkokul çağındaki çocuklara (4-10 yaş) yönelik, öğrenmeyi oyunlaştırarak sunan bir mobil eğitim uygulamasıdır.

## 🎯 Proje Vizyonu

Çocukların kısa süreli ama düzenli kullanımla matematik pratiği yapabildiği, öğrendikçe ödüllendirildiği, ilerledikçe kendini güçlü hissettiği ve güvenli sosyal rekabet ile motive olduğu bir mobil öğrenme deneyimi oluşturmak.

## 📱 Hedef Kitle

- **Birincil:** 4-10 yaş arası çocuklar
  - Okul öncesi hazırlık grubu
  - İlkokul 1-4. sınıf öğrencileri
- **İkincil:** Ebeveynler ve öğretmenler

## 🚀 MVP Özellikleri

### Kullanıcı Yönetimi
- Ebeveyn kaydı ve girişi
- Çocuk profili oluşturma
- Yaş/sınıf bazlı içerik filtreleme
- Avatar seçimi

### Eğitim Motoru
- Matematik odaklı içerik
- Seviye bazlı ilerleme sistemi
- Konu ve level yapısı
- Soru gösterimi ve değerlendirme
- İlerleme takibi

### Oyunlaştırma
- Coin kazanımı
- Yıldız sistemi
- Bölüm tamamlama ödülleri
- Avatar özelleştirme
- Item mağazası

### Sosyal Özellikler
- Haftalık leaderboard
- Canlı skor güncellemeleri
- 1v1 matematik yarışması
- Online kullanıcı durumu

### Ebeveyn Paneli
- Günlük/haftalık aktivite özeti
- Güçlü ve zayıf konu analizi
- İlerleme raporları

## 🛠 Teknoloji Stack

### Mobil Uygulama
- **Framework:** Flutter
- **State Management:** Riverpod / BLoC
- **Routing:** Go Router
- **HTTP Client:** Dio
- **Serialization:** json_serializable / freezed

### Backend
- **Framework:** ASP.NET Core Web API
- **Real-time:** SignalR
- **ORM:** Entity Framework Core
- **Validation:** FluentValidation
- **Logging:** Serilog
- **Documentation:** Swagger/OpenAPI

### Veritabanı
- **Database:** PostgreSQL
- **Driver:** Npgsql

### Altyapı
- Docker & Docker Compose
- GitHub Actions (CI/CD)
- Nginx (Reverse Proxy)

## 📁 Proje Yapısı

```
MiniBilge/
├── docs/           # Dokümantasyon
├── backend/        # .NET Core backend
├── mobile/         # Flutter mobil uygulama
└── database/       # Database migrations ve scripts
```

## 🗓 Sprint Planı

Proje 2 haftalık sprint döngüleri ile geliştirilecektir:

- **Sprint 0:** Ürün keşfi ve teknik hazırlık
- **Sprint 1:** Proje setup ve kimlik/profil altyapısı
- **Sprint 2:** Matematik eğitim motoru V1
- **Sprint 3:** Progress, puan ve level unlock
- **Sprint 4:** Coin sistemi, avatar ve mağaza
- **Sprint 5:** Leaderboard ve SignalR altyapısı
- **Sprint 6:** 1v1 canlı matematik yarışı
- **Sprint 7:** Ebeveyn raporları ve güvenlik
- **Sprint 8:** Stabilizasyon ve yayın hazırlığı

## 📚 Dokümantasyon

Detaylı analiz ve planlama için `docs/mvp-analiz.md` dosyasına bakınız.

## 🔒 Güvenlik

Çocuk odaklı uygulama olduğu için güvenlik önceliklidir:
- Minimum veri toplama
- Ebeveyn kontrollü erişim
- Filtrelenmiş kullanıcı adları
- Chat özelliği MVP'de yok
- JWT tabanlı kimlik doğrulama

## 📊 Başarı Metrikleri

- Günlük/haftalık aktif kullanıcı
- Ortalama oturum süresi
- Tamamlanan seviye oranı
- Doğru cevap oranı
- Avatar özelleştirme kullanımı
- Yarış katılım oranı

## 📝 Lisans

TBD

---

**Proje Başlangıç Tarihi:** 2026-04-20
