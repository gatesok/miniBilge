# Eğitici Oyun Mobil Uygulaması MVP
## Süreç Analizi, Teknik Analiz ve Sprint Planı

## 1. Proje Özeti

Bu proje; okul öncesi, 1. sınıf, 2. sınıf, 3. sınıf ve 4. sınıf seviyesindeki çocuklara yönelik, öğrenmeyi oyunlaştırarak sunan bir mobil eğitim uygulamasıdır. Uygulamanın ilk odak alanı matematik olacaktır. Sonraki fazlarda İngilizce modülü de eklenecektir.

Uygulama sadece soru çözdüren bir eğitim aracı olarak değil, aynı zamanda çocukların başarı hissi yaşamasını sağlayan, ödül kazandıran, avatar geliştirme ve kontrollü rekabet mekanikleri sunan bir ürün olarak kurgulanacaktır.

MVP kapsamında aşağıdaki ana başlıklar hedeflenmektedir:

- Flutter tabanlı mobil uygulama
- .NET Core tabanlı backend servisleri
- PostgreSQL veritabanı
- SignalR / WebSocket tabanlı gerçek zamanlı etkileşim
- Matematik tabanlı seviye sistemi
- Coin, yıldız ve ödül mekanikleri
- Avatar özelleştirme
- Canlı leaderboard
- Basit 1v1 canlı matematik yarışı
- Temel ebeveyn raporlama ekranları

---

## 2. Ürün Vizyonu

Çocukların kısa süreli ama düzenli kullanımla matematik pratiği yapabildiği, öğrendikçe ödüllendirildiği, ilerledikçe kendini güçlü hissettiği ve güvenli sosyal rekabet ile motive olduğu bir mobil öğrenme deneyimi oluşturmak.

---

## 3. Ürün Hedefleri

### 3.1 Ana Hedefler
- Matematik öğrenimini eğlenceli hale getirmek
- Kolaydan zora ilerleyen yapı kurmak
- Çocukta günlük kullanım alışkanlığı oluşturmak
- Başarıyı görünür ödüllerle desteklemek
- Güvenli sosyal etkileşim ve rekabet sunmak
- Ebeveyne çocuk gelişimi ile ilgili özet görünüm sağlamak

### 3.2 İş Hedefleri
- Düşük lisans maliyeti ile sürdürülebilir MVP çıkarmak
- İlk versiyonu hızlı şekilde test edilebilir hale getirmek
- İçerik ve kullanıcı geri bildirimine göre ürünü genişletebilmek
- İleride İngilizce ve yeni eğitim modülleri eklenebilecek altyapı kurmak

---

## 4. Hedef Kitle

### 4.1 Birincil Hedef Kitle
- 4–10 yaş arası çocuklar
- Okul öncesi hazırlık grubu
- İlkokul 1–4. sınıf öğrencileri

### 4.2 İkincil Hedef Kitle
- Ebeveynler
- Öğretmenler

### 4.3 Kullanıcı Segmentleri
- Okul öncesi: sayı tanıma, şekiller, sayma, eşleştirme
- 1. sınıf: toplama, çıkarma, sayı sıralama
- 2. sınıf: iki basamaklı işlemler, saat, para, ölçüler
- 3. sınıf: çarpma, bölme, problem çözme, tablo yorumlama
- 4. sınıf: zorlayıcı problemler, kesirler, çevre/alan girişleri

---

## 5. Kapsam Tanımı

## 5.1 MVP Kapsamı
MVP sürümünde aşağıdaki fonksiyonların yer alması planlanmaktadır:

### Kullanıcı ve Profil
- Ebeveyn kaydı / girişi
- Çocuk profili oluşturma
- Yaş / sınıf seçimi
- Çocuk avatar başlangıç seçimi

### Eğitim Motoru
- Matematik ders modülü
- Seviye bazlı içerik
- Konu ve level yapısı
- Soru gösterimi ve cevaplama
- Doğru / yanlış geri bildirimi
- Puan ve ilerleme hesaplama

### Oyunlaştırma
- Coin kazanımı
- Yıldız sistemi
- Bölüm tamamlama ödülleri
- Basit görev mantığı

### Avatar ve Ödüller
- Avatar ekranı
- Kıyafet / aksesuar item yapısı
- Coin ile item alma
- Envanter ve equip mantığı

### Sosyal ve Gerçek Zamanlı Özellikler
- Haftalık leaderboard
- Canlı skor güncelleme
- Online kullanıcı durumu
- 1v1 canlı yarış eşleşmesi
- Canlı maç sonucu ekranı

### Ebeveyn Tarafı
- Temel ilerleme özeti
- Günlük / haftalık aktivite özeti
- Güçlü ve zayıf konu görünümü

## 5.2 MVP Dışı Bırakılan Konular
Aşağıdaki başlıklar sonraki fazlara bırakılmalıdır:

- Açık chat sistemi
- Grup odaları
- Takım bazlı turnuvalar
- Gelişmiş arkadaşlık sistemi
- İngilizce modülü
- Sesli rehberlik / voice assistant
- AI tabanlı kişiselleştirilmiş öğrenme önerileri
- Gelişmiş içerik yönetim araçları
- Çok detaylı sezonsal etkinlikler

---

## 6. Süreç Analizi

## 6.1 Proje Geliştirme Yaklaşımı
Proje çevik yöntemle yönetilmelidir. 2 haftalık sprint döngüleri uygundur. Her sprint sonunda test edilebilir, gözle görülür bir çıktı üretilmesi hedeflenmelidir.

Önerilen yaklaşım:
- Sprint 0: ürün ve teknik hazırlık
- Sprint planlama toplantıları
- Günlük kısa durum takibi
- Sprint review
- Sprint retrospective
- Sürekli backlog iyileştirme

## 6.2 Faz Bazlı İlerleme

### Faz 1 – Keşif ve Tanımlama
- Ürün vizyonunun netleştirilmesi
- Personaların oluşturulması
- Eğitim içerik ağacının çıkarılması
- MVP sınırlarının netleştirilmesi
- Wireframe ve bilgi mimarisi çalışmaları

### Faz 2 – Temel Ürün Geliştirme
- Kullanıcı altyapısı
- Matematik motoru
- Progress sistemi
- Ödül yapısı
- Avatar sistemi

### Faz 3 – Gerçek Zamanlı Rekabet
- Leaderboard
- SignalR altyapısı
- Online kullanıcı mantığı
- 1v1 canlı yarış

### Faz 4 – Ebeveyn ve Stabilizasyon
- Ebeveyn rapor ekranları
- Güvenlik kontrolleri
- Performans ve yayın hazırlıkları

## 6.3 Süreçte Kritik Roller

### Ürün / İş Tarafı
- Product Owner
- İçerik danışmanı / öğretmen
- UI/UX tasarımcı

### Teknik Taraf
- Flutter geliştirici
- .NET Core backend geliştirici
- QA / test desteği
- İhtiyaca göre DevOps desteği

## 6.4 Süreçte Kritik Başarı Faktörleri
- Kapsamın MVP sınırında tutulması
- Eğitim içeriğinin doğru seviyelendirilmesi
- Çocuk dostu arayüz tasarımı
- Ebeveyn güveni sağlayan güvenlik yapısı
- Gerçek zamanlı özelliklerin kontrollü şekilde devreye alınması

---

## 7. Fonksiyonel Analiz

## 7.1 Kullanıcı ve Profil Yönetimi
### Gereksinimler
- Ebeveyn uygulamaya kayıt olabilir
- Ebeveyn giriş yapabilir
- Ebeveyn bir veya daha fazla çocuk profili oluşturabilir
- Her çocuk profiline yaş / sınıf bilgisi atanabilir
- Her çocuk için başlangıç avatarı seçilebilir

### Kabul Kriterleri
- Profil oluşturma 1 dakikadan kısa sürede tamamlanabilmeli
- Çocuk profili olmadan oyun akışına geçilememeli
- Profil verileri kalıcı olarak saklanmalı

## 7.2 Matematik Eğitim Motoru
### Gereksinimler
- Soru havuzu konu, sınıf ve zorluk bazlı yönetilebilmeli
- Kullanıcı seviyesine göre soru çekilebilmeli
- Soru tipi başlangıçta çoktan seçmeli veya basit input olabilir
- Cevap sonrası doğru/yanlış geri bildirimi verilmeli
- Bölüm sonunda puan ve başarı özeti sunulmalı

### Kabul Kriterleri
- Aynı level için minimum soru seti üretilebilmeli
- Cevaplama akışı teknik hata olmadan tamamlanmalı
- Doğru/yanlış kayıtları ilerleme sistemine işlenmeli

## 7.3 Progress ve Level Sistemi
### Gereksinimler
- Kullanıcıların tamamladığı level’lar saklanmalı
- Puan, yıldız ve başarı durumu hesaplanmalı
- Belirli bir başarı eşiği ile yeni seviye açılmalı
- Başarısız olunan level tekrar oynanabilmeli

### Kabul Kriterleri
- Level unlock kuralı net ve tutarlı çalışmalı
- Kullanıcı uygulamaya tekrar girdiğinde aynı ilerleme noktası korunmalı

## 7.4 Oyunlaştırma Sistemi
### Gereksinimler
- Bölüm tamamlandığında coin kazanımı olmalı
- Performansa göre yıldız kazanımı olmalı
- Rozet / görev gibi yapılar genişlemeye uygun tasarlanmalı

### Kabul Kriterleri
- Coin hesaplaması backend tarafından yapılmalı
- Kullanıcının coin bakiyesi tutarlı görünmeli

## 7.5 Avatar ve Item Yönetimi
### Gereksinimler
- Avatar için item listesi sunulmalı
- Kullanıcı item satın alabilmeli
- Satın alınan item envantere düşmeli
- Kullanıcı item’i avatarına uygulayabilmeli

### Kabul Kriterleri
- Coin yetersizse satın alma engellenmeli
- Equip edilen item kalıcı olarak saklanmalı

## 7.6 Leaderboard
### Gereksinimler
- Kullanıcı puanları haftalık bazda sıralanmalı
- Leaderboard filtreleri seviye veya kategori bazında genişletilebilir olmalı
- Kullanıcı kendi sırasını görebilmeli

### Kabul Kriterleri
- Puan değiştiğinde sıralama güncellenmeli
- Aynı kullanıcı için puan çakışmaları engellenmeli

## 7.7 1v1 Canlı Yarış
### Gereksinimler
- Oyuncu yarış isteği gönderebilmeli
- Sistem benzer seviyede rakip bulabilmeli
- Aynı soru seti iki oyuncuya da atanmalı
- Cevaplar server tarafında değerlendirilerek canlı skor hesaplanmalı
- Yarış sonunda sonuç ekranı gösterilmeli

