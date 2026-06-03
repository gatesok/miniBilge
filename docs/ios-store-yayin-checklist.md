# MiniBilge iOS App Store Yayın Checklist

Bu dosya, Apple Developer hesabı henüz açılmamışken yapılabilecek hazırlıkları ve hesap açıldıktan sonra App Store'a yükleme adımlarını içerir.

## 1) Bu projede şimdiden yapılan teknik düzeltmeler

Aşağıdaki güncellemeler uygulandı:

- iOS uygulama bundle identifier örnek değerden proje değerine çekildi:
  - Runner: com.minibilge.mobile
  - RunnerTests: com.minibilge.mobile.RunnerTests
- Podfile içinde iOS platform hedefi netleştirildi:
  - platform :ios, '13.0'
- Uygulama adı iOS tarafında mağaza sunumuna uygun hale getirildi:
  - CFBundleDisplayName: MiniBilge
  - CFBundleName: MiniBilge

Not: Apple Developer hesabı açtıktan sonra bundle identifier'ı nihai marka/domain stratejine göre yeniden güncelleyebilirsin (ornek: com.sirketadi.minibilge).

## 2) Hesap acilmadan yapilabilecekler (simdi)

### 2.1 Uygulama kalite kontrolu

- Gercek cihazda temel akislarin calistigini dogrula:
  - Login / Register
  - Cocuk profili secme, olusturma, duzenleme
  - Ders/quiz akisi
  - Match / leaderboard
  - Parent report ekranlari
- Hatali internet senaryosu:
  - Internet kapali iken hata mesaji
  - API timeout durumunda geri bildirim
- Uygulama metinleri:
  - Turkce karakter ve tasma kontrolu
  - Kucuk ekranlarda layout bozulmasi kontrolu

### 2.2 Surumleme duzeni

- pubspec.yaml surum mantigini netlestir:
  - version: MAJOR.MINOR.PATCH+BUILD
  - Ilk yayin icin ornek: 1.0.0+1
- Her yeni App Store gonderiminde BUILD numarasini artir.

### 2.3 Magaza varliklarini hazirla

- App icon (1024x1024) son halini dogrula.
- Ekran goruntuleri hazirla:
  - iPhone 6.7" (1290x2796 veya 1320x2868)
  - iPhone 6.1" (1179x2556)
- App aciklamasi taslagi yaz:
  - Kisa aciklama
  - Uzun aciklama
  - Anahtar kelimeler

### 2.4 Hukuki metinler

- Privacy Policy URL hazirla.
- Support URL hazirla.
- Cocuk odakli urun oldugu icin veri isleme metnini acik yaz:
  - Hangi veri toplanir
  - Ne amacla kullanilir
  - Ucuncu taraf paylasim var mi

## 3) Apple Developer hesabi acildiktan sonra

### 3.1 Hesap ve sertifika

- Apple Developer Program kaydi tamamla.
- App Store Connect erisimi ac.
- Xcode icinde Apple ID ile sign-in yap.
- Team secimini proje icinde dogrula.

### 3.2 App ID ve bundle identifier

- Certificates, Identifiers & Profiles ekraninda App ID olustur.
- Bundle ID'nin Xcode'daki degerle birebir ayni oldugunu dogrula:
  - com.minibilge.mobile (veya senin nihai secimin)
- Gerekli capability'leri sadece ihtiyac varsa ac:
  - Push Notifications
  - Sign in with Apple
  - Associated Domains

### 3.3 App Store Connect app kaydi

- New App olustur:
  - Platform: iOS
  - Name: MiniBilge
  - Primary Language: Turkish (veya hedef dil)
  - Bundle ID: yukaridaki ile ayni
  - SKU: minibilge-ios-001 gibi benzersiz bir deger

## 4) iOS build ve upload adimlari

### 4.1 Yerel hazirlik

- Komutlar:

```bash
cd mobile/minibilge_mobile
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter build ios --release
```

Not: Nihai gonderimde Xcode Archive akisini kullanmak daha guvenlidir.

### 4.2 Xcode archive

- ios/Runner.xcworkspace dosyasini Xcode ile ac.
- Target: Runner
- Signing & Capabilities:
  - Automatically manage signing: acik
  - Team: dogru team secili
- Version / Build:
  - Version (marketing): ornek 1.0.0
  - Build: ornek 1
- Product > Archive ile archive al.

### 4.3 Upload

- Xcode Organizer > Distribute App
- Distribution method: App Store Connect
- Upload tamamlaninca App Store Connect'te build processing bitmesini bekle.

## 5) App Store Connect zorunlu alanlar

### 5.1 Uygulama bilgileri

- App Name
- Subtitle
- Description
- Keywords
- Support URL
- Marketing URL (opsiyonel)
- Privacy Policy URL

### 5.2 App Privacy formu

- Toplanan veri turlerini isaretle:
  - Kimlik bilgileri
  - Kullanim verileri
  - Cihaz verileri
- Her veri icin su alanlari doldur:
  - Verinin amaci
  - Kullanici ile iliskilendirme
  - Takip (tracking) durumu

### 5.3 Age Rating ve cocuk uygunlugu

- Age rating sorularini dogru yanitla.
- Cocuklara yonelik icerik oldugu icin beyanlari dikkatli doldur.

### 5.4 Export compliance

- Sifreleme kullanimina dair sorulari yanitla.
- Genelde HTTPS/JWT kullanan uygulamalarda bu bolum zorunludur.

## 6) Review'e gondermeden hemen once

- TestFlight ic test:
  - En az 1-2 fiziksel cihazda dene
- Asagidakileri tekrar kontrol et:
  - Cokme yok
  - Bos ekran yok
  - API hata durumlari yakalaniyor
  - Giris/oturum yenileme stabil
- App Review Notes yaz:
  - Test hesabi (gerekiyorsa)
  - Login adimlari
  - Ozel akislari acikla (ebeveyn-cocuk akisi gibi)

## 7) Yayin sonrasi operasyon

- Ilk 48 saat crash ve hata loglarini izle.
- Kullanici geri bildirimlerine gore hizli patch plani hazirla.
- Sonraki surumde BUILD numarasini artirarak yeni gonderim yap.

## 8) Hata oldugunda hizli kontrol listesi

- "Invalid Bundle" hatasi:
  - Bundle ID, App Store Connect kaydiyla ayni mi?
- Signing hatasi:
  - Team ve sertifikalar dogru mu?
- Upload reddi:
  - Privacy formu eksik olabilir
  - Metadata (aciklama, URL, screenshot) eksik olabilir
- Build processing uzadi:
  - App Store Connect tarafinda bekleme normal olabilir, sonra tekrar kontrol et

---

Son guncelleme: 2026-05-31
