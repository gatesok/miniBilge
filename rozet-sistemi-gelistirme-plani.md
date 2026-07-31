# MiniBilge Rozet Sistemi Geliştirme Planı

## Hedef

Mevcut 17 rozetin açıklamalarıyla uyumlu, güvenilir ve profil bazlı şekilde
kazanılmasını sağlamak; ardından meydan okuma, canlı yarış ve eğlence quizleri
için yeni rozet aileleri ekleyerek toplam aktif rozet sayısını 35'e çıkarmak.

Bu geliştirmede rozet koşullarının istemciden gelen sayaçlara güvenmesi yerine
backend tarafından kalıcı veriler üzerinden hesaplanması esastır. Çocuk ve
yetişkin profillerinin erişemeyeceği rozetler ilgili profilde ilerleme hedefi
olarak gösterilmemelidir.

## Öncelik sırası

1. Mevcut rozetlerdeki kazanılamama ve yanlış koşul sorunlarını düzelt.
2. Rozet değerlendirmesini güvenli, tekrar çalıştırılabilir ve profil bazlı yap.
3. Tüm sonuç ekranlarında ortak rozet kazanma animasyonu kullan.
4. Canlı yarış ve meydan okuma istatistiklerini birbirinden doğru şekilde ayır.
5. Eğlence quizleri için kategori ve başarı istatistiklerini kalıcılaştır.
6. Yeni rozetleri katalog ve koleksiyon ekranına ekle.
7. Kilitli rozetlerde ilerleme ve “yaklaşan rozet” bilgisini göster.
8. Rozet ekonomisini raporla, ölç ve canlıya çıkmadan önce geçmiş verilerle
   geriye dönük kazanım politikasını uygula.

## Yeni rozet kataloğu önerisi

Mevcut 17 rozete aşağıdaki 18 rozetin eklenmesi önerilir.

### Meydan okuma rozetleri — 6 adet

| Anahtar | Ad | Koşul | Nadirlik |
| --- | --- | --- | --- |
| `challenge_first_win` | İlk Meydan Okuma | İlk meydan okuma galibiyeti | Bronz |
| `challenge_wins_10` | Düello Meraklısı | Toplam 10 meydan okuma kazan | Gümüş |
| `challenge_wins_50` | Düello Ustası | Toplam 50 meydan okuma kazan | Altın |
| `challenge_streak_5` | Yenilmez Seri | Arka arkaya 5 meydan okuma kazan | Altın |
| `challenge_perfect_win` | Kusursuz Düello | Bir meydan okumayı tüm soruları doğru cevaplayarak kazan | Gümüş |
| `challenge_variety` | Çok Yönlü Rakip | En az 3 farklı kategoride meydan okuma kazan | Efsanevi |

### Canlı yarış rozetleri — 5 adet

Mevcut `first_win`, `win_streak_5` ve `champion_50` rozetleri korunur; aşağıdaki
rozetler canlı yarış ailesini tamamlar.

| Anahtar | Ad | Koşul | Nadirlik |
| --- | --- | --- | --- |
| `live_matches_10` | Arenaya Alışıyorum | 10 canlı yarış tamamla | Bronz |
| `live_wins_10` | Canlı Yarışçı | 10 canlı yarış kazan | Gümüş |
| `live_perfect_win` | Kusursuz Zafer | Canlı yarışı tam puanla kazan | Altın |
| `live_comeback` | Geri Dönüş Ustası | Geriden gelerek canlı yarış kazan | Altın |
| `live_variety` | Arena Bilgesi | 3 farklı kategoride canlı yarış kazan | Efsanevi |

`live_comeback` için soru bazlı skor sırası güvenilir şekilde tutulamıyorsa ilk
sürümde pasif bırakılmalı; yalnızca toplam sonuçtan tahmin edilmemelidir.

### Eğlence quizi rozetleri — 7 adet

