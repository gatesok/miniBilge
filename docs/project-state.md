# MiniBilge Proje Durumu

## Proje Özeti
Eğitici mobil oyun MVP - Flutter (frontend) + .NET 8 (backend)  
**Hedef**: Ebeveyn profili ile çocuk profilleri yönetimi + interaktif eğitim içeriği (Matematik, İngilizce)

## Sprint Durumu

### ✅ Sprint 1 - Auth & Profile System (TAMAMLANDI)
- Backend: User, ParentProfile, ChildProfile entities
- API: Auth endpoints (register/login/refresh/logout) + ChildProfile CRUD
- Frontend: Theme system, constants, widgets

### ✅ Sprint 2 - Matematik Eğitim Motoru V1 (TAMAMLANDI)
- **Backend**: 5 entity (Subject, Topic, Level, Question, QuestionOption)
- **Backend**: 5 API endpoint (subjects, topics, levels, questions, submit-answer)
- **Backend**: EducationDataSeeder - 25 soru (1. sınıf Matematik)
- **Frontend**: 6 Freezed model + 4 provider + 5 screen + 1 widget
- **Frontend**: Quiz akışı (SubjectSelection → Topic → Level → Quiz → Result)
- **Features**: 3 soru tipi (MultipleChoice, TrueFalse, NumericInput), SnackBar feedback, confetti animasyon
- **Git**: Commit 6c1ff0a, 66 dosya (+5,847 / -9)

### ✅ Sprint 3 - Progress, Puan ve Level Unlock (TAMAMLANDI - 20/20 task)
**Amaç**: İlerleme kalıcılığı, puan/yıldız sistemi, level unlock mekanizması

**Backend** (9 task):
- ✅ 3 Domain entities: ChildProgress, AnswerAttempt, LevelResult
- ✅ 3 EF Configurations + 3 migrations
- ✅ ProgressService: Puan hesaplama (doğru: +10 puan, yıldız: 1-3★)
- ✅ IProgressRepository + ProgressRepository
- ✅ ProgressController: 5 API endpoint (GetProgress, GetByLevel, SaveProgress, SaveAnswer, GetLevelResult)
- ✅ Level unlock mekanizması (%70 başarı gerekli)

**Frontend** (7 task):
- ✅ 4 Freezed models: ChildProgress, LevelResult, SaveProgressRequest, SaveAnswerAttemptRequest
- ✅ ProgressService (API client wrapper)
- ✅ progressProvider (StateNotifierProvider)
- ✅ Dashboard: TotalCoins ve TotalStars gösterimi (fresh data)
- ✅ Quiz navigation fix: Result screen persistence
- ✅ Dark theme text contrast improvements
- ✅ Router redirect exclusion for quiz routes

**Test** (4 task):
- ✅ 64 backend tests passing
- ✅ ProgressServiceTests: Puan/yıldız hesaplama testleri
- ✅ LevelUnlockTests: %70 başarı kuralı testleri
- ✅ ProgressIntegrationTests: API endpoint testleri

**Git**: Commit 9f13a24, 56 dosya (+7,113 / -414)

### ✅ Sprint 4 - Puan Bazlı Avatar Mağazası (TAMAMLANDI)
**Git**: `32a36c5` — feat: Sprint 4 - Complete Avatar System Implementation

**Yapılanlar**:
- `avatars`, `avatar_items`, `child_owned_items`, `child_equipped_items` tabloları
- AvatarService: PurchaseItem (puan kontrolü), EquipItem, UnequipItem, GetChildAvatar
- AvatarController: 6 endpoint (items, owned, equipped, purchase, equip, unequip)
- Flutter: Avatar profil ekranı, mağaza ekranı, envanter, equip/unequip akışı
- `PointBalanceWidget` (dashboard + mağaza entegrasyonu)
- İş Kuralları: TotalCoins puan deposu, ItemType başına 1 equip, başlangıç 100 puan

### ✅ Sprint 5 - Leaderboard ve SignalR Altyapısı (TAMAMLANDI)
**Git**: `2814f8f` — Sprint 5: Leaderboard + SignalR realtime updates implementation

**Yapılanlar**:
- SignalR LeaderboardHub kurulumu, connection yönetimi
- `leaderboard_entries` tablosu, LeaderboardService
- Canlı skor push (quiz tamamlanınca leaderboard güncelleme)
- Flutter: Leaderboard ekranı, sıra gösterimi, realtime listener