### Kabul Kriterleri
- Yarış sırasında skor güncellemesi gecikmesiz hissedilmeli
- Bağlantı kopması için minimum hata yönetimi olmalı
- Server authoritative scoring uygulanmalı

## 7.8 Ebeveyn Raporlama
### Gereksinimler
- Günlük soru çözüm sayısı gösterilmeli
- Doğru / yanlış oranı gösterilmeli
- Güçlü ve zayıf konu özeti verilmeli

### Kabul Kriterleri
- Rapor ekranı anlaşılır ve sade olmalı
- Veriler en geç son oturum sonunda güncellenmiş olmalı

## 8. Teknik Analiz

## 8.1 Teknoloji Stack’i
### Mobil
- Flutter
- Riverpod veya BLoC
- Go Router
- Dio
- json_serializable / freezed

### Backend
- ASP.NET Core Web API
- SignalR
- Entity Framework Core
- FluentValidation
- Serilog
- Swagger / OpenAPI

### Veritabanı
- PostgreSQL
- Npgsql

### Altyapı / Dağıtım
- Docker
- Docker Compose
- GitHub Actions
- Linux sunucu
- Nginx reverse proxy

### Opsiyonel Bileşenler
- Redis (leaderboard cache / queue optimizasyonu için)
- MinIO veya benzeri object storage

## 8.2 Mimari Yaklaşım
Backend tarafında katmanlı veya temiz mimariye yakın bir yapı önerilir:

- API Layer
- Application Layer
- Domain Layer
- Infrastructure Layer

Bu sayede:
- iş kuralları ayrışır
- test yazımı kolaylaşır
- modüler büyüme sağlanır
- ileride servisleşmeye uygun yapı oluşur

## 8.3 Önerilen Backend Modülleri
- Identity & Profile Module
- Learning Engine Module
- Reward Engine Module
- Avatar Module
- Leaderboard Module
- Matchmaking & Real-Time Competition Module
- Parent Reporting Module

## 8.4 Flutter Tarafı Mimari Öneri
Feature-based klasörleme önerilir.

Örnek yapı:
- core/
- shared/
- features/auth/
- features/profile/
- features/learning/
- features/avatar/
- features/leaderboard/
- features/matchmaking/
- features/parent_dashboard/

## 8.5 API Yaklaşımı
REST API + SignalR birlikte kullanılmalıdır.

### REST API kullanılacak alanlar
- authentication
- profil yönetimi
- soru çekme
- progress kayıtları
- mağaza işlemleri
- raporlama verileri

### SignalR kullanılacak alanlar
- online status
- matchmaking eventleri
- canlı yarış skorları
- yarış başlangıç / bitiş eventleri
- leaderboard canlı güncellemeleri

## 8.6 Veritabanı Ana Varlıkları

### Kullanıcı Yönetimi
- users
- parent_profiles
- child_profiles

### Eğitim İçeriği
- subjects
- topics
- levels
- questions
- question_options

### Öğrenme ve İlerleme
- answer_attempts
- child_progress
- level_results

### Oyunlaştırma
- reward_transactions
- coin_wallets
- badges
- child_badges

### Avatar Sistemi
- avatars
- avatar_items
- child_owned_items
- child_equipped_items

### Sosyal ve Yarışma
- leaderboard_entries
- match_requests
- match_sessions
- match_participants
- match_questions
- match_answers

### Raporlama
- activity_logs
- parent_summary_snapshots

## 8.7 Güvenlik Analizi
Çocuk odaklı ürün olduğu için güvenlik ve koruma kritik önemdedir.

### Temel Güvenlik Gereksinimleri
- çocuk verileri minimum düzeyde tutulmalı
- ebeveyn kimliği ve çocuk profili ayrıştırılmalı
- chat özelliği MVP’de olmamalı
- kullanıcı adları filtrelenmeli
- erişim yetkileri rol bazlı kontrol edilmeli
- yarış ve sosyal özellikler gerektiğinde ebeveyn kontrolü ile kısıtlanabilmeli

### Teknik Güvenlik Maddeleri
- JWT tabanlı kimlik doğrulama
- refresh token yönetimi
- input validation
- rate limiting
- loglama ve hata takibi
- hassas veri maskeleme

## 8.8 Performans Analizi
### Dikkat Edilecek Konular
- soru ekranlarının hızlı açılması
- leaderboard sorgularının optimize edilmesi
- gerçek zamanlı yarışlarda düşük gecikme
- aynı anda birden fazla kullanıcı bağlandığında bağlantı yönetimi

### Teknik Yaklaşım
- sorgu optimizasyonu
- gerekli alanlarda indexleme
- leaderboard için gerekirse cache
- SignalR grup / room yönetimi
- event bazlı minimal payload kullanımı

## 8.9 Ölçeklenebilirlik Analizi
İlk sürüm küçük tutulmalı ancak mimari büyümeye hazır olmalıdır.

### Genişleme Senaryoları
- İngilizce modülü ekleme
- yeni yaş grupları ekleme
- yeni soru tipleri ekleme
- sezonsal etkinlikler
- öğretmen paneli
- çok oyunculu turnuvalar

---

## 9. Teknik Riskler ve Yönetim Planı

## 9.1 Risk: Kapsamın Hızla Büyümesi
**Açıklama:** Eğitim, ödül, avatar, yarış ve raporlama birlikte yönetildiğinde MVP kontrolsüz büyüyebilir.

**Önlem:**
- Sprint başına net kapsam sınırı
- Must / Should / Could ayrımı
- MVP dışında kalan konuların bilinçli ertelenmesi

## 9.2 Risk: Eğitim İçeriği Eksikliği
**Açıklama:** Yazılım yetişse bile içerik eksik kalabilir.

**Önlem:**
- Sprint 0’da konu ağacı ve minimum içerik havuzu oluşturulmalı
- Öğretmen veya içerik uzmanı desteği alınmalı

## 9.3 Risk: Gerçek Zamanlı Yarış Karmaşıklığı
**Açıklama:** Matchmaking, bağlantı kopması, gecikme ve skor doğruluğu zor alanlardır.

**Önlem:**
- MVP’de yalnızca 1v1 basit yapı
- Server authoritative scoring
- Basit timeout ve forfeit mekanizması

## 9.4 Risk: Çocuk Güvenliği
**Açıklama:** Sosyal özellikler yanlış tasarlanırsa güvenlik riski doğurabilir.

**Önlem:**
- Chat olmamalı
- Filtrelenmiş nickname sistemi olmalı
- İzin kontrollü sosyal yapı kurulmalı

## 9.5 Risk: Performans Sorunları
**Açıklama:** Leaderboard ve gerçek zamanlı yarış yükü performans sıkıntısı yaratabilir.

**Önlem:**
- Optimize sorgular
- Gerekirse Redis cache
- SignalR event payload’larının dar tutulması

---

## 10. Süreçte Ölçülecek Başarı Metrikleri

### Ürün Kullanımı
- Günlük aktif kullanıcı
- Haftalık aktif kullanıcı
- Ortalama oturum süresi
- Günlük çözülen soru sayısı

### Öğrenme Başarısı
- Tamamlanan level oranı
- Doğru cevap oranı
- Tekrar oynanan bölüm oranı
- Konu bazlı başarı trendi

### Oyunlaştırma
- Kazanılan coin miktarı
- Harcanan coin oranı
- Avatar item kullanım oranı

### Sosyal ve Realtime
- Yarış başlatma sayısı
- Yarış tamamlama oranı
- Matchmaking bekleme süresi
- Leaderboard ekran görüntülenme oranı

### Ebeveyn Değeri
- Rapor ekranı görüntüleme oranı
- Haftalık geri dönüş oranı

---

## 11. Sprint Planı

Aşağıdaki sprintler 2 haftalık çevrim varsayımı ile hazırlanmıştır.

---

## Sprint 0 – Ürün Keşfi ve Teknik Hazırlık
### Amaç
Ürünün kapsamını ve teknik omurgasını netleştirmek.

### İş Kalemleri
- Ürün vizyonunun netleştirilmesi
- Hedef kullanıcı personlarının tanımlanması
- Matematik içerik ağacının çıkarılması
- MVP kapsam sınırının belirlenmesi
- Temel kullanıcı akışlarının oluşturulması
- Wireframe taslaklarının hazırlanması
- Backend mimarisinin belirlenmesi
- Flutter proje yapısının belirlenmesi
- PostgreSQL veri model taslağının çıkarılması
- SignalR hub ve event akışlarının tanımlanması

### Çıktılar
- Ürün gereksinim taslağı
- Teknik mimari taslağı
- Veri modeli taslağı
- Ekran listesi
- Sprint backlog başlangıcı

---

## Sprint 1 – Proje Setup ve Kimlik / Profil Altyapısı ✅ TAMAMLANDI
### Amaç
Temel teknik altyapıyı ayağa kaldırmak ve kullanıcı giriş/profil akışını hazırlamak.

### Frontend İşleri
- Flutter proje setup
- Tema, renk, typography ve component iskeleti
- Route / navigation altyapısı
- Kayıt ve giriş ekranları
- Çocuk profil oluşturma ekranları
- Yaş / sınıf seçimi ekranı

### Backend İşleri
- .NET Core solution oluşturulması
- Katmanlı mimari iskeleti
- PostgreSQL bağlantısı
- EF Core migration altyapısı
- JWT auth yapısı
- parent profile API’leri
- child profile API’leri

### Veritabanı İşleri
- users tablosu
- parent_profiles tablosu
- child_profiles tablosu
- temel migration’lar

### Test İşleri
- Auth endpoint testleri
- Profil oluşturma akışı testleri

### Çıktılar
- Ebeveyn kayıt/giriş
- Çocuk profil oluşturma
- Uygulama içinde profil seçimi

---

## Sprint 2 – Matematik Eğitim Motoru V1 ✅ TAMAMLANDI
### Amaç
İlk uçtan uca soru çözme deneyimini oluşturmak.

### Frontend İşleri
- Ders seçimi ekranı
- Matematik kategori ekranı
- Level listeleme ekranı
- Soru çözme ekranı
- Cevap verme bileşeni
- Sonuç ekranı

### Backend İşleri
- subjects, topics, levels modelleri
- questions ve question_options modelleri
- soru çekme API’si
- cevap kontrol API’si
- bölüm sonucu hesaplama mantığı

### İçerik İşleri
- okul öncesi başlangıç seviyesi örnek içerikleri
- 1. sınıf toplama / çıkarma içerikleri
- minimum playable soru havuzu