| Anahtar | Ad | Koşul | Nadirlik |
| --- | --- | --- | --- |
| `fun_first_quiz` | Eğlence Başlasın | İlk eğlence quizini tamamla | Bronz |
| `fun_quizzes_10` | Quiz Meraklısı | 10 eğlence quizi tamamla | Gümüş |
| `fun_quizzes_50` | Eğlence Bilgesi | 50 eğlence quizi tamamla | Altın |
| `fun_perfect` | Eğlencede Kusursuz | Bir eğlence quizini %100 tamamla | Gümüş |
| `fun_categories_5` | Kategori Kaşifi | 5 farklı eğlence kategorisinde quiz tamamla | Altın |
| `general_culture_master` | Genel Kültür Ustası | Genel kültürde 10 quiz ve en az %80 ortalama | Altın |
| `word_game_master` | Kelime Ustası | 10 kelime oyunu tamamla | Efsanevi |

## Sprint 1 — Mevcut Rozet Sistemini Sağlamlaştırma

### Backend ve veri modeli

- [ ] Rozet değerlendirmesini profil bazlı, idempotent bir servis hâline getir.
- [ ] `child_badges` tablosuna `ChildProfileId + BadgeId` birleşik benzersiz
  indeksi ekle.
- [ ] Gerekli migration ve manuel çalıştırılabilir PostgreSQL scriptini hazırla.
- [ ] Quiz tamamlanma süresini backend tarafında güvenilir şekilde kaydet.
- [ ] Soru cevap sürelerini kaydet ve “Şimşek” koşulunda yalnızca doğru cevabı
  dikkate al.
- [ ] Profilin günlük farklı konu, toplam konu ve ders bazlı tamamlanan konu
  sayılarını backend üzerinden hesapla.
- [ ] İngilizce seviyesini `A1–C2` değerleriyle normalize et.
- [ ] “İlk Adım” koşulunu ürün metniyle eşleştir: gerçek ilk tamamlanan uygun
  quiz mi, ilk başarılı yeni seviye mi olduğuna karar ver ve tek anlam uygula.
- [ ] “Konu Ustası” koşulunu bir konunun gerekli tüm seviyelerini tamamlamaya
  bağla.
- [ ] “Kelime Avcısı” koşulunu tüm A1 içeriğinin tamamlanmasına bağla.
- [ ] “CEFR Yolcusu” koşulunu B1 seviyesine gerçekten ulaşmaya bağla.
- [ ] “Sayıların Efendisi” hesabında yalnızca matematik konularını say.
- [ ] `StreakUpdated` olayını backend aktivite kaydıyla tetikle.
- [ ] 3, 7 ve 30 günlük seri değerini cihaz yerine backend'de profil bazında
  tut.
- [ ] Canlı yarış toplam galibiyetini son 20 maç yerine kalıcı toplamdan hesapla.
- [ ] Hükmen/bağlantı kopmasıyla kazanılan maçların seri ve toplam galibiyete
  sayılıp sayılmayacağı kuralını açıkça uygula.
- [ ] `early_bird` ve `beta_hero` rozetlerini gerçek koşulla uygula veya aktif
  katalogdan kaldır.
- [ ] Rozet değerlendirme hatalarını yutmadan log ve metrik üret; ana oyun
  sonucunun kaydedilmesini yine engelleme.

### Flutter

- [ ] Normal matematik ve İngilizce quiz sonuçlarında kazanılan rozet
  anahtarlarını detaylarıyla işle.
- [ ] Eğlence quizi, meydan okuma ve canlı yarış sonuçlarında aynı ortak
  `BadgeEarnedOverlay` bileşenini kullan.
- [ ] Kart ve rozet aynı sonuçta kazanılırsa animasyonları sıraya koy.
- [ ] Rozet kazanıldığında koleksiyon provider/cache'ini yenile.
- [ ] Rozet animasyonuna ad, açıklama, nadirlik, yeni görsel ve “Rozetlerimde
  Gör” aksiyonu ekle.