### ✅ Sprint 6 - 1v1 Canlı Matematik Yarışı (TAMAMLANDI)
**Git**: `3b09aa9` (core) + `62a1b54` (teknik borçlar)

**Yapılanlar**:
- SignalR MatchHub: eşleşme, soru akışı, skor, sonuç, forfeit
- `match_requests`, `match_sessions`, `match_participants`, `match_questions`, `match_answers` tabloları
- MatchmakingService: seviye bazlı eşleştirme (MaxLevelDifference=10, TODO: prod=1)
- Server authoritative scoring, berabere tespiti
- Flutter: Arena ekranı, eşleşme bekleme, canlı yarış, sonuç ekranı, maç geçmişi
- **Teknik Borçlar (TB)**: ILogger, print temizliği, forfeit (OnDisconnected), isDraw, Abandoned maçlar geçmişte, Dashboard'dan geçmiş navigasyonu

### ✅ Sprint 7 - Ebeveyn Raporları ve Güvenlik (TAMAMLANDI)
**Amaç**: Ebeveyn tarafını görünür hale getirmek

**İşler**:
- Ebeveyn dashboard, günlük/haftalık aktivite özeti
- Güçlü/zayıf konu analizi, nickname filtreleme

### 📅 Sprint 8 - Bilge-Dost + World Events + Otomasyon (SON SPRINT PLANI)
**Amaç**: MVP'yi son sprintte motivasyon ve topluluk özellikleriyle tamamlamak.

**İşler**:
- Bilge-Dost V1: `pet_states` modeli, quiz/progress entegrasyonu, dashboard pet kartı
- World Events V1: global hedef modeli, katkı hesaplama, canlı event progress (SignalR)
- Otomasyon: haftalık reset/ödül dağıtımı, idempotent ödül kontrolü
- Dengeleme: hedef/ödül parametrelerinin telemetriye göre ayarlanması
- Son stabilizasyon: kritik bug fix, performans ve release checklist

### ✅ Sprint 9 - PostgreSQL Migration (TAMAMLANDI - 15 task) ⭐
**Amaç**: SQLite → PostgreSQL geçişi (Production-ready database)

**Ön Hazırlık** (3):
- Docker Compose PostgreSQL service
- NuGet package değişikliği (SQLite → Npgsql)
- Connection string yapılandırması

**Kod Değişiklikleri** (4):
- Program.cs: UseSqlite → UseNpgsql
- Migration'ları yeniden oluştur (PostgreSQL uyumlu)
- Entity configurations: Data type mapping (TEXT→VARCHAR, DATETIME→TIMESTAMP, GUID→UUID)
- Data seeder PostgreSQL uyumluluğu

**Test & Doğrulama** (5):
- Docker container başlat ve test et
- Migration uygula, tablo kontrolü
- Data seeding test, API endpoint testleri
- Performance & index optimizasyonu

**Production** (3):
- Environment variables (DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD)
- Backup/restore stratejisi (pg_dump)
- Documentation güncellemesi

**NOT**: Bu sprint yalnızca database geçişine ayrıldı ve başarıyla tamamlandı.

---

## Teknik Stack

### Backend (.NET 8.0)
- **Framework**: ASP.NET Core Web API
- **ORM**: EF Core 8.0.4
- **Database**: PostgreSQL (production-ready)
- **Auth**: JWT + BCrypt password hashing
- **Validation**: FluentValidation
- **Logging**: Serilog
- **API Docs**: Swagger/OpenAPI
- **Durum**: Sprint 2 tamamlandı ✅
- **API**: http://localhost:5077/swagger

### Frontend (Flutter 3.11.5)
- **State**: Riverpod 2.5.1 (StateNotifier, FutureProvider)
- **Navigation**: Go Router 14.8.1
- **HTTP**: Dio 5.4.0
- **Serialization**: Freezed 2.5.2 + json_annotation 4.9.0
- **Storage**: SharedPreferences + flutter_secure_storage 9.2.4
- **UI**: Material3, confetti 0.7.0
- **Durum**: Sprint 2 tamamlandı ✅

---

## Tamamlanan İşler

### Sprint 1: Auth & Profile System ✅