### Test İşleri
- Soru akışı testleri
- Farklı soru tipleri için validasyon testleri
- Sonuç ekranı testleri

### Çıktılar
- Kullanıcı matematik level seçip soru çözebilir
- Sonuç ekranı görebilir

---

## Sprint 3 – Progress, Puan ve Level Unlock Sistemi ✅ TAMAMLANDI
### Amaç
Öğrenme akışını kalıcı ilerleme yapısına dönüştürmek.

### Frontend İşleri
- İlerleme barı gösterimi
- Puan ve yıldız gösterimi
- Level kilit / açık durumları
- Bölüm başarı özeti ekranı

### Backend İşleri
- child_progress tablosu / modeli
- level_results yapısı
- puan hesaplama servisi
- yıldız hesaplama mantığı
- level unlock kuralları
- answer_attempt kayıtları

### İş Kuralları
- minimum başarı yüzdesi ile level açılması
- tekrar çözüm desteği
- kalan ilerlemenin kullanıcıya gösterilmesi

### Test İşleri
- Puan doğrulama testleri
- Level unlock senaryoları
- Tekrar çözüm testi

### Çıktılar
- İlerleme kalıcı hale gelir
- Kullanıcı yeni seviyeler açabilir

---

## Sprint 4 – Puan Bazlı Avatar Mağazası ve Özelleştirme ✅ TAMAMLANDI (32a36c5)
### Amaç
Oyunlaştırmayı görünür ve motive edici hale getirmek. Çocuklar quiz'lerden kazandıkları puanlarla avatar aksesuarları satın alabilir.

### Frontend İşleri
- Avatar profil ekranı (equipped items gösterimi)
- Mağaza ekranı (item listesi, fiyat, satın alma)
- Puan bakiyesi widget'ı (Dashboard ve mağazada)
- Item satın alma confirmation dialog
- Envanter ekranı (sahip olunan items)
- Equip / unequip akışı (item seç → avatara uygula)
- Preview özelliği (satın almadan önce deneme)

### Backend İşleri
- `avatars` tablosu (Id, Name, ImageUrl, IsDefault)
- `avatar_items` tablosu (Id, Name, ItemType, PointCost, ImageUrl, Category)
  - ItemType: Hat, Glasses, Outfit, Accessory, Background
  - PointCost: Puan cinsinden fiyat (örn: 50, 100, 250)
- `child_owned_items` tablosu (ChildProfileId FK, ItemId FK, PurchasedAt)
- `child_equipped_items` tablosu (ChildProfileId FK, ItemId FK, EquippedAt)
- **NOT**: Coin sistemi YOK - Mevcut `ChildProfile.TotalCoins` alanı puan deposu olarak kullanılır
- AvatarService: 
  - GetAvailableItems() - Satın alınabilir items
  - PurchaseItem(childId, itemId) - Puan kontrolü + owned_items'a ekle
  - EquipItem(childId, itemId) - Equipped_items güncelle
  - UnequipItem(childId, itemId)
  - GetChildAvatar(childId) - Equipped items listesi
- AvatarController: 
  - `GET /api/avatar/items` - Mağaza item listesi
  - `GET /api/avatar/child/{childId}/owned` - Sahip olunan items
  - `GET /api/avatar/child/{childId}/equipped` - Equipped items
  - `POST /api/avatar/child/{childId}/purchase/{itemId}` - Satın alma (puan düş)
  - `POST /api/avatar/child/{childId}/equip/{itemId}` - Equip
  - `DELETE /api/avatar/child/{childId}/unequip/{itemId}` - Unequip

### İçerik İşleri
- Başlangıç avatar seti (default görünüm)
- İlk mağaza item listesi (10-15 item):
  - Şapkalar (50-100 puan)
  - Gözlükler (75 puan)
  - Kıyafetler (150-200 puan)
  - Aksesuarlar (100 puan)
  - Arka planlar (250 puan)
- Item kategorilendirmesi

### İş Kuralları
- **Puan Kaynağı**: Quiz tamamlama (her doğru cevap: +10 puan)
- **Satın Alma**: `ChildProfile.TotalCoins >= Item.PointCost` kontrolü
- **Puan Düşümü**: Başarılı satın almada `TotalCoins -= PointCost`
- **Tekrar Satın Alma Engeli**: Aynı item için `child_owned_items` kontrolü
- **Equip Limiti**: Her ItemType için sadece 1 item equipped olabilir
- **Başlangıç Bonus**: Yeni profillere 100 başlangıç puanı

### Test İşleri
- Puan yeterliliği kontrol testleri
- Satın alma işlemi ve puan düşümü testi
- Yetersiz puan senaryosu (hata mesajı)
- Tekrar satın alma engelleme testi
- Equip/Unequip kalıcılığı testleri
- ItemType conflict testi (aynı tipte 2 item equip edilemez)

### Çıktılar
- Kullanıcı quiz çözerek puan kazanır
- Puan ile avatar aksesuarları satın alır
- Avatarını istediği gibi özelleştirebilir
- Equipped items kalıcı olarak saklanır ve gösterilir

---

## Sprint 5 – Leaderboard ve SignalR Altyapısı ✅ TAMAMLANDI (2814f8f)
### Amaç
Gerçek zamanlı yapının temelini kurmak.

### Frontend İşleri
- Leaderboard ekranı
- Kullanıcının sırasını gösterme
- Canlı skor güncellemelerini dinleme
- SignalR bağlantı yönetimi

### Backend İşleri
- SignalR hub kurulumu
- connection mapping
- online presence mantığı
- leaderboard hesaplama servisi
- leaderboard API + realtime push yapısı

### Veritabanı İşleri
- leaderboard_entries tablosu
- gerekli indeksler

### Test İşleri
- Çoklu bağlantı testleri
- Leaderboard güncelleme testleri
- Bağlantı kopma / tekrar bağlanma testleri

### Çıktılar
- Canlı leaderboard çalışır
- Online kullanıcı temel görünümü oluşur

---

## Sprint 6 – 1v1 Canlı Matematik Yarışı ✅ TAMAMLANDI (3b09aa9 + 62a1b54)
### Amaç
MVP’nin en dikkat çekici canlı rekabet özelliğini eklemek.

### Frontend İşleri
- Yarış başlat ekranı
- Rakip aranıyor ekranı
- Canlı yarış ekranı
- Rakip skor alanı
- Zaman göstergesi
- Yarış sonucu ekranı

### Backend İşleri
- matchmaking queue mantığı
- match request yönetimi
- match session oluşturma
- yarış soru seti üretimi
- canlı cevap işleme
- gerçek zamanlı skor yayını
- timeout / forfeit mantığı

### Veritabanı İşleri
- match_requests tablosu
- match_sessions tablosu
- match_participants tablosu
- match_questions tablosu
- match_answers tablosu

### İş Kuralları
- aynı veya yakın seviye eşleştirme
- 5 veya 10 soruluk kısa maç
- server authoritative scoring
- bağlantı koparsa kısa bekleme süresi
- dönmeyen oyuncu için mağlubiyet

### Test İşleri
- Eşleşme testleri
- Maç başlatma ve bitirme testleri
- Skor tutarlılığı testleri
- Disconnect senaryoları

### Çıktılar
- Kullanıcı canlı 1v1 yarış yapabilir

---

## Sprint 7 – Ebeveyn Raporları ve Güvenlik Kontrolleri
### Amaç
Ebeveyn tarafını görünür hale getirmek ve çocuk güvenliğini güçlendirmek.

### Frontend İşleri
- Ebeveyn dashboard ekranı
- Günlük aktivite özeti
- Haftalık ilerleme özeti
- Güçlü / zayıf konu widget’ları

### Backend İşleri
- performans özet servisleri
- weak-topic analizi
- activity log aggregation
- parental control flag yapıları

### Güvenlik İşleri
- nickname doğrulama / filtreleme
- çocuk sosyal özellik erişim kontrolü
- rol bazlı yetki kontrolleri
- rate limiting iyileştirmeleri

### Test İşleri
- Rapor tutarlılığı testleri
- Erişim yetkisi testleri
- Güvenlik senaryoları

### Çıktılar
- Ebeveyn ilerlemeyi görebilir
- Sosyal taraf daha güvenli hale gelir

---

## Sprint 8 – Stabilizasyon, Performans ve Yayın Hazırlığı
### Amaç
Sistemi pilot kullanıma hazır hale getirmek.

### Teknik İşler
- Bug fixing
- Performans ölçümü
- Kritik sorgu optimizasyonu
- Loglama ve monitoring iyileştirmeleri
- Crash senaryolarının ele alınması

### Mobil İşleri
- UX polish
- Hata mesajları iyileştirmesi
- Loading ve empty-state düzenlemeleri

### Backend İşleri
- API hardening
- timeout ayarları
- SignalR reconnect iyileştirmeleri
- deployment pipeline iyileştirmeleri

### Release İşleri
- Test checklist
- Pilot kullanıcı senaryoları
- app store / play store hazırlık notları
- sürümleme ve release notları

### Çıktılar
- Pilot yayına uygun MVP sürümü

---

## 11.1 MVP Genişletme Adayları: Bilge-Dost ve World Events

Bu bölüm, mevcut MVP omurgasını bozmadan iki yeni motivasyon mekanizmasını kontrollü ve ölçülebilir şekilde eklemek için hazırlanmıştır.

### A. Dijital Evcil Hayvan / Sınıf Arkadaşı (Bilge-Dost)

#### Amaç
- Çocuğun motivasyonunu sadece puandan değil, sorumluluk ve duygusal bağ üzerinden artırmak
- Küçük yaş gruplarında düzenli kullanım alışkanlığı oluşturmak

#### MVP V1 Kapsamı (Basit ve Hızlı)
- Ana ekranda görünen tek bir maskot/evcil arkadaş
- 3 temel durum: Enerji, Mutluluk, XP
- Doğru cevap ve quiz tamamlama sonrası durum artışı
- Seviye eşikleri: 10, 20, 50 (evrim aşaması)
- Evcil hayvan asla ölmez; sadece yorgun/uykulu görünür

#### Teknik Tasarım
- Yeni tablo: `pet_states`
  - `Id`, `ChildId` (FK), `Level`, `Xp`, `Energy`, `Happiness`, `EvolutionStage`, `LastInteractionAt`
- Servis katmanı: `IPetService` / `PetService`
  - `ApplyAnswerResultAsync(childId, isCorrect)`
  - `ApplyQuizCompletedAsync(childId, correctCount, totalQuestions)`
  - `GetPetStateAsync(childId)`
- API endpointleri (öneri)
  - `GET /api/pet/child/{childId}`
  - `POST /api/pet/child/{childId}/feed` (opsiyonel, coin veya ödül ile)
