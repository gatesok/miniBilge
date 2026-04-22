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
- Gelişmiş admin paneli
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

---

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
- Admin Content Management Module (ileriki faz)

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

---

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

## Sprint 9 – PostgreSQL Migration (SQLite → PostgreSQL)
### Amaç
Development süresince kullanılan SQLite veritabanını production-ready PostgreSQL'e taşımak. Bu sprint tüm geliştirmeler tamamlandıktan sonra, deployment öncesi son adım olarak uygulanır.

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
- Bu sprint SADECE database geçişi içerir, yeni feature eklenmez
- Tüm Sprint 1-8 işleri tamamlandıktan SONRA uygulanır
- Development sırasında SQLite kullanılmaya devam edilir
- Migration test için staging environment kullanılmalı

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
8. **PostgreSQL production migration (Sprint 9)**

Teknik tarafta Flutter + .NET Core + PostgreSQL + SignalR kombinasyonu, lisans maliyeti düşük, sürdürülebilir ve büyümeye uygun bir yapı sunmaktadır. 

**Database Stratejisi**: Development süresince SQLite kullanarak hızlı iterasyon yapılır, tüm özellikler tamamlandıktan sonra Sprint 9'da PostgreSQL'e geçilerek production deployment gerçekleştirilir. Bu yaklaşım hem development hızını artırır hem de production'da robust database altyapısı sağlar.

MVP kapsamı kontrollü tutulduğu sürece bu proje gerçek kullanıcı testi için güçlü bir ilk ürün haline getirilebilir.