#### Backend
- **Domain**: User, ParentProfile, ChildProfile, RefreshToken entities
- **Enums**: UserRole, GradeLevel
- **Infrastructure**: ApplicationDbContext, EF configurations, Repository pattern
- **Services**: JwtService, PasswordHasher, AuthService, ChildProfileService
- **API**: AuthController (4 endpoint), ChildProfileController (5 endpoint)
- **Database**: SQLite migration, 1 test user (gunesatesok@gmail.com / Test1234!)

#### Frontend
- **Theme**: AppColors, AppTheme (Material3), ThemeProvider (dark/light + persistence)
- **Constants**: ApiConstants, StorageKeys, RegexPatterns
- **Widgets**: ThemeSwitcher (icon + list tile)

### Sprint 2: Matematik Eğitim Motoru V1 ✅

#### Backend (31 dosya)
**Domain Entities**:
- Subject (Id, Name, DisplayOrder, IsActive)
- Topic (Id, SubjectId FK, Name, Description, DisplayOrder, IsActive)
- Level (Id, TopicId FK, Name, Description, Difficulty, MinCorrectToPass, DisplayOrder)
- Question (Id, LevelId FK, QuestionText, QuestionType, CorrectAnswer, Explanation)
- QuestionOption (Id, QuestionId FK, OptionText, DisplayOrder)
- QuestionType enum (1=MultipleChoice, 2=TrueFalse, 3=NumericInput)

**EF Configurations**:
- 5 EntityTypeConfiguration dosyası
- Foreign keys, indexes, defaults (MinCorrectToPass=7, IsActive=true)

**Migration**:
- AddEducationEntities (5 tablo oluşturma)

**Seeding** (EducationDataSeeder.cs):
- 1 Subject: Matematik
- 4 Topics: Sayı & Görsel (10 soru), Toplama (5), Çıkarma (5), Problemler (5)
- 4 Levels: Her topic için 1 seviye (Okul Öncesi, Seviye 1)
- 25 Questions: 1. sınıf soruları (NumericInput tipi)

**Application Layer**:
- 8 DTO: SubjectDto, TopicDto, LevelDto, QuestionDto, QuestionOptionDto, SubmitAnswerRequest/Response, QuizResultDto
- IEducationService & EducationService
- IEducationRepository & EducationRepository
- **Business Logic**: Random soru seçimi, case-insensitive cevap kontrolü

**API** (EducationController):
- `GET /api/education/subjects`
- `GET /api/education/subjects/{id}/topics`
- `GET /api/education/topics/{id}/levels`
- `GET /api/education/levels/{id}/questions?count=10`
- `POST /api/education/questions/submit-answer`

#### Frontend (35 dosya)

**Freezed Models** (6 + 12 generated):
- subject.dart, topic.dart, level.dart
- question.dart (QuestionType enum), question_option.dart
- submit_answer_response.dart
- **@JsonKey(name: 'PascalCase')** mapping (Backend uyumluluğu)

**Services**:
- EducationService (Dio client wrapper)

**Providers** (Riverpod):
- subjectListProvider (FutureProvider)
- topicListProvider (FutureProvider.family)
- levelListProvider (FutureProvider.family)
- quizProvider (StateNotifierProvider + QuizState)

**QuizState**:
- questions, currentQuestionIndex, userAnswers Map, results Map
- isLoading, isCompleted
- Computed: currentQuestion, correctCount, wrongCount, successPercentage
- Methods: startQuiz(), submitAnswer(), nextQuestion(), resetQuiz()

**Screens** (5):
1. **SubjectSelectionScreen**: Grid view, subject kartları (icon + color)
2. **TopicSelectionScreen**: Topic listesi (icon patterns: 📊➕➖💡)
3. **LevelListScreen**: Level kartları (zorluk renkleri, MinCorrectToPass gösterimi)
4. **QuizScreen**: Progress bar, soru kartı, AnswerWidget, SnackBar feedback, loading overlay
5. **QuizResultScreen**: Circular progress, stat cards, confetti (%70+), "Ana Sayfaya Dön"

**Widgets** (1):
- **AnswerWidget**: 3 soru tipi (MultipleChoice şık kartları, TrueFalse butonları, NumericInput TextField)

**Router**:
- 5 route eklendi (/education/subjects, /topics/:id, /levels/:id, /quiz/:id, /quiz-result)

**Dashboard**:
- Matematik butonu aktif edildi (enabled=true, onTap navigation)

---

## Sıradaki Adımlar (Öncelik Sırasına Göre)