- Entegrasyon noktası
  - Quiz sonuç kaydı sırasında mevcut progress akışına hook (puan/coin güncellemesi ile aynı transaction sınırında veya güvenli şekilde ardıl işlem)

#### Flutter Uygulama Notları
- Dashboard üzerinde `Bilge-Dost Kartı`
- İlk sürüm: statik görseller + basit animasyon (zıplama/sevinme)
- İkinci sürüm: Lottie veya sprite sheet ile evrim animasyonları

#### Kabul Kriterleri
- Doğru cevap sonrası pet XP artmalı
- Quiz tamamlanınca enerji/mutluluk güncellenmeli
- Pet enerji düşse de kaybolmamalı/ölmemeli
- Seviye 10/20/50 geçişlerinde evrim aşaması doğru değişmeli

### B. Sosyal ve İşbirlikçi Görevler (World Events)

#### Amaç
- Tekil rekabet stresini azaltmak
- Topluluk hissi ile düzenli katılımı artırmak

#### MVP V1 Kapsamı (Basit Global Hedef)
- Haftalık tek bir global hedef
- Örnek: "Bu hafta toplam 50.000 doğru cevap"
- Tüm kullanıcılar ortak ilerleme barına katkı sağlar
- Hedef tamamlanınca herkese ortak ödül (coin veya kozmetik)

#### Teknik Tasarım
- Yeni tablolar:
  - `community_events` (`Id`, `Name`, `GoalType`, `GoalValue`, `CurrentValue`, `StartsAt`, `EndsAt`, `Status`, `RewardType`, `RewardValue`)
  - `community_event_contributions` (`Id`, `EventId`, `ChildId`, `Contribution`, `ContributedAt`, `SourceType`)
- Servis katmanı: `ICommunityEventService` / `CommunityEventService`
  - `ApplyContributionAsync(childId, isCorrect, topicId)`
  - `GetActiveEventAsync()`
  - `FinalizeExpiredEventsAsync()`
- Realtime yayın
  - SignalR üzerinden `CommunityGoalUpdated` eventi
  - Mobilde küçük "topluluk katkısı" bildirimleri
- Zamanlanmış görev
  - Başlangıç: `BackgroundService` ile periyodik kontrol
  - Sonraki aşama: Hangfire/Quartz.NET ile haftalık reset + otomatik ödül dağıtımı

#### Ebeveyn Raporu ile Sinerji (MVP+)
- Global hedef bir konuya odaklıysa, çocuk o konuda zayıfsa katkı çarpanı (2x) uygulanabilir
- Zayıf konu verisi mevcut parent reporting akışından türetilir

#### Kabul Kriterleri
- Aktif event varsa doğru cevaplar global sayacı artırmalı
- Tüm bağlı istemcilerde ilerleme barı güncellenmeli
- Event süresi dolunca durum kapanmalı ve ödüller otomatik dağıtılmalı
- Aynı çocuğa aynı event ödülü ikinci kez verilmemeli

### Önerilen Uygulama Sıralaması

#### Sprint 8.1 – Bilge-Dost V1
- `pet_states` veri modeli ve migration
- Pet servis + API
- Quiz/progress akışına pet update entegrasyonu
- Dashboard pet kartı

#### Sprint 8.2 – World Events V1
- Community event veri modeli ve migration
- Event servis + contribution endpointleri
- SignalR event progress yayını
- Mobilde global hedef progress kartı

#### Sprint 8.3 – Otomasyon ve Dengeleme
- Haftalık reset/ödül dağıtım job'u
- Telemetri ve dengeleme (hedef değeri, ödül miktarı, katılım oranı)
- Gerekirse Redis cache optimizasyonu

---

## 12. Epic Bazlı Backlog Yapısı

## Epic 1 – Kimlik ve Profil Yönetimi
- Ebeveyn kayıt / giriş
- JWT tabanlı auth
- Çocuk profil oluşturma
- Profil listeleme ve seçme

## Epic 2 – Matematik Eğitim Motoru
- Ders / konu / level yönetimi
- Soru sunum yapısı
- Cevap değerlendirme
- Sonuç ekranı

## Epic 3 – Progress ve Level Yönetimi
- İlerleme kayıtları
- Puan / yıldız sistemi
- Level unlock mantığı
- Tekrar çözüm desteği

## Epic 4 – Oyunlaştırma ve Ödüller
- Coin wallet
- Reward transaction
- Bölüm ödülleri
- Gelecekte rozet altyapısı

## Epic 5 – Avatar ve Mağaza
- Avatar verisi
- Item listesi
- Satın alma
- Envanter / equip

## Epic 6 – Leaderboard ve Realtime
- Leaderboard hesaplama
- SignalR hub
- Presence yönetimi
- Canlı güncelleme

## Epic 7 – Canlı Yarış
- Matchmaking
- Match session
- Soru seti eşleme
- Canlı skor
- Sonuç ekranı

## Epic 8 – Ebeveyn Raporlama
- Aktivite özeti
- Konu bazlı başarı analizi
- Haftalık ilerleme

## Epic 9 – Güvenlik ve Stabilizasyon
- Nickname filtreleme
- Rol bazlı yetki
- Rate limiting
- Performans ve hata iyileştirmeleri

## 13. Önceliklendirme

## Must Have
- Auth ve profil
- Matematik soru akışı
- Progress sistemi
- Coin ve avatar mantığı
- Leaderboard
- 1v1 canlı yarış
- Temel ebeveyn raporları

## Should Have
- Görev sistemi
- Rozet altyapısı
- Presence görünümü

## Could Have
- İngilizce modülü başlangıcı
- Gelişmiş eşleştirme kuralları
- Sezon bazlı etkinlikler

## Won’t Have in MVP
- Açık sohbet
- Grup turnuvaları
- AI destekli koçluk
- Gelişmiş arkadaş ağı

---

---

## Sprint 9 – PostgreSQL Migration (SQLite → PostgreSQL) ✅ TAMAMLANDI
### Amaç
Development süresince kullanılan SQLite veritabanını production-ready PostgreSQL'e taşımak.

### Ön Hazırlık İşleri (3 task)
- Docker Compose'da PostgreSQL service tanımı (port: 5432)
- NuGet package güncelleme: `Microsoft.EntityFrameworkCore.Sqlite` → `Npgsql.EntityFrameworkCore.PostgreSQL` (8.0.4)
- Connection string yapılandırması (appsettings.json, appsettings.Development.json, appsettings.Production.json)

### Backend Kod Değişiklikleri (4 task)
- Program.cs: `UseSqlite()` → `UseNpgsql()` değişikliği
- Mevcut SQLite migration'larını SİL, PostgreSQL için yeniden oluştur (InitialCreate, AddEducationEntities)
- Entity configurations: Data type uyumluluğu (TEXT → VARCHAR, DATETIME → TIMESTAMP, GUID → UUID)
- Data seeder PostgreSQL uyumluluğu kontrolü

