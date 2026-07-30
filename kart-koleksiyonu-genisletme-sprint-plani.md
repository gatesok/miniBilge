# MiniBilge Kart Koleksiyonu Genişletme Planı

## Hedef

Kart koleksiyonunu mevcut 40 karttan 80 karta çıkarmak; ilk kartların motive
edici hızda kazanılmasını korurken koleksiyon ilerledikçe yeni kart kazanmayı
daha değerli ve dengeli hâle getirmek.

## Sprint 1 — Katalog ve Koleksiyon Genişletme

### İçerik ve görseller

- [x] 40 yeni kartın ad, açıklama, seri, nadirlik ve dosya adlarını belirle.
- [x] Yeni kartları şu temalara dağıt:
  - 10 hayvan
  - 8 kahraman/meslek
  - 7 efsane
  - 6 bilim ve keşif
  - 5 doğa ve uzay
  - 4 kültür ve tarih
- [x] Nadirlik dağılımını 14 yaygın, 11 nadir, 9 destansı ve 6 efsanevi olarak
  uygula.
- [x] Her kart için MiniBilge'nin mevcut görsel diline uygun kare görsel üret.
- [x] Görselleri Flutter asset yapısına ekle ve dosya yollarını doğrula.

### Backend ve veritabanı

- [x] Mevcut 40 kartı ve kazanılmış kart kayıtlarını değiştirmeden 41–80
  numaralı kartları ekleyen idempotent PostgreSQL scripti hazırla.
- [x] Kart numarası, seri ve nadirlik için doğrulama sorguları ekle.
- [x] Kart koleksiyonu API'sinin aktif katalogdan dinamik kart sayısını ve yeni
  serileri döndürebildiğini kod üzerinden doğrula.
- [x] Rastgele kart seçiminin aktif katalogdaki tüm uygun kartları aday havuzuna
  aldığını kod üzerinden doğrula.

### Flutter

- [x] Kart koleksiyonu ekranına Bilim, Doğa/Uzay ve Kültür/Tarih filtrelerini
  ekle.
- [x] Filtreleri küçük telefon ve iPad ekranlarında taşma olmadan yatay
  kaydırılabilir hâle getir.
- [x] Toplam kart ve koleksiyon yüzdesinin API'den gelen 80 kart üzerinden
  hesaplandığını doğrula.
- [x] Kilitli ve kazanılmış yeni kart görsel yollarını doğrula.

### Test ve teslim

- [x] Backend derlemesini çalıştır.
- [x] Flutter analizini çalıştır.
- [x] iOS Simulator derlemesini çalıştır.
- [x] Manuel SQL çalıştırma ve canlı API dağıtım sırasını dokümante et.

### Canlıya alma sırası

1. Mobil uygulamanın yeni kart görsellerini ve seri filtrelerini içeren sürümünü
   hazırla.
2. `20260731_Add40CollectibleCards.sql` scriptini PostgreSQL üzerinde çalıştır.
3. Script sonundaki sorgularda 80 aktif ve 80 farklı kart numarası geldiğini
   doğrula.
4. API'yi bu branch'teki backend ile dağıt.
5. Canlı API ile iOS Simulator üzerinde koleksiyon toplamının 80 olduğunu,
   filtreleri ve yeni kart görsellerini kontrol et.
6. Mobil sürümü mağaza incelemesine gönder.

## Sprint 2 — Kart Kazanma Ekonomisi

### İlerlemeye göre zorluk

- [x] Koleksiyon ilerlemesini `benzersiz kazanılmış kart / aktif kart` olarak
  hesapla.
- [x] Başlangıç evresi (0–15 kart): yüksek kart düşürme ve yeni kart ağırlığı.
- [x] Gelişim evresi (16–40 kart): dengeli düşürme ve kopya ihtimali.
- [x] Ustalık evresi (41–64 kart): daha düşük düşürme ve nadir kart odağı.
- [x] Koleksiyon sonu (65–79 kart): kontrollü düşürme ve garanti sayacı.
- [x] Quiz başarısı, quiz türü ve zorluk seviyesini ödül olasılığına dahil et.

### Garanti ve tekrar kart sistemi

- [x] Belirlenen sayıda sonuçsuz denemeden sonra kart garantisi ekle.
- [x] Belirlenen sayıda kopyadan sonra yeni kart garantisi ekle.
- [x] Aynı kartın kopyalarını “kart parçası” bakiyesine dönüştür.
- [x] Kart parçalarıyla henüz kazanılmamış kart açma servisi ve endpoint'i ekle.
- [x] Günlük kart kazanma sınırı ve kalan hak bilgisini ekle.
- [x] Sayaçların profil bazında kalıcı tutulacağı tabloları ve migration
  scriptini hazırla.

### Kullanıcı deneyimi

- [x] Sonuç ekranında garanti sayacı ve günlük kalan hakkı göster.
- [x] Kopya kart kazanıldığında kazanılan kart parçasını göster.
- [x] Koleksiyon ekranına kart parçası bakiyesi ve kart açma akışı ekle.
- [x] Tüm ödül kurallarını profil türünden bağımsız çalışacak şekilde uygula.

### Ölçüm ve güvenlik

- [x] Kart düşürme olaylarına evre, oran, garanti ve kopya bilgilerini kaydet.
- [x] Yönetim raporuna yeni/kopya kart oranı ve günlük dağıtım sayılarını ekle.
- [x] Yarışma sonucunun tekrar gönderilmesiyle birden fazla ödül alınmasını
  engelle.
- [x] Backend ve Flutter statik analizini, backend derlemesini ve iOS Simulator
  derlemesini çalıştır.
- [x] Kart ekonomisi Flutter model uyumluluk testlerini çalıştır.
- [ ] Canlı API ile çocuk/yetişkin profillerinde manuel ekonomi senaryolarını
  ve widget etkileşimlerini doğrula.

### Sprint 2 canlıya alma sırası

1. Önce `20260731_AddCardEconomy.sql` scriptini PostgreSQL üzerinde çalıştır.
2. Script sonundaki sorguda iki ekonomi tablosunun oluştuğunu doğrula.
3. Daha sonra API'yi dağıt. API, script çalıştırılmadan dağıtılmamalıdır.
4. Yeni mobil sürümle koleksiyon özeti, kopya parça bildirimi ve parçayla kart
   açma akışını canlı API üzerinde test et.
