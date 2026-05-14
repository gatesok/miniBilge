# Sprint 8 Execution Checklist
Tarih: 14 Mayis 2026
Sprint Suresi: 2 hafta
Hedef: MVP'yi pilot yayina hazir hale getirmek (stabilizasyon + kalite + release hazirligi)

## 1. Sprint Hedefleri
- Kritik bug'lari kapatmak
- Performans darboazlarini azaltmak
- UX/hata mesaji/loading akisini iyilestirmek
- SignalR ve API dayanikliligini artirmak
- Pilot release icin checklist'i tamamlamak

## 2. Tanimlar (DoD)
Bir is kalemi "tamamlandi" sayilirsa:
- Kod merge edildi
- Ilgili testler gecti (veya test notu yazildi)
- Log/monitoring etkisi kontrol edildi
- Dokumantasyon guncellendi (gerekliyse)
- Product owner kabul etti

## 3. Sprint 8 Is Listesi

### A. Bug Fixing ve Stabilite
- [ ] P0/P1 bug triage listesi olusturuldu ve onceliklendirildi
- [ ] Tum P0 bug'lar kapatildi
- [ ] P1 bug'larin en az %80'i kapatildi
- [ ] En az 1 regression test paketi calistirildi
- [ ] Acik bug'lar icin release etiketi/veri seti guncellendi

### B. Performans
- [ ] En yavas 5 API endpoint olculdu (baseline)
- [ ] Kritik sorgular optimize edildi (index/sorgu duzenleme)
- [ ] Match + leaderboard akisinda gecikme olcumleri alindi
- [ ] Iyilestirme sonrasi benchmark tekrarlandi
- [ ] Once/sonra performans raporu yazildi

### C. Mobil UX Polish
- [ ] Tum ana ekranlarda loading state standardize edildi
- [ ] Empty-state metinleri ve CTA'lar netlestirildi
- [ ] Hata mesajlari kullanici dostu hale getirildi
- [ ] Router/navigation edge-case'leri test edildi
- [ ] En az 1 usability pass tamamlandi (ebeveyn akisi + cocuk akisi)

### D. Backend Hardening
- [ ] API timeout/retry politikalari gozden gecirildi
- [ ] Global exception handling ve hata kodlari denetlendi
- [ ] SignalR reconnect davranisi test edildi
- [ ] Log seviyeleri (Info/Warn/Error) operasyon icin duzenlendi
- [ ] Production config degerleri kontrol edildi

### E. Test ve Kalite Kapisi
- [ ] Backend testleri toplu calistirildi
- [ ] Flutter analiz/test paketi calistirildi
- [ ] Kritik user journey E2E smoke testi tamamlandi
- [ ] "No blocker" kalite kapisi onayi alindi

### F. Release Hazirligi
- [ ] Pilot release note taslagi yazildi
- [ ] Bilinen limitler/known issues listesi guncellendi
- [ ] Operasyon runbook kontrol edildi
- [ ] Rollback plani netlestirildi
- [ ] Pilot kullanici senaryolari ve test takvimi kesinlestirildi

## 4. Gun Bazli Uygulama Plani (2 Hafta)

### Hafta 1
- Gun 1: Triage + sprint kickoff + kalite kapisi kriterleri
- Gun 2: P0 bug fix + performans baseline
- Gun 3: P0/P1 fix + backend hardening
- Gun 4: Mobil UX polish + error/loading standartlari
- Gun 5: Ara demo + risk/gozden gecirme

### Hafta 2
- Gun 6: Kalan P1 bug'lar + SignalR reconnect testleri
- Gun 7: Performans optimizasyonu final
- Gun 8: E2E smoke + regression run
- Gun 9: Release dokumani + pilot hazirlik
- Gun 10: Sprint review + go/no-go karari

## 5. Riskler ve Aksiyonlar
- Risk: Sprint sonunda beklenmedik P0 bug cikmasi
  - Aksiyon: Gun 8'den sonra yeni feature freeze, yalnizca blocker fix

- Risk: Realtime akista gecikme
  - Aksiyon: Match/leaderboard icin ayrik performans olcumu ve fallback plan

- Risk: Pilotta operasyonel belirsizlik
  - Aksiyon: Net runbook + rollback adimlarini sprint icinde dry-run etmek

## 6. Cikis Kriteri (Sprint 8 Basari)
- P0 bug yok
- P1 bug kapanis orani >= %80
- Kritik endpointlerde olculebilir performans iyilesmesi
- Realtime akislarda kopma/reconnect davranisi kabul edilebilir
- Pilot release checklist'i tamamlaniyor ve go karari verilebiliyor