### Test & Doğrulama (5 task)
- Docker container başlatma ve health check (`docker-compose up -d postgres`)
- Migration uygulama (`dotnet ef database update`) ve tablo kontrolü
- Data seeding test (25 soru + test kullanıcısı)
- API endpoint testleri (Swagger'da tüm 14 endpoint)
- Performance & index optimizasyonu (foreign key indexes, query performance)

### Production Hazırlığı (3 task)
- Environment variables setup (DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD)
- Backup & restore stratejisi (pg_dump script, otomatik backup planı)
- Documentation güncellemesi (README.md, project-state.md)

### Kritik Kontrol Noktaları
- **GUID → UUID mapping**: PostgreSQL'de UUID type kullanılmalı
- **DateTime → TIMESTAMP**: Timezone aware yapılandırma
- **String length**: VARCHAR(x) limitleri belirlenmeli
- **Connection pool**: Npgsql connection pool ayarları
- **Migration naming**: Tüm migration'lar PostgreSQL için clean slate

### Çıktılar
- ✅ Production-ready PostgreSQL database
- ✅ Docker Compose ile kolay deployment
- ✅ Backup/restore mekanizması hazır
- ✅ Tüm veriler SQLite'dan PostgreSQL'e taşınmış
- ✅ Performance optimize edilmiş

### Notlar
- Bu sprint SADECE database geçişi içerdi, yeni feature eklenmedi
- Sprint 1-8 tamamlandıktan sonra uygulandı
- Migration testleri staging ortamında doğrulandı

---

## Sprint 10 – LaTeX Tabanlı Matematik Notasyonu ve Görsel Soru Desteği
### Amaç
Geometri, kesir, köklü ifade, üslü sayı gibi görsel gösterim gerektiren soruların uygulamada doğru biçimde render edilmesini sağlamak. Şu an bu tür sorular plain text olarak tutuluyor ve kullanıcı soruyu anlayamıyor.

### Sorun Tanımı
`QuestionText` ve `OptionText` alanları yalnızca düz metin destekliyor. Kesir (½), köklü ifade (√16), üslü sayı (5²), açı gösterimi (∠ABC = 60°) ve geometri soruları düzgün görüntülenemiyor.

### Çözüm Yaklaşımı
- Soru metni içine LaTeX markup gömerimi (`$...$` inline, `$$...$$` blok)
- Flutter tarafında `flutter_math_fork` paketi ile rendering
- DB'ye minimal değişiklik: sadece `has_latex` boolean flag eklenir
- Mevcut `QuestionText` ve `OptionText` alanları korunur, içerik LaTeX söz dizimi kullanır

### DB Değişiklikleri
```sql
ALTER TABLE questions ADD COLUMN "HasLatex" BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE question_options ADD COLUMN "HasLatex" BOOLEAN NOT NULL DEFAULT FALSE;
```
- `HasLatex = true` olan sorular için Flutter LaTeX renderer tetiklenir
- `HasLatex = false` olanlarda mevcut düz Text widget kullanılmaya devam eder

### Örnek Soru Formatları
| Soru Tipi | QuestionText örneği |
|---|---|
| Kesir | `$\frac{3}{4} + \frac{1}{4}$ işleminin sonucu kaçtır?` |
| Köklü ifade | `$\sqrt{144}$ işleminin sonucu kaçtır?` |
| Üslü sayı | `$5^2 + 3^2$ işleminin sonucu kaçtır?` |
| Açı | `Bir üçgende $\angle A = 90°$, $\angle B = 45°$ ise $\angle C$ kaç derecedir?` |
| Alan | `Kenar uzunluğu $6$ cm olan karenin alanı $A = kenar^2$ formülüyle kaç $cm^2$'dir?` |

### Backend İşleri
- `Question` entity'sine `HasLatex` property eklenmesi
- `QuestionOption` entity'sine `HasLatex` property eklenmesi
- EF Core migration oluşturulması
- İlgili DTO'lara (`QuestionDto`, `QuestionOptionDto`, `MatchQuestionDto`) `HasLatex` alanı eklenmesi
- Yeni LaTeX içerikli soruların import script'ine eklenmesi (örnek geometri soruları)

### Flutter İşleri
- `flutter_math_fork` paketi `pubspec.yaml`'a eklenmesi
- `MathText` adında paylaşılan bir widget oluşturulması:
  - `hasLatex: true` ise `$...$` inline blokları `Math.tex()` ile, düz text kısımları `Text()` ile render eder
  - `hasLatex: false` ise doğrudan `Text()` widget'ı döner
- `match_arena_screen.dart`: Soru metni ve seçeneklerde `Text(...)` yerine `MathText(...)` kullanılması
- `question_screen.dart` (learning flow): Aynı widget ile güncellenmesi
- Match modellerine `hasLatex` alanı eklenmesi (`match_models.dart`)

### İçerik İşleri
- 3. ve 4. sınıf geometri sorularının LaTeX formatında yazılması/düzenlenmesi
- Kesir sorularının LaTeX formatına dönüştürülmesi
- Import SQL script'lerine `HasLatex = true` ile örnek soru seti eklenmesi

### Kabul Kriterleri
- LaTeX içerikli soru metni uygulamada hatasız render edilmeli
- Plain text sorular mevcut görünümünü korumali
- Maç ekranında LaTeX soruları hem oyuncuya hem rakibe aynı görünmeli
- Desteklenmeyen LaTeX komutu durumunda fallback olarak raw text gösterilmeli
- `HasLatex = false` olan soruların performansı etkilenmemeli

### Test İşleri
- `HasLatex = true / false` render branch testleri
- Farklı LaTeX tipleri (kesir, kök, üs, açı) için render doğrulaması
- Maç akışında LaTeX sorularının doğru soru geçişi
- Import script ile DB'ye yüklenen LaTeX sorularının API'den doğru dönmesi

### Teknik Notlar
- `flutter_math_fork`: KaTeX tabanlı, `Math.tex(r'...')` ile kullanılır
- Inline parsing için basit bir regex: `\$([^$]+)\$` → `Math.tex()` widget'ına geçilir
- Blok LaTeX (`$$...$$`) soru kartında ortalanmış, büyük fontla gösterilir
- İlerde SVG/resim tabanlı geometri şekilleri gerekirse `diagram_url` alanı bu sprint'e bağımsız olarak ayrı bir sprint'te eklenebilir

### Çıktılar
- Geometri, kesir, üslü sayı, köklü ifade içeren sorular uygulamada doğru görünür
- Öğretmen / içerik girişi LaTeX söz dizimi ile yapılabilir hale gelir
- Soru havuzu daha zengin matematik içeriğini destekler

---

## Sprint 11 – Ses Efektleri ve Animasyonlar
### Amaç
Kullanıcı etkileşimini görsel ve işitsel geri bildirimle zenginleştirerek uygulamanın eğlenceli hissini artırmak. Doğru/yanlış cevap, combo, seviye atlama gibi anlarda çocuğun ödüllendirildiğini hissettirmek.

### Kapsam
Sıfır ses efekti olan mevcut uygulamaya temel ses altyapısı ve animasyon katmanı eklenmesi.

### Flutter İşleri

#### Ses Efektleri
- `audioplayers` paketi `pubspec.yaml`'a eklenmesi
- `SoundService` singleton servisi oluşturulması:
  - `playCorrect()` — doğru cevap sesi
  - `playWrong()` — yanlış cevap sesi
  - `playCombo()` — üst üste 3+ doğru cevap
  - `playLevelUp()` — seviye atlama
  - `playMatchWin()` — maç kazanma
  - `playMatchLose()` — maç kaybetme
  - `playButtonTap()` — genel buton sesi
- `assets/sounds/` klasörüne ses dosyalarının eklenmesi (royalty-free .mp3)
- `pubspec.yaml`'a `assets/sounds/` kaydı
- Ebeveyn ses kısma ayarı: `SharedPreferences`'da `sound_enabled` flag

#### Animasyonlar
- Doğru cevap: yeşil ✓ overlay + kısa scale-up animasyonu (`AnimatedContainer` / `TweenAnimationBuilder`)
- Yanlış cevap: kırmızı ✗ overlay + hafif sarsma animasyonu (`Transform.translate` + titreme)
- Combo göstergesi: `quiz_screen.dart`'ta üst üste 3+ doğru cevap → "🔥 3'lü Combo!" `SnackBar` veya overlay
- Konfeti animasyonu: `confetti` paketi ile quiz/maç tamamlama ekranında
- Buton press efekti: `GestureDetector` + `AnimatedScale` ile tüm primary butonlara

#### Entegrasyon Noktaları
- `quiz_screen.dart`: doğru/yanlış cevap handler'larına ses + animasyon eklenmesi
- `match_arena_screen.dart`: aynı ses/animasyon entegrasyonu
- `quiz_result_screen.dart`: konfeti + kazanma/kaybetme sesi
- `match_result_screen.dart`: konfeti + maç sesleri

### Ses Dosyaları (İçerik İşi)
- `correct.mp3` — kısa, pozitif ses (1-2 sn)
- `wrong.mp3` — nazik, kısa ses (1 sn)
- `combo.mp3` — coşkulu ses (1-2 sn)
- `level_up.mp3` — zafer fanfar (2-3 sn)
- `win.mp3` — maç kazanma (3 sn)
- `lose.mp3` — maç kaybetme (2 sn)
- `tap.mp3` — genel buton tıklama (0.2 sn)
- Kaynak önerileri: freesound.org, mixkit.co (CC0 lisanslı)

### Kabul Kriterleri
- Doğru cevapta yeşil animasyon + ses çalar
- Yanlış cevapta kırmızı animasyon + ses çalar
- 3 üst üste doğru cevap combo göstergesi tetiklenir
- Quiz/maç tamamlamada konfeti görünür
- Ses kısık modda hiçbir ses çalmaz
- Ses başlatma gecikme süresi < 100ms (kullanıcı hissini bozmaz)

### Test İşleri
- Ses servisi başlatma testi
- `sound_enabled = false` durumunda ses çalınmaması testi
- Animasyon widget'larının doğru tetiklendiğinin doğrulanması

### Çıktılar
- Uygulama ses ve animasyonlarla hayat bulur
- Çocuklar doğru/yanlış anında anlık görsel+işitsel geri bildirim alır
- Kombolar motivasyonu artırır
- Ebeveynler ses kapatabilir

---

## Sprint 12 – Günlük Streak ve Push Notification
### Amaç
Günlük kullanım alışkanlığı oluşturmak. Çocukların uygulamayı her gün açmasını sağlayan streak (zincir) sistemi ve push notification ile geri çağırma mekanizması kurmak.

### Flutter İşleri

#### Streak Sistemi
- `StreakService` oluşturulması:
  - `checkAndUpdateStreak()` — uygulama açılışında çağrılır; bugün quiz çözüldüyse streak devam ettirilir
  - `getCurrentStreak()` → kaç günlük zincir
  - `getLongestStreak()` → en uzun zincir rekoru
- `SharedPreferences`'da `last_activity_date` + `current_streak` + `longest_streak` saklanması
- Dashboard'da streak göstergesi: `🔥 5 Günlük Zincir` widget'ı
- Streak kırılma uyarısı: o gün hiç soru çözülmemişse app açılışında `"Zincirini kaybetme! Bugün 1 soru yeterli 🔥"` dialog'u

#### Günlük Görev Kartı
- Dashboard'a `DailyQuestCard` widget'ı eklenmesi:
  - "Bugünkü Görev: 5 soru çöz"
  - Progress bar: 3/5 gibi ilerleme
  - Tamamlandığında: ✅ animasyonu + `+50 puan` kazanım
- `SharedPreferences`'da günlük ilerleme takibi (`daily_quest_date` + `daily_quest_progress`)

#### Push Notification
- `firebase_messaging` paketi eklenmesi
- `FirebaseMessaging.instance.getToken()` ile cihaz token'ı alınıp backend'e kaydedilmesi
- Notification permission isteği (iOS için `requestPermission()`)
- Foreground notification handler (`FirebaseMessaging.onMessage`)
- Background / terminated handler (`FirebaseMessaging.onBackgroundMessage`)
- Bildirim geldiğinde ilgili ekrana yönlendirme (deep link)

### Backend İşleri
- `device_tokens` tablosu: `ChildProfileId`, `Token`, `Platform`, `CreatedAt`, `UpdatedAt`
- `POST /api/notifications/register` — cihaz token kaydetme endpoint'i
- Firebase Admin SDK entegrasyonu (Google Cloud için zaten servis hesabı mevcut)
- `NotificationService`:
  - `SendDailyReminderAsync(childProfileId)` — akşam 18:00 bildirim
  - `SendStreakWarningAsync(childProfileId)` — günlük görev yapılmamışsa
- Scheduled job (Hangfire veya Cloud Scheduler + HTTP trigger):
  - Her gün 18:00'de aktif child profillere "Bugünkü görevini yapmayı unutma!" bildirimi
  - Her gün 20:00'de streak'i tehlikede olanlara uyarı bildirimi

### DB Değişiklikleri
```sql
CREATE TABLE device_tokens (
    "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "ChildProfileId" UUID NOT NULL REFERENCES child_profiles("Id") ON DELETE CASCADE,
    "Token" TEXT NOT NULL,
    "Platform" VARCHAR(10) NOT NULL DEFAULT 'ios',
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_device_tokens_child ON device_tokens("ChildProfileId");
```

### Kabul Kriterleri
- İlk girişte notification izni istenir (iOS)
- Her gün quiz çözüldüğünde streak artar
- 1 gün atlandığında streak sıfırlanır
- Dashboard'da streak sayısı görünür
- Günlük görev kartı ilerleme gösterir, tamamlandığında puan eklenir
- Akşam saatlerinde push bildirim gelir

### Test İşleri
- Streak hesaplama: ardışık gün, gün atlama, sıfırlama senaryoları
- Günlük görev ilerleme ve tamamlama testi
- Push notification token kaydı testi
- Scheduled job tetikleme testi

### Çıktılar
- Kullanıcılar her gün uygulamaya geri döner
- Streak görsel motivasyon sağlar
- Push bildirimler pasif kullanıcıları geri çağırır
- Günlük görev tamamlama ek puan ile ödüllendirilir

---

## Sprint 14 – İngilizce Modülü (CEFR Sistemi) ✅ TAMAMLANDI
### Amaç
Uygulamaya ikinci bir eğitim modülü olarak İngilizce derslerini eklemek. CEFR seviye sistemi (A1–C2) ile İngilizce konularını ayrı bir subject olarak sunmak; matchmaking'i ders bazında genişletmek.

### Tamamlanan İşler ✅

#### Backend
- `EnglishLevel` enum oluşturuldu (`A1=1, A2=2, B1=3, B2=4, C1=5, C2=6`)
- `ChildProfile.EnglishLevel` alanı eklendi (nullable int)
- `Topic.EnglishLevel` alanı eklendi; `Topic.GradeLevel` nullable yapıldı
- İlgili DTO'lar güncellendi (`ChildProfileDto`, `CreateChildProfileRequest`, `TopicDto`)
- `ChildProfileService`: create/update/mapToDto güncellendi, `GetEnglishLevelText()` eklendi
- `EducationService`: TopicDto mapping'e `EnglishLevel` eklendi
- `MatchmakingService`: İngilizce için CEFR bazlı eşleşme + `SelectEnglishMatchQuestionsAsync()` eklendi
- Repository interfaceleri ve implementasyonları: `GetPendingMatchRequestsByEnglishLevelAsync()`, `GetTopicsByEnglishLevelAsync()` eklendi
- `MatchController`: `RequestMatchDto.SubjectId` eklendi
- Seeder: İngilizce subject kaydı idempotent olarak ekleniyor (topicler ve sorular manuel)

#### Flutter
- `EnglishLevel` enum oluşturuldu (`fromValue()`, `fromString()`, `displayName`)
- `ChildProfileDto.englishLevel` + `englishLevelEnum` extension eklendi
- `CreateChildProfileRequest` ve `UpdateChildProfileRequest`: `int? englishLevel` eklendi (freezed)
- `child_profile_form_screen.dart`: CEFR dropdown eklendi
- `child_profile_list_screen.dart` ve `child_profile_selection_screen.dart`: englishLevel badge gösterimi
- `Topic` modeli: `int? englishLevel` eklendi (freezed)
- `topic_selection_screen.dart`: CEFR badge (A1/A2 pill), İngilizce topic ikonları
- `match_subject_select_screen.dart`: Yeni ekran — ders seçimi (Matematik/İngilizce)
- `match_request_screen.dart`: `subjectId` ve `subjectName` parametreleri eklendi
- `match_provider.dart` ve `match_service.dart`: `subjectId` parametresi eklendi
- `app_router.dart`: `/match/subject-select` route eklendi
- `dashboard_screen.dart`: Hardcoded Matematik butonu → dinamik subject loop
- `QuestionType` enum değerleri düzeltildi (0'dan başlıyor — `main`'e commit: `3ab7ee6`)

#### Commit
- `e66cf9a` — Sprint 14 değişiklikleri (`english_course_add` branch)
- `3ab7ee6` — QuestionType bug fix (`main` branch)

### Bekleyen İşler ⏳

#### DB ✅
```sql
ALTER TABLE child_profiles ADD COLUMN IF NOT EXISTS "EnglishLevel" integer;  -- ✅ uygulandı
ALTER TABLE topics ADD COLUMN IF NOT EXISTS "EnglishLevel" integer;           -- ✅ uygulandı
ALTER TABLE topics ALTER COLUMN "GradeLevel" DROP NOT NULL;                   -- ✅ uygulandı
```

#### Backend Deploy ✅
- `main` branch Cloud Run'a deploy edildi

#### İngilizce İçerik
- Numbers konusu: 15 soru DB'ye eklendi ✅ (manuel SQL ile)
- Diğer İngilizce konuları ve seviyeleri için içerik eklenmesi devam edecek

#### Test ✅
- Numbers quiz testi yapıldı ✅
- CEFR bazlı matchmaking uçtan uca testi ⏳ (ileride)

### Branch Durumu
- `english_course_add` → `main` merge tamamlandı ✅
- Sprint 14 tamamen kapatıldı ✅

---

## Sprint 13 – Avatar Mağazası Genişletme ve Coin Sistemi
### Amaç
Mevcut avatar sistemini (Sprint 4) daha zengin ve bağımlılık yaratan hale getirmek. Coin'leri ayrı bir para birimi olarak puandan ayırmak; streak, daily quest ve maç kazanımları ile coin kazandırmak. Mağazayı periyodik olarak yenilenen "öne çıkan ürün" ile canlı tutmak.

### Kapsam Değişikliği — Coin vs Puan Ayrımı
Şu an `TotalCoins` alanı puan deposu olarak kullanılıyor. Bu sprint'te:
- **Puan (Score)**: Quiz performansı, leaderboard sıralaması için
- **Coin**: Mağaza para birimi; streak, daily quest, maç kazanımı ile kazanılır

### DB Değişiklikleri
```sql
-- child_profiles tablosuna coin alanı ekle
ALTER TABLE child_profiles ADD COLUMN "TotalCoinsV2" INTEGER NOT NULL DEFAULT 0;

-- coin_transactions tablosu (kazanım geçmişi)
CREATE TABLE coin_transactions (
    "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "ChildProfileId" UUID NOT NULL REFERENCES child_profiles("Id") ON DELETE CASCADE,
    "Amount" INTEGER NOT NULL, -- pozitif: kazanım, negatif: harcama
    "Reason" VARCHAR(50) NOT NULL, -- 'daily_quest', 'streak_bonus', 'match_win', 'purchase'
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- avatar_items tablosuna yeni alanlar
ALTER TABLE avatar_items ADD COLUMN "CoinCost" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE avatar_items ADD COLUMN "IsSpecial" BOOLEAN NOT NULL DEFAULT FALSE; -- sezonluk/özel item
ALTER TABLE avatar_items ADD COLUMN "AvailableUntil" TIMESTAMPTZ NULL; -- NULL = her zaman mevcut
```

### Flutter İşleri

#### Coin Widget'ı
- Dashboard top bar'a coin göstergesi: `🪙 120` (puan göstergesinin yanına)
- Coin kazanıldığında floating `+10 🪙` animasyonu

#### Mağaza Yenilikleri
- Mağaza ekranına "Öne Çıkan" banner bölümü (sınırlı süreli item)
- Item kartlarında puan vs coin fiyat gösterimi
- "Yakında Geliyor" kilitli item placeholder'ları (merak uyandırır)
- Satın alma sonrası `+equip` kısayolu: "Hemen giy?" dialog'u

#### Coin Kazanım Noktaları (Sprint 12 ile entegre)
- Günlük görev tamamlama: `+50 coin`
- 3 günlük streak: `+20 coin` bonus
- 7 günlük streak: `+100 coin` bonus
- Maç kazanma: `+30 coin`
- Maç kaybetme: `+5 coin` (katılım ödülü)
- İlk quiz tamamlama (günlük): `+10 coin`

### Backend İşleri
- `CoinService`:
  - `AddCoins(childId, amount, reason)` — coin ekle + transaction kaydet
  - `SpendCoins(childId, amount, reason)` — coin düş + yeterlilik kontrolü
  - `GetBalance(childId)` → mevcut coin miktarı
  - `GetTransactionHistory(childId)` → kazanım geçmişi
- Avatar purchase endpoint'inin coin sistemi ile güncellenmesi
- `GET /api/avatar/items` response'una `CoinCost` ve `IsSpecial` eklenmesi
- Maç sonucu endpoint'ine coin ödülü tetikleme eklenmesi

### Kabul Kriterleri
- Dashboard'da coin bakiyesi görünür
- Günlük görev tamamlama ve streak bonusları coin kazandırır
- Maç kazanma coin kazandırır
- Mağazadan coin ile item satın alınabilir
- Coin yetersizse anlaşılır hata mesajı gösterilir
- Coin kazanımında animasyonlu geri bildirim görünür

### Test İşleri
- Coin kazanım senaryoları (daily quest, streak, maç)
- Yetersiz coin ile satın alma girişimi
- Coin transaction geçmişi doğruluğu
- Aynı item iki kez satın alınamama

### Çıktılar
- Çocuklar coin kazanmak için uygulamaya geri döner
- Avatar mağazası sürekli değişen içerikle canlı kalır
- Puan (performans) ve coin (ekonomi) sistemi birbirinden ayrışır
- Koleksiyon yapma güdüsü oluşur

---

---

## Sprint 17 – Rozet Sistemi + Karakter Kartı Koleksiyonu (Mağaza Yerine)

### Neden Bu Değişiklik?

Avatar mağazası iki temel sorunu çözemiyor:
1. **Teknik**: Satın alınan item'lar avatarın üzerine doğru konumlanmıyor, görsel kalite yetersiz.
2. **Motivasyon**: Çocuklar için "para biriktir, item al" döngüsü yeterince heyecan verici değil — bir kez aldıktan sonra motivasyon düşüyor.

**Yeni yaklaşım:** Avatar mağazası kaldırılır. Yerine iki birbirini tamamlayan sistem gelir:
- **Rozet Sistemi**: Başarıları simgeleyen kalıcı rozetler — profilde sergilenir, statü göstergesidir.
- **Karakter Kartı Koleksiyonu**: Soru çözdükçe rastgele kazanılan kartlar — nadir kartlar merak ve koleksiyon güdüsü yaratır.

### Hedef

- Çocukları her gün uygulamaya çeken, koleksiyon tamamlama güdüsü yaratan bir ödül sistemi
- Avatar item konumlandırma teknik sorununu tamamen ortadan kaldır
- Mağaza UI karmaşıklığını kaldırıp yerine daha ilgi çekici iki ekran koy

---

### 17.1 Rozet Sistemi

#### Rozet Kategorileri

| Kategori | Rozet Adı | Tetikleyici |
|----------|-----------|-------------|
| 📚 Öğrenme | İlk Adım | İlk quiz tamamlama |
| 📚 Öğrenme | Konu Ustası | Bir konunun tüm seviyelerini tamamla |
| 📚 Öğrenme | Mükemmeliyetçi | Herhangi bir seviyeyi %100 başarıyla bitir |
| 📚 Öğrenme | Çalışkan Arı | Tek günde 3 farklı konu çalış |
| ⚡ Hız | Şimşek | Bir soruyu 5 saniyede doğru cevapla |
| ⚡ Hız | Hız Treni | Bir quizi 2 dakika altında bitir |
| 🔥 Streak | Isınıyorum | 3 günlük streak |
| 🔥 Streak | Ateş Topu | 7 günlük streak |
| 🔥 Streak | Yanmıyor | 30 günlük streak |
| ⚔️ Yarış | İlk Zafer | İlk canlı yarış galibiyeti |
| ⚔️ Yarış | Seri Katil | Arka arkaya 5 yarış kazan |
| ⚔️ Yarış | Turnuva Şampiyonu | 50 yarış kazan |
| 🧮 Matematik | Sayıların Efendisi | Matematik'te 10 konu tamamla |
| 🌍 İngilizce | Kelime Avcısı | İngilizce A1 tüm seviyeleri bitir |
| 🌍 İngilizce | CEFR Yolcusu | İngilizce B1'e ulaş |
| 🌟 Özel | Erken Kuş | İlk 100 kullanıcıdan biri |
| 🌟 Özel | Beta Kahramanı | v1.0 döneminde aktif kullanıcı |

#### Rozet Nadirlik Seviyeleri

- 🥉 **Bronz** — kolay ulaşılabilir, motivasyon başlangıcı
- 🥈 **Gümüş** — düzenli kullanım gerektiren
- 🥇 **Altın** — uzun vadeli başarı
- 💎 **Efsanevi** — çok az oyuncunun kazanabileceği

#### DB Değişiklikleri

```sql
-- Rozet tanımları
CREATE TABLE badges (
    "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "Key" VARCHAR(50) NOT NULL UNIQUE,      -- 'first_quiz', 'streak_7' gibi
    "Name" VARCHAR(100) NOT NULL,
    "Description" TEXT NOT NULL,
    "Emoji" VARCHAR(10) NOT NULL,
    "Category" VARCHAR(30) NOT NULL,         -- 'learning', 'speed', 'streak', 'match', 'special'
    "Rarity" VARCHAR(20) NOT NULL DEFAULT 'bronze', -- 'bronze', 'silver', 'gold', 'legendary'
    "IsActive" BOOLEAN NOT NULL DEFAULT TRUE,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Çocukların kazandığı rozetler
CREATE TABLE child_badges (
    "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "ChildProfileId" UUID NOT NULL REFERENCES child_profiles("Id") ON DELETE CASCADE,
    "BadgeId" UUID NOT NULL REFERENCES badges("Id"),
    "EarnedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE ("ChildProfileId", "BadgeId")
);

CREATE INDEX idx_child_badges_child ON child_badges("ChildProfileId");
```

#### Backend İşleri

- `BadgeService`:
  - `CheckAndAwardBadgesAsync(childId, triggerEvent)` — her önemli aksiyon sonrası çağrılır
  - `GetEarnedBadgesAsync(childId)` → kazanılan rozetler
  - `GetAllBadgesAsync()` → tüm rozetler (kazanılmamış = kilitli görünür)
- Trigger noktaları: quiz tamamlama, streak güncelleme, maç sonucu, seviye unlock
- `GET /api/badges` — tüm rozetler
- `GET /api/badges/child/{childId}` — kazanılan rozetler

#### Flutter İşleri

- **Rozet Koleksiyon Ekranı** (`/badges`):
  - Grid görünüm: kazanılmış renkli, kazanılmamış gri/kilitli
  - Nadirlik filtresi
  - Kazanma tarihi gösterimi
- **Rozet Kazanım Overlay**: Soru/quiz/maç sonrası "🎉 Yeni Rozet Kazandın!" tam ekran animasyonu
- **Profil Entegrasyonu**: Profil sayfasında son 3 kazanılan rozet sergilenir
- **Dashboard Entegrasyonu**: "Bu ay X rozet kazandın" mini widget

---

### 17.2 Karakter Kartı Koleksiyonu

#### Kart Sistemi Mantığı

Her doğru cevap sonrası düşük ihtimalle, her quiz tamamlandığında garantili bir kart kazanılır. Kartlar çocuk karakterlerini, hayvanları veya mini hikayeleri temsil eder. Koleksiyonu tamamlama güdüsü günlük geri dönüşü destekler.

#### Kart Nadirlik & Kazanım Oranları

| Nadirlik | Sembol | Renk | Quiz kazanım | Doğru cevap |
|----------|--------|------|-------------|-------------|
| Yaygın | ⚪ | Gri | %60 | %5 |
| Nadir | 🔵 | Mavi | %25 | %1.5 |
| Epik | 🟣 | Mor | %12 | %0.4 |
| Efsanevi | 🟡 | Altın | %3 | %0.1 |

#### Görsel Kaynağı — Kenney.nl

> ⚠️ **KOD YAZARKEN HATIRLATMA**: Kart görselleri için **[Kenney.nl](https://kenney.nl/assets)** kullanılacak.
> - Lisans: **CC0** (tamamen ücretsiz, ticari kullanım serbest, atıf gerekmez)
> - Önerilen paketler: `Animal Pack Redux`, `Character Pack`, `Creature Mixer`
> - Görseller `assets/cards/` klasörüne PNG olarak eklenmeli
> - `ImageUrl` alanı başlangıçta local asset path olacak (`assets/cards/owl.png`), ileride CDN'e taşınabilir
> - Boyut: 256x256 veya 512x512 PNG, şeffaf arka plan

#### Kart Kategorileri (İlk Sürüm — 40 kart)

- 🦊 **Hayvan Serisi** (15 kart): Baykuş, Aslan, Kaplan, Tilki, Penguen... → Kenney `Animal Pack Redux`
- 🧙 **Kahraman Serisi** (15 kart): Mini bilge karakterler, farklı meslekler → Kenney `Character Pack`
- 🌟 **Efsane Serisi** (10 kart): Tarihi figürler, bilim insanları (çocuk yorumu) → Kenney `Creature Mixer`

#### DB Değişiklikleri

```sql
-- Kart tanımları
CREATE TABLE collectible_cards (
    "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "Name" VARCHAR(100) NOT NULL,
    "Description" TEXT NOT NULL,
    "Series" VARCHAR(50) NOT NULL,           -- 'animals', 'heroes', 'legends'
    "Rarity" VARCHAR(20) NOT NULL,           -- 'common', 'rare', 'epic', 'legendary'
    "ImageUrl" TEXT NOT NULL,
    "CardNumber" INTEGER NOT NULL,           -- koleksiyon numarası
    "IsActive" BOOLEAN NOT NULL DEFAULT TRUE,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Çocukların koleksiyonu
CREATE TABLE child_cards (
    "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "ChildProfileId" UUID NOT NULL REFERENCES child_profiles("Id") ON DELETE CASCADE,
    "CardId" UUID NOT NULL REFERENCES collectible_cards("Id"),
    "Count" INTEGER NOT NULL DEFAULT 1,      -- aynı kart birden fazla kez kazanılabilir
    "FirstEarnedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "LastEarnedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE ("ChildProfileId", "CardId")
);

CREATE INDEX idx_child_cards_child ON child_cards("ChildProfileId");

-- Kart kazanım geçmişi (drop log)
CREATE TABLE card_drop_log (
    "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "ChildProfileId" UUID NOT NULL REFERENCES child_profiles("Id") ON DELETE CASCADE,
    "CardId" UUID NOT NULL REFERENCES collectible_cards("Id"),
    "Source" VARCHAR(30) NOT NULL,           -- 'quiz_complete', 'correct_answer'
    "EarnedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

#### Backend İşleri

- `CardDropService`:
  - `TryDropCardAsync(childId, source)` → drop ihtimaline göre kart ver veya null döndür
  - `GetCollectionAsync(childId)` → sahip olunan kartlar + toplam kart sayısı
  - `GetAllCardsAsync()` → tüm kartlar (sahip olunmayanlar kilitli)
- Quiz tamamlama endpoint'ine kart drop entegrasyonu
- `GET /api/cards` — tüm kart tanımları
- `GET /api/cards/collection/{childId}` — koleksiyon durumu

#### Flutter İşleri

- **Kart Koleksiyon Ekranı** (`/cards`):
  - Pokémon tarzı grid: sahip olunanlar renkli, olmayanlar siluet/gri
  - Seri filtreleri (Hayvanlar / Kahramanlar / Efsaneler)
  - Nadirlik filtresi
  - "X/40 kart toplandı" progress bar
- **Kart Kazanım Animasyonu**: Quiz biterken kart açılma efekti — kart yüzükoyun düşer, çevrilir, parlar (nadirliğe göre farklı efekt)
- **Kart Detay Modal**: Karta tıklayınca büyük görünüm + açıklama + kaç kez kazanıldı
- **Dashboard Widget**: "Son Kazanılan Kart" mini banner

---

### 17.3 Mağaza Kaldırma Planı

#### Kaldırılacaklar
- `AvatarShopScreen` ve `AvatarInventoryScreen` ekranları
- Avatar item satın alma endpoint'leri (`POST /api/avatar/purchase`)
- Dashboard'daki mağaza butonu → "Kartlarım" butonuna dönüştür
- Bottom navigation'daki mağaza sekmesi → "Koleksiyon" sekmesine dönüştür

#### Korunacaklar
- Avatar seçim ekranı (temel avatar değiştirme kalır — sadece item ekleme kaldırılır)
- Coin ve puan sistemi altyapısı (rozet/kart ekonomisine dönüştürülür)

---

### 17.4 Sprint Görev Özeti

#### Backend Görevleri

| # | Görev | Öncelik |
|---|-------|---------|
| 1 | `badges` ve `child_badges` tabloları + migration | Yüksek |
| 2 | `BadgeService.CheckAndAwardBadgesAsync()` | Yüksek |
| 3 | Badge trigger'larını quiz/streak/maç endpoint'lerine ekle | Yüksek |
| 4 | `GET /api/badges` ve `GET /api/badges/child/{childId}` | Yüksek |
| 5 | `collectible_cards` ve `child_cards` tabloları + migration | Yüksek |
| 6 | `CardDropService.TryDropCardAsync()` — ağırlıklı random drop | Yüksek |
| 7 | Quiz tamamlama endpoint'ine kart drop entegrasyonu | Yüksek |
| 8 | `GET /api/cards` ve `GET /api/cards/collection/{childId}` | Yüksek |
| 9 | İlk 40 kartın seed datası (ImageUrl için placeholder) | Orta |
| 10 | Avatar item purchase endpoint'lerini devre dışı bırak | Orta |

#### Flutter Görevleri

| # | Görev | Öncelik |
|---|-------|---------|
| 1 | `BadgeCollectionScreen` — grid, filtre, kilitli/açık durum | Yüksek |
| 2 | `BadgeEarnedOverlay` — rozet kazanım animasyonu | Yüksek |
| 3 | Profil sayfasına rozet showcase eklenmesi | Orta |
| 4 | `CardCollectionScreen` — grid, seri/nadir filtre, progress | Yüksek |
| 5 | `CardDropAnimation` — kart açılma efekti (quiz sonrası) | Yüksek |
| 6 | `CardDetailModal` — kart detay bottom sheet | Orta |
| 7 | Dashboard'a "Son Kart" ve "Rozet" mini widget'ları | Orta |
| 8 | Bottom nav'daki Mağaza → Koleksiyon (badges + cards) | Yüksek |
| 9 | `AvatarShopScreen` ve `AvatarInventoryScreen` kaldır | Orta |
| 10 | Router güncellemeleri (`/badges`, `/cards`) | Yüksek |

### Kabul Kriterleri

- Quiz tamamlandığında kart drop animasyonu oynanır
- Belirli başarılarda rozet kazanılır ve overlay gösterilir
- Koleksiyon ekranında kazanılmış/kazanılmamış kartlar görünür
- Profil sayfasında rozetler listelenir
- Mağaza ekranı artık erişilebilir değil
- Kart drop ihtimalleri tutarlı çalışır (log'lanabilir)

### Çıktılar

- Avatar mağazası konumlandırma sorununu ortadan kalkar
- Çocuklar kartlarını tamamlamak için her gün geri döner
- Rozetler uzun vadeli hedef duygusu yaratır
- Koleksiyon sistemi sosyal kıyaslama fırsatı sunar (ileride "arkadaşının koleksiyonu" özelliği)

---

## 14. Sonuç ve Öneri

Bu MVP için en sağlıklı ürün yaklaşımı aşağıdaki sırayla ilerlemektir:

1. Temel öğrenme motorunu kurmak (Sprint 1-2)
2. İlerleme ve ödül hissini görünür kılmak (Sprint 3)
3. Avatar ve coin ile motivasyonu artırmak (Sprint 4)
4. Leaderboard ile rekabeti başlatmak (Sprint 5)
5. SignalR ile canlı 1v1 yarış deneyimini eklemek (Sprint 6)
6. Ebeveyn tarafında güven ve görünür değer üretmek (Sprint 7)
7. Stabilizasyon ve yayın hazırlığı (Sprint 8)
8. **PostgreSQL production migration (Sprint 9 - tamamlandı)**
9. **LaTeX tabanlı matematik notasyonu ve görsel soru desteği (Sprint 10 - planlandı)**

Teknik tarafta Flutter + .NET Core + PostgreSQL + SignalR kombinasyonu, lisans maliyeti düşük, sürdürülebilir ve büyümeye uygun bir yapı sunmaktadır. 

**Database Stratejisi**: Development süresince SQLite ile hızlı iterasyon yapıldı, Sprint 9'da PostgreSQL'e geçiş tamamlanarak production-ready altyapı sağlandı.

MVP kapsamı kontrollü tutulduğu sürece bu proje gerçek kullanıcı testi için güçlü bir ilk ürün haline getirilebilir.

---

## 10. iOS App Store Yayın Planı

### 10.1 Durum
Apple Developer hesabı aktif. Branch: `ios_appstore_publish`

### 10.2 Kritik — Olmadan Review Reddedilir

| # | Görev | Durum |
|---|-------|-------|
| 1 | Splash screen (launch image) gerçek asset ile değiştir | ✅ |
| 2 | Privacy Policy URL hazırla ve App Store Connect'e ekle | ✅ |
| 3 | App Store screenshots — iPhone 6.7" + 6.1" (min 3 adet) | ✅ |
| 4 | Login ekranındaki test kullanıcı kartını kaldır | ✅ |
| 5 | Age Rating anketini App Store Connect'te doldur | ✅ |

### 10.3 Önemli — UX / Güvenlik

| # | Görev | Durum |
|---|-------|-------|
| 6 | Tüm teknik hata mesajlarını Türkçe kullanıcı dostu hale getir | ✅ |
| 7 | Offline / internet yok senaryosu — kullanıcı dostu mesaj | ✅ |
| 8 | Gmail App Password → environment variable (güvenlik) | ✅ |
| 9 | Şifremi unuttum akışını production backend'e deploy et | ✅ |

### 10.4 App Store Connect Yapılacaklar

| # | Görev | Durum |
|---|-------|-------|
| 10 | App Store Connect'te uygulama kaydı oluştur (Bundle: com.minibilge.mobile) | ✅ |
| 11 | App Store metinleri — kısa açıklama, uzun açıklama, anahtar kelimeler | ✅ |
| 12 | Support URL ekle | ✅ |
| 13 | 1024×1024 App Icon yükle (alfa kanalı olmadan) | ✅ |

### 10.5 Teknik Deploy

| # | Görev | Durum |
|---|-------|-------|
| 14 | Backend: tüm değişiklikleri Cloud Run'a deploy et | ✅ |
| 15 | flutter build ipa --release (build number artır) | ✅ |
| 16 | Transporter ile TestFlight'a yükle | ✅ |
| 17 | TestFlight iç test (min 1-2 gün) | ✅ |
| 18 | Submit for Review | ✅ |

### 10.7 v1.1.0 Sonrası — Gelecek Özellikler

| # | Özellik | Notlar |
|---|---------|--------|
| 1 | Google AdMob reklam entegrasyonu | Soru araları veya sonuç ekranında InterstitialAd. `google_mobile_ads` paketi, AdMob hesabı gerekli. Age Ratings'de Advertising → YES seçilmeli |
| 2 | Android yayını | Google Play Store |
| 3 | Push notification | Yeni maç daveti, haftalık rapor bildirimi |


1. Privacy Policy sayfası aç
2. Test kartını kaldır + hata mesajlarını düzelt
3. Offline senaryoyu test et
4. Gmail App Password → environment variable
5. Splash screen + screenshots
6. App Store Connect kayıt + metinler
7. Final build → TestFlight → Submit

---

## 11. Sonraki Sprint Planları (Post-MVP)

### Sprint 14 — İngilizce Modülü

**Hedef:** Matematik'in yanına İngilizce ders modülü eklemek. Matematik okul sınıflarına (1–4. sınıf) göre yapılandırılırken İngilizce CEFR seviyelerine (A1, A2, B1, B2, C1, C2) göre yapılandırılacaktır.

#### 14.1 Seviye Yapısı — İngilizce

| CEFR Seviyesi | Kapsam |
|---------------|--------|
| A1 | Alfabe, renkler, sayılar (1–10), hayvanlar, selamlaşma |
| A2 | Günlük nesneler, aile, giysi, günler/aylar, basit cümleler |
| B1 | Zaman ifadeleri, hobiler, meslekler, fiiller (present/past) |
| B2 | Paragraf anlama, karmaşık fiil zamanları, idiomlar |
| C1 | İleri okuma parçaları, akademik kelime, soyut kavramlar |
| C2 | İleri düzey anlama, tartışma, edebi metinler |

#### 14.2 Backend Görevleri

| # | Görev | Açıklama |
|---|-------|----------|
| 1 | `Subject` tablosuna "İngilizce" kaydı ekle | Seeder'a ekle, `IsActive = true` |
| 2 | `Topic` tablosuna İngilizce konuları ekle | A1–B1 için ilk 3 seviye × 5 konu |
| 3 | `Level` entity'sine `CefrLevel` alanı ekle | A1/A2/B1/B2/C1/C2 enum veya string |
| 4 | İngilizce için migration ekle | CefrLevel field + index |
| 5 | Soru seeder'ı oluştur | A1: 15 soru, A2: 15 soru, B1: 10 soru (başlangıç için) |
| 6 | MatchmakingService: İngilizce maçlarda CEFR seviyesine göre eşleştir | Matematik'te sınıf bazlıydı, İngilizce'de CEFR bazlı olacak |

#### 14.3 Frontend Görevleri

| # | Görev | Açıklama |
|---|-------|----------|
| 1 | Dashboard'a İngilizce butonu ekle | Matematik butonunun altına, yeşil renk |
| 2 | Çocuk profili oluşturma formuna CEFR seviye seçimi ekle | Sadece İngilizce seçilince görünür |
| 3 | Topic selection ekranında CEFR badge'i göster | A1, A2 etiketleri |
| 4 | Soru widget'ını görsel/emoji desteğine uyarla | Animals konusu için emoji gösterimi |
| 5 | Profil formunda ders bağımsız seviye yapısı | Matematik → sınıf, İngilizce → CEFR |

---

### Sprint 15 — Canlı Yarış: Ders Seçimli Eşleşme

**Hedef:** Canlı yarışa girmeden önce ders seçimi (Matematik / İngilizce) yapılabilmesi. Eşleşme aynı dersi seçen kullanıcılar arasında gerçekleşecek.

**Mevcut akış:** Yarış → direkt kuyruğa gir
**Yeni akış:** Yarış → Ders Seç → Kuyruğa gir → Eşleş → Arena

#### 15.1 Backend Görevleri

| # | Görev | Açıklama |
|---|-------|----------|
| 1 | `match_requests` tablosuna `SubjectId` alanı ekle | Migration gerekli |
| 2 | MatchmakingService: `SubjectId` bazlı eşleştirme | Aynı dersi seçenler eşleşir |
| 3 | MatchHub `JoinQueue` metodu: `subjectId` parametresi al | |
| 4 | Maç başladığında soruları `SubjectId`'e göre çek | |

#### 15.2 Frontend Görevleri

| # | Görev | Açıklama |
|---|-------|----------|
| 1 | Yeni ekran: `SubjectPickerForMatchScreen` | Yarış butonuna tıklayınca açılır |
| 2 | Matematik / İngilizce seçim kartları | Büyük, görsel kartlar |
| 3 | Seçim sonrası `MatchRequestScreen`'e subjectId ilet | Route parametresi olarak |
| 4 | MatchHub bağlantısında subjectId gönder | `JoinQueue(subjectId)` |
| 5 | Arena ekranında hangi dersin oynanacağını göster | Başlık: "Matematik Yarışı" |

---

### Sprint 16 — İçerik Genişletme ve Kalite

**Hedef:** Soru havuzunu artırmak, zayıf konu raporunu aksiyona dönüştürmek.

| # | Görev | Açıklama |
|---|-------|----------|
| 1 | Her Matematik konusu için 50+ soruya ulaş | Mevcut seeder genişletme |
| 2 | Quiz sonucu ekranına "Yanlışları Tekrar Çöz" butonu ekle | Yalnızca yanlış soruları tekrar yükle |
| 3 | Ebeveyn raporu: zayıf konudan direkt "Pratik Yap" butonu | İlgili konuya navigate et |
| 4 | Takvim lokalizasyonu: showDatePicker sistem diline göre | `GlobalMaterialLocalizations` + `supportedLocales` |
| 5 | App Store'a 1.0.4 build yükle | Transporter ile TestFlight |


