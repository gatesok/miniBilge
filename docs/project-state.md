# MiniBilge Proje Durumu

## Proje Özeti
Eğitici mobil oyun MVP - Flutter (frontend) + .NET 8 (backend)
Ebeveyn profili ile çocuk profilleri yönetimi ve eğitici içerik sistemi

## Teknik Stack

### Backend (.NET 8.0)
- ASP.NET Core Web API
- EF Core + SQLite (dev), PostgreSQL (prod planı)
- JWT Authentication + BCrypt
- FluentValidation, Serilog, Swagger
- **Durum**: Sprint 1 tamamlandı ✅
- **API**: http://localhost:5077/swagger

### Frontend (Flutter 3.x)
- Riverpod (state management)
- Go Router (navigation - planlandı)
- Dio + Retrofit (HTTP client - planlandı)
- Freezed (code generation - planlandı)
- SharedPreferences + Secure Storage
- **Durum**: Theme system tamamlandı ✅

## Tamamlanan İşler

### Backend Sprint 1 ✅
- Domain: User, ParentProfile, ChildProfile, RefreshToken entities + UserRole, GradeLevel enums
- Infrastructure: ApplicationDbContext, EF configurations, Repository pattern, JwtService, PasswordHasher
- Application: AuthService, ChildProfileService, DTOs, Validators
- API: AuthController (register/login/refresh/logout), ChildProfileController (CRUD)
- Database: SQLite migrated, 1 test user kayıtlı

### Frontend Theme System ✅
**Dosyalar**:
- `lib/core/theme/app_colors.dart` - Light/Dark renk paleti
- `lib/core/theme/app_theme.dart` - Material3 ThemeData (light/dark)
- `lib/core/theme/theme_provider.dart` - Riverpod StateNotifier + SharedPreferences persistence
- `lib/core/constants/app_constants.dart` - API URLs, storage keys, regex patterns
- `lib/shared/widgets/theme_switcher.dart` - Theme toggle widget
- `lib/main.dart` - ProviderScope + theme integration + splash screen

**Özellikler**:
- Dark/Light tema dinamik geçişi ✅
- Tema tercihi kalıcı saklama ✅
- Material3 tasarım sistemi ✅
- AppBar'da tema toggle icon ✅

## Sıradaki Adımlar (Öncelik Sırasına Göre)

### 1. Auth Feature - Models & Services
- [ ] Freezed modelleri: AuthResponse, LoginRequest, RegisterRequest, UserDto, RefreshTokenRequest
- [ ] Retrofit API service: AuthApiService
- [ ] Dio interceptor: Token yönetimi, auto-refresh
- [ ] Auth repository: API service wrapper
- [ ] Auth state provider: Login durumu, user session

### 2. Auth Feature - Screens
- [ ] LoginScreen: Email/password form + validation
- [ ] RegisterScreen: Parent kayıt formu + validation
- [ ] Form validators: Email, password, phone regex
- [ ] Error handling: API errors, network errors
- [ ] Loading states: CircularProgressIndicator

### 3. Routing Setup
- [ ] Go Router configuration
- [ ] Auth guard: Protected routes
- [ ] Route definitions: /, /login, /register, /home, /profile
- [ ] Deep linking support

### 4. Profile Feature
- [ ] ChildProfile models (Freezed)
- [ ] ChildProfile API service
- [ ] CRUD screens: List, Add, Edit, Delete child profiles
- [ ] Grade level selector
- [ ] Profile state management

## Önemli Dosyalar

### Backend
- `backend/MiniBilge.API/appsettings.json` - JWT secret, DB connection
- `backend/MiniBilge.API/Program.cs` - Middleware, DI configuration
- `backend/MiniBilge.API/minibilge.db` - SQLite database (64KB)

### Frontend
- `mobile/minibilge_mobile/pubspec.yaml` - Dependencies
- `mobile/minibilge_mobile/lib/main.dart` - App entry point
- `mobile/minibilge_mobile/lib/core/constants/app_constants.dart` - API base URL

## API Endpoints (Hazır)

### AuthController
- POST `/api/auth/register` - Ebeveyn kaydı
- POST `/api/auth/login` - Giriş (JWT token)
- POST `/api/auth/refresh` - Token yenileme
- POST `/api/auth/logout` - Çıkış

### ChildProfileController
- GET `/api/childprofiles` - Tüm çocuk profilleri
- GET `/api/childprofiles/{id}` - Tek profil
- POST `/api/childprofiles` - Yeni profil
- PUT `/api/childprofiles/{id}` - Güncelleme
- DELETE `/api/childprofiles/{id}` - Silme (soft delete)

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
flutter run -d macos   # macOS
```

### Database Kontrol
- DataGrip ile bağlan: `backend/MiniBilge.API/minibilge.db`

## Test Kullanıcısı
- Email: gunesatesok@gmail.com
- Password: Test1234!
- Parent Profile: Güneş Ateşok

## Notlar
- PostgreSQL yerine SQLite kullanılıyor (development kolaylığı)
- Docker hazır ama kullanılmıyor (docker-compose.yml mevcut)
- Flutter Web + macOS için çalışıyor (Android/iOS toolchain yok)
- API CORS açık (development)
- JWT token expiry: 60 dakika
- Refresh token expiry: 7 gün