- [ ] iPhone ve iPad üzerinde rozet animasyonu boyutlarını ayrı doğrula.

### Mevcut rozet kabul testleri

- [ ] 17 mevcut rozetin her biri için backend birim testi yaz.
- [ ] Aynı olay iki kez işlendiğinde aynı rozetin iki kayıt oluşturmadığını test
  et.
- [ ] A1, B1, matematik konu sayısı ve konu tamamlama sınır testlerini yaz.
- [ ] 3, 7 ve 30 günlük seri sınırlarını ve gün atlama durumunu test et.
- [ ] 1, 5 ve 50 canlı yarış galibiyeti sınırlarını test et.
- [ ] Normal quiz, eğlence quizi, meydan okuma ve canlı yarış sonucu için Flutter
  entegrasyon/widget testlerini ekle.
- [ ] Backend derlemesi ve testlerini çalıştır.
- [ ] Flutter analyze ve testlerini çalıştır.
- [ ] iOS Simulator derlemesini ve kritik akışları canlı API ile doğrula.

### Sprint 1 tamamlanma ölçütü

- Aktif bırakılan mevcut 17 rozetin tamamı açıklamasındaki gerçek koşulla
  kazanılabilir olmalı.
- Aynı rozet profil başına yalnızca bir kez kaydedilmeli.
- Rozet kazanımı bütün oyun sonuç ekranlarında aynı kaliteli animasyonla
  görünmeli.
- Seri ve toplam sayaçları uygulama silinse veya cihaz değişse de korunmalı.

## Sprint 2 — Yeni Rozet Aileleri ve İlerleme Deneyimi

### Backend ve istatistikler

- [ ] Meydan okuma için oynanan, kazanılan, kaybedilen, beraberlik, ardışık
  galibiyet ve kategori bazlı galibiyet sayaçlarını profil bazında tut.
- [ ] Canlı yarış için oynanan, kazanılan, kusursuz galibiyet, ardışık galibiyet
  ve kategori bazlı galibiyet sayaçlarını tut.
- [ ] Eğlence quizleri için tamamlanan quiz, kategori çeşitliliği, kategori bazlı
  başarı ve toplam başarı ortalamasını tut.
- [ ] Meydan okuma ve canlı yarış istatistiklerini birbirine karıştırmadan ayrı
  olaylarla değerlendir.
- [ ] Sonuç isteğinin tekrarlanmasıyla sayaç veya rozetin iki kez işlenmesini
  idempotency anahtarıyla engelle.
- [ ] Yeni 18 rozet tanımını idempotent SQL scriptiyle `badges` tablosuna ekle.
- [ ] Yeni rozetlerin profil türü uygunluğunu tanımlayacak alan veya kural ekle.
- [ ] Mevcut kullanıcılara geriye dönük rozet verilecekse tek seferlik, tekrar
  çalıştırılabilir backfill servisi/scripti hazırla.

### Rozet görselleri ve içerik

- [ ] Yeni 18 rozet için MiniBilge görsel dilinde birbirinden ayırt edilebilir
  görseller üret.
- [ ] Görsellerde meydan okuma, canlı yarış ve eğlence quiz aileleri için ortak
  ama farklı renk kodları kullan.
- [ ] Tüm rozet adlarını, açıklamalarını ve nadirliklerini Türkçe dil kontrolünden
  geçir.
- [ ] Rozet görsellerini Flutter asset yapısına ekle ve eksik asset fallback'ini
  doğrula.

### Flutter koleksiyon ve ilerleme

- [ ] Rozet koleksiyonunda toplam sayıyı API'deki aktif katalogdan dinamik
  hesapla.
- [ ] Meydan Okuma, Canlı Yarış ve Eğlence kategorisi filtrelerini ekle.
- [ ] Yatay kategori menüsünü küçük telefonlarda ve iPad'de taşma olmadan göster.
- [ ] Kilitli rozet kartlarına sayısal ilerleme ekle (`3/5`, `8/10`, `%80`).
- [ ] Koşulu profil için uygun olmayan rozetleri gizle veya ayrı şekilde açıkla.
- [ ] Dashboard'a en yakın 1–2 hedefi gösteren “Yaklaşan Rozetler” bileşeni
  ekle.
