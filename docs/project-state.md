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

### 🔄 Sprint 3 - Progress, Puan ve Level Unlock (PLANLANDI - 20 task)
**Amaç**: İlerleme kalıcılığı, puan/yıldız sistemi, level unlock mekanizması

**Backend Tasklar** (9):
- child_progress, answer_attempts, level_results tabloları
- Puan hesaplama (doğru: +10, bonus: +5)
- Yıldız hesaplama (⭐ %30-49, ⭐⭐ %50-79, ⭐⭐⭐ %80-100)
- Level unlock kuralları (%70 başarı gerekli)
- 3 yeni API endpoint (progress CRUD)

**Frontend Tasklar** (7):
- Progress models + providers
- Dashboard'da 🏆 puan + ⭐ yıldız gösterimi
- Level listede 🔒 kilit/🔓 açık durumu
- Bölüm başarı özeti (+70 puan, ⭐⭐ gösterimi)
- İlerleme barı, tekrar çözme desteği

**Test Tasklar** (4):
- Puan/yıldız hesaplama, level unlock, tekrar çözüm testleri

---

## Teknik Stack

### Backend (.NET 8.0)
- **Framework**: ASP.NET Core Web API
- **ORM**: EF Core 8.0.4
- **Database**: SQLite (dev), PostgreSQL (prod planı)
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

### Sprint 3: Progress & Gamification (20 task)

#### Backend Database (3 task)
1. **child_progress** tablosu
   - Columns: ChildProfileId, LevelId, IsCompleted, Score, Stars, CompletedAt
   - Purpose: Her child'ın her level'daki ilerlemesi

2. **answer_attempts** tablosu
   - Columns: ChildProfileId, QuestionId, UserAnswer, IsCorrect, AttemptedAt
   - Purpose: Tüm cevap denemeleri (tekrar çözüm için)

3. **level_results** tablosu
   - Columns: ChildProfileId, LevelId, CorrectCount, WrongCount, TotalQuestions, SuccessPercentage, CompletedAt
   - Purpose: Her quiz tamamlandığında detaylı sonuç

#### Backend Services (6 task)
4. **Puan hesaplama servisi**
   - Doğru cevap: +10 puan
   - Yanlış: 0 puan
   - Bonus: İlk denemede doğru +5 puan

5. **Yıldız hesaplama mantığı**
   - %30-49: ⭐ 1 yıldız
   - %50-79: ⭐⭐ 2 yıldız
   - %80-100: ⭐⭐⭐ 3 yıldız

6. **Level unlock kuralları**
   - Minimum %70 başarı
   - Sıralı unlock (aynı topic içinde)
   - Geçilen level → sonraki açılır

7-9. **API Endpoints**:
   - `POST /api/progress` - Progress kaydet
   - `POST /api/progress/attempt` - Answer attempt kaydet
   - `GET /api/progress/{childId}` - Child progress getir

#### Frontend (7 task)
10. **Progress models** (Freezed): ChildProgress, LevelResult, AnswerAttempt
11. **Quiz sonunda progress kaydetme**: Backend'e POST
12. **Level listede kilit/açık**: 🔒 Kilitli (gri), 🔓 Açık (tıklanabilir)
13. **Dashboard stats**: 🏆 Toplam puan, ⭐ Toplam yıldız
14. **İlerleme barı**: Topic seviyesinde (3/4 level tamamlandı)
15. **Quiz result güncelleme**: +70 puan, ⭐⭐ 2 yıldız, "Sonraki Level Açıldı!"
16. **Tekrar çözme**: Tamamlanmış level'lar tekrar çözülebilir

#### Test (4 task)
17-19. Puan, yıldız, level unlock, tekrar çözüm testleri
20. Sprint 3 E2E test

---

## Önemli Dosyalar

### Backend
- `backend/MiniBilge.API/appsettings.json` - JWT secret, DB connection
- `backend/MiniBilge.API/Program.cs` - Middleware, DI, CORS
- `backend/MiniBilge.API/minibilge.db` - SQLite database
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
- PostgreSQL yerine SQLite (development kolaylığı)
- Docker hazır ama kullanılmıyor (docker-compose.yml mevcut)
- Flutter Web + macOS için çalışıyor
- API CORS açık (development)
- JWT expiry: 60 dakika, Refresh token: 7 gün
- Confetti package: quiz sonuç ekranında %70+ başarıda animasyon

---

## Son Güncellemeler
- **20 Nisan 2026**: Sprint 2 tamamlandı ve GitHub'a push edildi (6c1ff0a)
- **66 dosya değişti**: +5,847 satır eklendi, -9 satır silindi
- **Repo**: https://github.com/gatesok/miniBilge.git
- **Sıradaki**: Sprint 3 - Progress, Puan ve Level Unlock Sistemi (20 task)