### 1) Sprint 8 - Son Sprint Planı
- 8.1 Bilge-Dost V1: pet state, quiz/progress entegrasyonu, dashboard kartı
- 8.2 World Events V1: global hedef, event katkısı, SignalR canlı ilerleme
- 8.3 Otomasyon ve Dengeleme: haftalık reset, ödül dağıtımı, metrik bazlı tuning
- 8.4 Son Stabilizasyon: kritik bug fix, performans kontrolü, release checklist

---

## Önemli Dosyalar

### Backend
- `backend/MiniBilge.API/appsettings.json` - JWT secret, DB connection
- `backend/MiniBilge.API/Program.cs` - Middleware, DI, CORS
- `backend/docker-compose.yml` - PostgreSQL servisi ve altyapı tanımı
- `backend/MiniBilge.Infrastructure/Data/Seeders/EducationDataSeeder.cs` - 25 soru

### Frontend
- `mobile/minibilge_mobile/pubspec.yaml` - Dependencies (confetti eklendi)
- `mobile/minibilge_mobile/lib/main.dart` - App entry + ProviderScope
- `mobile/minibilge_mobile/lib/core/constants/app_constants.dart` - API base URL
- `mobile/minibilge_mobile/lib/features/education/` - Education feature dosyaları

---

## API Endpoints (Hazır)

### AuthController (4 endpoint)
- POST `/api/auth/register` - Parent kaydı
- POST `/api/auth/login` - JWT token
- POST `/api/auth/refresh` - Token refresh
- POST `/api/auth/logout` - Logout

### ChildProfileController (5 endpoint)
- GET `/api/childprofile` - Tüm profiller
- GET `/api/childprofile/{id}` - Tek profil
- POST `/api/childprofile` - Yeni profil
- PUT `/api/childprofile/{id}` - Güncelle
- DELETE `/api/childprofile/{id}` - Soft delete

### EducationController (5 endpoint) ✅ YENİ
- GET `/api/education/subjects`
- GET `/api/education/subjects/{id}/topics`
- GET `/api/education/topics/{id}/levels`
- GET `/api/education/levels/{id}/questions?count=10`
- POST `/api/education/questions/submit-answer`

---

## Komutlar

### Backend Çalıştır
```bash
cd backend/MiniBilge.API
dotnet run
# Swagger: http://localhost:5077/swagger
```

### Frontend Çalıştır
```bash
cd mobile/minibilge_mobile
flutter run -d chrome  # Web
flutter run -d macos   # macOS (gerekirse)
```

### Frontend Build Runner
```bash
cd mobile/minibilge_mobile
dart run build_runner build --delete-conflicting-outputs
```

### Git
```bash
git add .
git commit -m "feat: Sprint X - ..."
git push origin main
```

---

## Test Kullanıcısı
- **Email**: gunesatesok@gmail.com
- **Password**: Test1234!
- **Parent**: Güneş Ateşok
- **Children**: Ada (4. Sınıf, 9 yaş), Mocha (1. Sınıf, 6 yaş)

---

## Database İçeriği

### Education Data (Sprint 2)
- **1 Subject**: Matematik
- **4 Topics**: Sayı & Görsel, Toplama, Çıkarma, Problemler
- **4 Levels**: Her topic için 1 level (Okul Öncesi, Seviye 1)
- **25 Questions**: 1. sınıf sorular (NumericInput)
  - Sayı & Görsel: 10 soru (1-10 arası sayılar)
  - Toplama: 5 soru (3+6=?, 5+2=?, vb.)
  - Çıkarma: 5 soru (8-3=?, 10-4=?, vb.)
  - Problemler: 5 soru (sözel matematik)

---

## Notlar
- PostgreSQL aktif kullanımda (migration tamamlandı)
- Docker/PostgreSQL altyapısı aktif kullanılıyor (docker-compose.yml)
- Flutter Web + macOS için çalışıyor
- API CORS açık (development)
- JWT expiry: 60 dakika, Refresh token: 7 gün
- Confetti package: quiz sonuç ekranında %70+ başarıda animasyon

---

## Son Güncellemeler
- **20 Nisan 2026**: Sprint 2 tamamlandı ve GitHub'a push edildi (6c1ff0a)
- **66 dosya değişti**: +5,847 satır eklendi, -9 satır silindi
- **Repo**: https://github.com/gatesok/miniBilge.git
- **Sıradaki**: Sprint 8 (Son Sprint) — Bilge-Dost V1 + World Events V1 + Otomasyon ve Dengeleme