- [ ] Rozete dokunulduğunda koşul, ilerleme, nadirlik ve kazanılma tarihini
  gösteren detay alanını güncelle.

### Yönetim ve ölçüm

- [ ] Rozet bazında toplam kazanım ve benzersiz profil sayısını raporla.
- [ ] Oyun türüne göre rozet kazanım oranını raporla.
- [ ] Hiç kazanılmayan veya aşırı kolay kazanılan rozetler için yönetim uyarısı
  üret.
- [ ] Çocuk ve yetişkin profillerinde rozet kazanım dağılımını ayrı izle.
- [ ] Rozet animasyonunun gösterilme ve “Rozetlerimde Gör” tıklanma olaylarını
  analitiğe ekle.

### Yeni rozet kabul testleri

- [ ] Yeni 18 rozetin her biri için koşul altı, tam sınır ve koşul üstü testleri
  yaz.
- [ ] Meydan okuma ve canlı yarış galibiyetlerinin yanlış ailede sayılmadığını
  test et.
- [ ] Eğlence quiz kategori çeşitliliğinin aynı kategoriyi tekrar oynayarak
  artırılamadığını test et.
- [ ] Kusursuz sonuç rozetlerinde soru sayısı sıfır veya eksik sonuç durumlarını
  test et.
- [ ] Backfill uygulanırsa mevcut kullanıcılarda mükerrer rozet oluşmadığını
  test et.
- [ ] iPhone ve iPad'de koleksiyon, ilerleme ve animasyon ekranlarını test et.
- [ ] Backend derlemesi/testleri, Flutter analyze/testleri ve iOS Simulator
  derlemesini çalıştır.

### Sprint 2 tamamlanma ölçütü

- Aktif rozet kataloğu 35 rozete ulaşmalı.
- Meydan okuma, canlı yarış ve eğlence quizlerinin her biri kendi rozet ailesine
  sahip olmalı.
- Kullanıcı kilitli rozetlerde ne kadar ilerlediğini görebilmeli.
- Yeni rozetler profil bazında doğru kazanılmalı ve bütün sonuç ekranlarında
  animasyonla gösterilmeli.

## Canlıya alma ve geriye dönük kazanım kararı

Önerilen politika:

1. “Toplam adet” rozetleri geçmiş veriler güvenilir ise geriye dönük verilsin.
2. “Ardışık seri”, “kusursuz galibiyet” ve “geriden dönüş” gibi olay sırası
   gerektiren rozetler geçmiş veri yeterli değilse geriye dönük verilmesin.
3. Backfill önce yalnızca rapor modunda çalıştırılarak kaç profile hangi rozetin
   verileceği gösterilsin.
4. Sonuç onaylandıktan sonra idempotent şekilde gerçek kayıtlar oluşturulsun.
5. SQL/migration önce, geriye uyumlu API ikinci, mobil uygulama son olarak
   yayınlansın.

## Haftaya geliştirmeye başlarken ilk işler

1. Bu plan için `main` üzerinden ayrı bir rozet geliştirme branch'i oluştur.
2. Rozet koşulları ve ürün metinleri için son kararları kodlamadan önce sabitle.
3. Sprint 1 veritabanı değişikliklerini ve manuel SQL scriptini hazırla.
4. Mevcut 17 rozet için başarısız olan testleri yazarak mevcut durumu görünür
   hâle getir.
5. Backend rozet değerlendirme ve istatistik servislerini düzelt.
6. Flutter ortak rozet ödül animasyonunu tüm sonuç ekranlarına bağla.
7. Sprint 1 kabul testleri tamamlandıktan sonra Sprint 2 katalog ve görsel
   çalışmalarına geç.
