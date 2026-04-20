# MiniBilge MVP - Detaylı Teknik Analiz
## Sprint Bazlı Backend ve Frontend Teknik Dokümantasyon

**Versiyon:** 1.0  
**Tarih:** 20 Nisan 2026  
**Proje:** Eğitici Oyun Mobil Uygulaması - MiniBilge

---

## İçindekiler

1. [Genel Teknoloji Stack](#genel-teknoloji-stack)
2. [Mimari Yaklaşım](#mimari-yaklaşım)
3. [Sprint 0 - Ürün Keşfi ve Teknik Hazırlık](#sprint-0)
4. [Sprint 1 - Proje Setup ve Kimlik/Profil Altyapısı](#sprint-1)
5. [Sprint 2 - Matematik Eğitim Motoru V1](#sprint-2)
6. [Sprint 3 - Progress, Puan ve Level Unlock Sistemi](#sprint-3)
7. [Sprint 4 - Coin Sistemi, Avatar ve Ödül Mağazası](#sprint-4)
8. [Sprint 5 - Leaderboard ve SignalR Altyapısı](#sprint-5)
9. [Sprint 6 - 1v1 Canlı Matematik Yarışı](#sprint-6)
10. [Sprint 7 - Ebeveyn Raporları ve Güvenlik Kontrolleri](#sprint-7)
11. [Sprint 8 - Stabilizasyon, Performans ve Yayın Hazırlığı](#sprint-8)

---

## Genel Teknoloji Stack

### Backend
```
- Runtime: .NET 8.0
- Framework: ASP.NET Core Web API
- ORM: Entity Framework Core 8.0
- Database: PostgreSQL 16
- Real-time: SignalR
- Validation: FluentValidation
- Logging: Serilog
- API Docs: Swagger/OpenAPI
- Authentication: JWT Bearer Token
```

### Frontend
```
- Framework: Flutter 3.x
- Language: Dart 3.x
- State Management: Riverpod
- Routing: Go Router
- HTTP Client: Dio
- Code Generation: freezed, json_serializable
- Dependency Injection: get_it
```

### Database
```
- PostgreSQL 16
- Provider: Npgsql
- Migration: EF Core Migrations
```

### DevOps & Infrastructure
```
- Containerization: Docker
- Orchestration: Docker Compose
- CI/CD: GitHub Actions
- Reverse Proxy: Nginx
- Cache (Optional): Redis
- Storage (Optional): MinIO
```

---

## Mimari Yaklaşım

### Backend Katmanlı Mimari

```
MiniBilge.API/              # API Layer (Controllers, Middleware, Filters)
MiniBilge.Application/      # Application Layer (Services, DTOs, Interfaces)
MiniBilge.Domain/           # Domain Layer (Entities, Value Objects, Enums)
MiniBilge.Infrastructure/   # Infrastructure Layer (Data Access, External Services)
MiniBilge.Shared/          # Shared utilities, Constants, Extensions
```

### Flutter Feature-Based Yapı

```
lib/
├── core/                  # Core utilities, constants, themes
├── shared/               # Shared widgets, services, models
└── features/
    ├── auth/            # Authentication feature
    ├── profile/         # Profile management
    ├── learning/        # Learning/Math engine
    ├── avatar/          # Avatar & items
    ├── leaderboard/     # Leaderboard
    ├── matchmaking/     # Live competition
    └── parent_dashboard/ # Parent reporting
```

---

## Sprint 0 - Ürün Keşfi ve Teknik Hazırlık

### Sprint Amacı
Proje altyapısının kurulması, mimari kararların netleştirilmesi ve temel dokümantasyonun hazırlanması.

### 1. Backend Teknik Detaylar

#### 1.1 Solution Yapısı Oluşturma

**Proje Oluşturma Komutları:**
```bash
# Solution oluşturma
dotnet new sln -n MiniBilge

# Projeler oluşturma
dotnet new webapi -n MiniBilge.API
dotnet new classlib -n MiniBilge.Application
dotnet new classlib -n MiniBilge.Domain
dotnet new classlib -n MiniBilge.Infrastructure
dotnet new classlib -n MiniBilge.Shared

# Solution'a ekleme
dotnet sln add MiniBilge.API/MiniBilge.API.csproj
dotnet sln add MiniBilge.Application/MiniBilge.Application.csproj
dotnet sln add MiniBilge.Domain/MiniBilge.Domain.csproj
dotnet sln add MiniBilge.Infrastructure/MiniBilge.Infrastructure.csproj
dotnet sln add MiniBilge.Shared/MiniBilge.Shared.csproj

# Proje referansları
dotnet add MiniBilge.API reference MiniBilge.Application
dotnet add MiniBilge.Application reference MiniBilge.Domain
dotnet add MiniBilge.Infrastructure reference MiniBilge.Domain
dotnet add MiniBilge.API reference MiniBilge.Infrastructure
```

#### 1.2 NuGet Paketleri

**MiniBilge.API:**
```xml
<PackageReference Include="Microsoft.AspNetCore.Authentication.JwtBearer" Version="8.0.*" />
<PackageReference Include="Microsoft.AspNetCore.SignalR" Version="1.1.*" />
<PackageReference Include="Serilog.AspNetCore" Version="8.0.*" />
<PackageReference Include="Swashbuckle.AspNetCore" Version="6.5.*" />
```

**MiniBilge.Application:**
```xml
<PackageReference Include="FluentValidation" Version="11.9.*" />
<PackageReference Include="AutoMapper" Version="13.0.*" />
```

**MiniBilge.Infrastructure:**
```xml
<PackageReference Include="Microsoft.EntityFrameworkCore" Version="8.0.*" />
<PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="8.0.*" />
<PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="8.0.*" />
```

#### 1.3 Temel Klasör Yapısı

**MiniBilge.Domain yapısı:**
```
Domain/
├── Entities/
│   ├── Base/
│   │   └── BaseEntity.cs
│   ├── User.cs
│   └── ...
├── Enums/
│   ├── UserRole.cs
│   └── ...
├── ValueObjects/
└── Interfaces/
```

**MiniBilge.Application yapısı:**
```
Application/
├── DTOs/
│   ├── Auth/
│   └── ...
├── Interfaces/
│   ├── Services/
│   └── Repositories/
├── Services/
├── Validators/
└── Mappings/
```

**MiniBilge.Infrastructure yapısı:**
```
Infrastructure/
├── Data/
│   ├── ApplicationDbContext.cs
│   ├── Configurations/
│   └── Migrations/
├── Repositories/
└── Services/
```

#### 1.4 Temel Entity Base Class

```csharp
// MiniBilge.Domain/Entities/Base/BaseEntity.cs
namespace MiniBilge.Domain.Entities.Base;

public abstract class BaseEntity
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public bool IsDeleted { get; set; }
}
```

#### 1.5 DbContext Taslak

```csharp
// MiniBilge.Infrastructure/Data/ApplicationDbContext.cs
using Microsoft.EntityFrameworkCore;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    // DbSets will be added in subsequent sprints
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // Apply configurations
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
    }
}
```

#### 1.6 appsettings.json Yapılandırması

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=minibilge_db;Username=minibilge_user;Password=your_password"
  },
  "JwtSettings": {
    "SecretKey": "your-secret-key-min-32-characters-long",
    "Issuer": "MiniBilge.API",
    "Audience": "MiniBilge.Client",
    "ExpirationMinutes": 60,
    "RefreshTokenExpirationDays": 7
  },
  "Serilog": {
    "MinimumLevel": "Information",
    "WriteTo": [
      {
        "Name": "Console"
      },
      {
        "Name": "File",
        "Args": {
          "path": "logs/log-.txt",
          "rollingInterval": "Day"
        }
      }
    ]
  }
}
```

#### 1.7 Docker Compose Yapılandırması

```yaml
# docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: minibilge_postgres
    environment:
      POSTGRES_DB: minibilge_db
      POSTGRES_USER: minibilge_user
      POSTGRES_PASSWORD: your_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - minibilge_network

  api:
    build:
      context: ./backend
      dockerfile: MiniBilge.API/Dockerfile
    container_name: minibilge_api
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Host=postgres;Port=5432;Database=minibilge_db;Username=minibilge_user;Password=your_password
    ports:
      - "5000:8080"
    depends_on:
      - postgres
    networks:
      - minibilge_network

volumes:
  postgres_data:

networks:
  minibilge_network:
    driver: bridge
```

### 2. Database Schema (Sprint 0)

Sprint 0'da herhangi bir tablo oluşturulmaz, sadece altyapı hazırlığı yapılır.

### 3. Frontend Teknik Detaylar

#### 3.1 Flutter Proje Oluşturma

```bash
flutter create minibilge_mobile
cd minibilge_mobile
```

#### 3.2 pubspec.yaml Temel Bağımlılıklar

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  
  # Routing
  go_router: ^14.0.0
  
  # HTTP & API
  dio: ^5.4.0
  retrofit: ^4.0.0
  
  # Code Generation
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
  # Dependency Injection
  get_it: ^7.6.0
  injectable: ^2.3.2
  
  # Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # UI
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  
  # Utils
  intl: ^0.19.0
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Generation
  build_runner: ^2.4.8
  freezed: ^2.4.7
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.11
  retrofit_generator: ^8.0.0
  injectable_generator: ^2.4.1
  
  # Linting
  flutter_lints: ^3.0.0
```

#### 3.3 Klasör Yapısı

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── api_constants.dart
│   │   └── asset_constants.dart
│   ├── themes/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_text_styles.dart
│   ├── di/
│   │   └── injection.dart
│   ├── routing/
│   │   └── app_router.dart
│   └── utils/
│       ├── extensions/
│       └── helpers/
├── shared/
│   ├── widgets/
│   │   ├── buttons/
│   │   ├── inputs/
│   │   └── loading/
│   ├── models/
│   │   └── api_response.dart
│   └── services/
│       ├── api_service.dart
│       └── storage_service.dart
└── features/
    └── (Sprint bazında eklenecek)
```

#### 3.4 Tema Yapılandırması (Taslak)

```dart
// lib/core/themes/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9C96FF);
  static const Color primaryDark = Color(0xFF3D35CC);
  
  // Secondary colors
  static const Color secondary = Color(0xFFFF6584);
  static const Color secondaryLight = Color(0xFFFF96AD);
  static const Color secondaryDark = Color(0xFFCC3461);
  
  // Backgrounds
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);
  
  // Success, Warning, Error
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  
  // Avatar & Game colors
  static const Color coin = Color(0xFFFFD700);
  static const Color star = Color(0xFFFFA500);
}
```

```dart
// lib/core/themes/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Poppins', // Custom font eklenecek
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      
      // Button themes will be added
      // Input decoration themes will be added
    );
  }
}
```

#### 3.5 API Service Base

```dart
// lib/shared/services/api_service.dart
import 'package:dio/dio.dart';

class ApiService {
  late final Dio _dio;
  
  ApiService({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? 'http://localhost:5000/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
    
    // Auth interceptor will be added
    // Error interceptor will be added
  }
  
  Dio get dio => _dio;
}
```

#### 3.6 Routing Taslak

```dart
// lib/core/routing/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Routes will be added sprint by sprint
    ],
  );
}
```

### 4. API Contracts

Sprint 0'da API contract yoktur. Altyapı hazırlığı sprint'idir.

### 5. Test Senaryoları

#### Backend Test Yapısı
```bash
# Test projeleri oluşturma
dotnet new xunit -n MiniBilge.Tests.Unit
dotnet new xunit -n MiniBilge.Tests.Integration

dotnet sln add MiniBilge.Tests.Unit/MiniBilge.Tests.Unit.csproj
dotnet sln add MiniBilge.Tests.Integration/MiniBilge.Tests.Integration.csproj
```

#### Flutter Test Yapısı
```
test/
├── unit/
├── widget/
└── integration/
```

### 6. Sprint 0 Çıktıları Checklist

- [ ] Backend solution yapısı oluşturuldu
- [ ] NuGet paketleri eklendi
- [ ] DbContext taslak hazırlandı
- [ ] Docker Compose yapılandırıldı
- [ ] Flutter projesi oluşturuldu
- [ ] pubspec.yaml bağımlılıkları eklendi
- [ ] Klasör yapısı kuruldu
- [ ] Tema sistemi taslağı hazırlandı
- [ ] API service base class oluşturuldu
- [ ] Routing altyapısı kuruldu
- [ ] Test projeleri oluşturuldu

---

# MiniBilge MVP - Sprint 1 Tamamlandı ✅

**Tarih:** 20 Nisan 2026  
**Durum:** Backend tamamlandı ve test edildi  
**API URL:** http://localhost:5077  
**Swagger:** http://localhost:5077/swagger

---

## Sprint 1 Özeti

### Backend Tamamlananlar ✅

#### 1. Entities ve Database
- ✅ User, ParentProfile, ChildProfile, RefreshToken entity'leri
- ✅ Entity Configurations (EF Core)
- ✅ SQLite migration oluşturuldu ve uygulandı

#### 2. Repository Pattern
- ✅ IUserRepository & UserRepository
- ✅ IChildProfileRepository & ChildProfileRepository  
- ✅ IRefreshTokenRepository & RefreshTokenRepository

#### 3. Services
- ✅ AuthService: Kayıt, Giriş, Token Yenileme, Çıkış
- ✅ ChildProfileService: Çocuk CRUD işlemleri
- ✅ JwtService: JWT token oluşturma ve validasyon
- ✅ PasswordHasher: BCrypt ile şifre hash/verify

#### 4. API Controllers
- ✅ AuthController (4 endpoint)
- ✅ ChildProfileController (5 endpoint)

#### 5. Security & Validation
- ✅ JWT Bearer Authentication
- ✅ FluentValidation kuralları
- ✅ Role-based authorization

---

## API Endpoints

### Authentication (`/api/auth`)
| Method | Endpoint | Açıklama | Auth |
|--------|----------|----------|------|
| POST | `/register` | Kullanıcı kaydı | No |
| POST | `/login` | Kullanıcı girişi | No |
| POST | `/refresh` | Token yenileme | No |
| POST | `/logout` | Çıkış yapma | No |

### Child Profile (`/api/childprofile`)
| Method | Endpoint | Açıklama | Auth |
|--------|----------|----------|------|
| GET | `/` | Çocukları listele | Yes (Parent) |
| GET | `/{id}` | Çocuk detay | Yes (Parent) |
| POST | `/` | Çocuk oluştur | Yes (Parent) |
| PUT | `/{id}` | Çocuk güncelle | Yes (Parent) |
| DELETE | `/{id}` | Çocuk sil | Yes (Parent) |

---

## Test Senaryosu

### 1. Kayıt Ol
```
POST /api/auth/register
{
  "email": "parent@test.com",
  "password": "Test123",
  "confirmPassword": "Test123",
  "firstName": "Test",
  "lastName": "User",
  "phoneNumber": "5551234567"
}
```

### 2. Giriş Yap
```
POST /api/auth/login
{
  "email": "parent@test.com",
  "password": "Test123"
}
```
→ Response'dan `accessToken` kopyala

### 3. Authorization (Swagger)
- Swagger UI'da "Authorize" butonuna tıkla
- `Bearer {accessToken}` formatında yapıştır

### 4. Çocuk Oluştur
```
POST /api/childprofile
{
  "name": "Ali",
  "dateOfBirth": "2018-05-15",
  "gradeLevel": 1,
  "avatarImageUrl": "avatar-boy-1.png"
}
```

### 5. Çocukları Listele
```
GET /api/childprofile
```

---

## Teknik Stack

### Backend
- .NET 8.0
- ASP.NET Core Web API
- Entity Framework Core 8.0
- SQLite (dev), PostgreSQL (production)
- JWT Bearer Authentication
- BCrypt.Net password hashing
- FluentValidation
- Serilog
- Swagger/OpenAPI

### Klasör Yapısı
```
backend/
├── MiniBilge.API/           # Controllers, Program.cs
├── MiniBilge.Application/   # DTOs, Services, Interfaces, Validators
├── MiniBilge.Domain/        # Entities, Enums
├── MiniBilge.Infrastructure/# Repositories, Data, Configurations
└── MiniBilge.Shared/        # Constants, Extensions
```

---

## Veritabanı Şeması

### users
- Id (PK, GUID)
- Email (Unique)
- PasswordHash
- Role (Parent/Admin)
- IsEmailConfirmed
- LastLoginAt
- CreatedAt, UpdatedAt, IsDeleted

### parent_profiles
- Id (PK, GUID)
- UserId (FK → users)
- FirstName
- LastName
- PhoneNumber
- CreatedAt, UpdatedAt, IsDeleted

### child_profiles
- Id (PK, GUID)
- ParentProfileId (FK → parent_profiles)
- Name
- DateOfBirth
- GradeLevel (0=PreSchool, 1-4=Grade)
- AvatarImageUrl
- TotalCoins, TotalStars
- CreatedAt, UpdatedAt, IsDeleted

### refresh_tokens
- Id (PK, GUID)
- UserId (FK → users)
- Token (Unique)
- ExpiresAt
- IsRevoked
- IpAddress, UserAgent
- CreatedAt, UpdatedAt, IsDeleted

---

## Sonraki Adımlar

### Sprint 2 - Matematik Eğitim Motoru
- Subject, Topic, Level, Question entities
- Soru havuzu yönetimi
- Soru çözme API'leri
- Cevap değerlendirme sistemi

### Frontend İçin Hazırlık
Backend hazır ve test edildi. Flutter projesi için:
1. Flutter proje kurulumu
2. Riverpod state management
3. API integration (Retrofit + Dio)
4. Auth flow ekranları
5. Child profile yönetimi

---

## Notlar
- ✅ Build başarılı (uyarılar: AutoMapper vulnerability - production'da güncellenecek)
- ✅ Migration başarıyla uygulandı
- ✅ Swagger UI çalışıyor ve test edildi
- ✅ JWT authentication çalışıyor
- ⚠️  SQLite kullanılıyor (development), production için PostgreSQL
- 📝 Docker/PostgreSQL setup opsiyonel (şimdilik SQLite yeterli)
