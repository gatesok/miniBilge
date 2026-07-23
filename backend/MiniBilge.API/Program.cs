using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using MiniBilge.API.Hubs;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Services;
using MiniBilge.API.Services;
using MiniBilge.Infrastructure.Services;
using MiniBilge.Infrastructure.Data;
using MiniBilge.Infrastructure.Extensions;
using MiniBilge.Infrastructure.Repositories;
using MiniBilge.API.Health;
using MiniBilge.API.Middleware;
using Serilog;
using System.Text;
var builder = WebApplication.CreateBuilder(args);

// Serilog
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .CreateLogger();

builder.Host.UseSerilog();

// Database — provider (SQLite / PostgreSQL) is driven by "DatabaseProvider" in appsettings.json
builder.Services.AddDatabaseProvider(builder.Configuration);

// JWT Authentication
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSettings["Issuer"],
            ValidAudience = jwtSettings["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtSettings["SecretKey"]!))
        };
        // SignalR: Token query string üzerinden de alınabilir
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var accessToken = context.Request.Query["access_token"];
                var path = context.HttpContext.Request.Path;
                if (!string.IsNullOrEmpty(accessToken) &&
                    path.StartsWithSegments("/hubs"))
                {
                    context.Token = accessToken;
                }
                return Task.CompletedTask;
            }
        };
    });

builder.Services.AddAuthorization();

// Repositories
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IChildProfileRepository, ChildProfileRepository>();
builder.Services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
builder.Services.AddScoped<IPasswordResetTokenRepository, PasswordResetTokenRepository>();
builder.Services.AddScoped<IEducationRepository, EducationRepository>();
builder.Services.AddScoped<IProgressRepository, ProgressRepository>();
builder.Services.AddScoped<IAvatarRepository, AvatarRepository>();
builder.Services.AddScoped<IMatchRepository, MatchRepository>();
builder.Services.AddScoped<IDeviceTokenRepository, DeviceTokenRepository>();
builder.Services.AddScoped<IAppNotificationRepository, AppNotificationRepository>();
builder.Services.AddScoped<IBadgeRepository, BadgeRepository>();
builder.Services.AddScoped<ICardRepository, CardRepository>();
builder.Services.AddScoped<IPodcastRepository, PodcastRepository>();
builder.Services.AddScoped<IFlashcardRepository, FlashcardRepository>();
builder.Services.AddScoped<IPodcastQuizRepository, PodcastQuizRepository>();
builder.Services.AddScoped<IFriendshipRepository, FriendshipRepository>();
builder.Services.AddScoped<IMatchInvitationRepository, MatchInvitationRepository>();
builder.Services.AddScoped<IChallengeRepository, ChallengeRepository>();
builder.Services.AddScoped<IClassroomRepository, ClassroomRepository>();

// Services
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<IChildProfileService, ChildProfileService>();
builder.Services.AddScoped<IStorageService, GcsStorageService>();
builder.Services.AddScoped<IEducationService, EducationService>();
builder.Services.AddScoped<IProgressService, ProgressService>();
builder.Services.AddScoped<IAvatarService, AvatarService>();
builder.Services.AddScoped<ILeaderboardService, LeaderboardService>();
builder.Services.AddScoped<ILeaderboardNotifier, LeaderboardHubNotifier>();
builder.Services.AddScoped<IParentReportingService, ParentReportingService>();
builder.Services.AddScoped<IMatchmakingService, MatchmakingService>();
builder.Services.AddScoped<IMatchNotifier, MatchHubNotifier>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<IBadgeService, BadgeService>();
builder.Services.AddScoped<ICardDropService, CardDropService>();
builder.Services.AddScoped<IPodcastService, PodcastService>();
builder.Services.AddScoped<IFlashcardService, FlashcardService>();
builder.Services.AddScoped<IPodcastQuizService, PodcastQuizService>();
builder.Services.AddScoped<IJwtService, JwtService>();
builder.Services.AddScoped<IPasswordHasher, PasswordHasher>();
builder.Services.AddScoped<IFriendshipService, FriendshipService>();
builder.Services.AddScoped<IMatchInvitationService, MatchInvitationService>();
builder.Services.AddScoped<ISocialNotifier, SocialHubNotifier>();
builder.Services.AddScoped<IChallengeService, ChallengeService>();
builder.Services.Configure<MiniBilge.Application.Options.DailyUsageOptions>(
    builder.Configuration.GetSection(
        MiniBilge.Application.Options.DailyUsageOptions.SectionName));
builder.Services.AddScoped<IDailyUsageService, DailyUsageService>();

builder.Services.Configure<MiniBilge.Application.Options.AppleStoreOptions>(
    builder.Configuration.GetSection(
        MiniBilge.Application.Options.AppleStoreOptions.SectionName));
builder.Services.AddHttpClient<IApplePurchaseVerifier, ApplePurchaseVerifier>();

// Adaptive AI Quiz (feature/adaptive-quiz-ai)
builder.Services.AddMemoryCache();
builder.Services.AddScoped<IOpenAiCompletionClient, OpenAiCompletionClient>();
builder.Services.AddScoped<IAdaptiveQuizService,
    MiniBilge.Infrastructure.Services.AdaptiveQuizService>();

// Entertainment Quiz — Stateless AI (Sprint AI-2)
builder.Services.AddScoped<IEntertainmentQuizService,
    MiniBilge.Infrastructure.Services.EntertainmentQuizService>();

// Gerçek mi Uydurma mı? — Stateless AI (Sprint E1)
builder.Services.AddScoped<IFactOrFictionService,
    MiniBilge.Infrastructure.Services.FactOrFictionService>();

// Kim Bu? — Stateless AI (Sprint E2)
builder.Services.AddScoped<IKimBuService,
    MiniBilge.Infrastructure.Services.KimBuService>();

// Ne Ortak? — Stateless AI (Sprint E3)
builder.Services.AddScoped<INeOrtakService,
    MiniBilge.Infrastructure.Services.NeOrtakService>();

// Wordle (Sprint W1)
builder.Services.AddScoped<IWordleAiRefillService,
    MiniBilge.Infrastructure.Services.WordleAiRefillService>();
builder.Services.AddScoped<IWordleService,
    MiniBilge.Infrastructure.Services.WordleService>();

// Wordle Seviyeleri (Sprint W2)
builder.Services.AddScoped<IWordleLevelService,
    MiniBilge.Infrastructure.Services.WordleLevelService>();
builder.Services.AddScoped<IClassroomService, ClassroomService>();

// OpenAI (Sprint 22 – Writing Practice)
builder.Services.Configure<MiniBilge.Application.Options.OpenAiSettings>(
    builder.Configuration.GetSection(MiniBilge.Application.Options.OpenAiSettings.SectionName));

builder.Services.AddHttpClient("openai", (sp, client) =>
{
    var settings = sp.GetRequiredService<Microsoft.Extensions.Options.IOptions<MiniBilge.Application.Options.OpenAiSettings>>().Value;
    client.BaseAddress = new Uri("https://api.openai.com/v1/");
    client.DefaultRequestHeaders.Add("Authorization", $"Bearer {settings.ApiKey}");
    client.Timeout = TimeSpan.FromSeconds(Math.Clamp(settings.TimeoutSeconds, 5, 120));
});

builder.Services.AddScoped<MiniBilge.Application.Interfaces.IWritingService,
    MiniBilge.Application.Services.WritingService>();

builder.Services.AddScoped<MiniBilge.Application.Interfaces.ITopicExplanationService,
    MiniBilge.Application.Services.TopicExplanationService>();

builder.Services.AddScoped<MiniBilge.Application.Interfaces.IVocabChallengeService,
    MiniBilge.Application.Services.VocabChallengeService>();

builder.Services.AddScoped<MiniBilge.Application.Interfaces.IRolePlayService,
    MiniBilge.Application.Services.RolePlayService>();

builder.Services.AddScoped<MiniBilge.Application.Interfaces.IPronunciationService,
    MiniBilge.Application.Services.PronunciationService>();
builder.Services.AddScoped<MiniBilge.Application.Interfaces.Repositories.IRolePlayRepository,
    MiniBilge.Infrastructure.Repositories.RolePlayRepository>();
builder.Services.AddScoped<MiniBilge.Application.Interfaces.Repositories.IRolePlayScenarioRepository,
    MiniBilge.Infrastructure.Repositories.RolePlayScenarioRepository>();

// TTS — Provider-Agnostic (Sprint 19)
// Credentials: GOOGLE_APPLICATION_CREDENTIALS env var (local) veya Cloud Run kimliği (prod)
builder.Services.Configure<MiniBilge.Application.Options.TtsProviderOptions>(
    builder.Configuration.GetSection(MiniBilge.Application.Options.TtsProviderOptions.SectionName));

// Lazy factory — client startup'ta değil, ilk kullanımda oluşturulur
builder.Services.AddSingleton<Google.Cloud.TextToSpeech.V1.TextToSpeechClient>(
    _ => Google.Cloud.TextToSpeech.V1.TextToSpeechClient.Create());
builder.Services.AddSingleton<Google.Cloud.Storage.V1.StorageClient>(
    _ => Google.Cloud.Storage.V1.StorageClient.Create());

builder.Services.AddScoped<MiniBilge.Application.Interfaces.ITtsProvider,
    MiniBilge.Infrastructure.Services.GoogleTtsProvider>();
builder.Services.AddScoped<MiniBilge.Application.Interfaces.ITtsAudioStorage,
    MiniBilge.Infrastructure.Services.GoogleCloudStorageProvider>();
builder.Services.AddScoped<MiniBilge.Application.Services.TtsAudioGeneratorService>();

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = null; // Use PascalCase
    });

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddHealthChecks()
    .AddCheck<DatabaseHealthCheck>("database", tags: ["ready"]);

// SignalR with PascalCase JSON serialization
builder.Services.AddSignalR(options =>
    {
        // Mobil uygulama kapanınca bağlantı kesilmesini hızlı tespit et
        options.KeepAliveInterval       = TimeSpan.FromSeconds(8);
        options.ClientTimeoutInterval   = TimeSpan.FromSeconds(20);
    })
    .AddJsonProtocol(options =>
    {
        options.PayloadSerializerOptions.PropertyNamingPolicy = null; // Use PascalCase
    });

// CORS Configuration for Web App (SignalR requires specific origin, not AllowAnyOrigin)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowWebApp", policy =>
    {
        policy.WithOrigins(
                "http://localhost:*",
                "http://localhost:3000",
                "http://localhost:5077",
                "http://localhost:8080")
              .SetIsOriginAllowed(_ => true) // development
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials(); // SignalR için gerekli
    });
});

builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "MiniBilge API", Version = "v1" });
    
    // JWT Bearer auth configuration
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Example: \"Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

builder.Services.AddHostedService<ExpiryBackgroundService>();
builder.Services.AddHostedService<AssignmentReminderBackgroundService>();

var app = builder.Build();

// Run migrations and seed database
using (var scope = app.Services.CreateScope())
{
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    try
    {
        await context.Database.MigrateAsync();
        await MiniBilge.Infrastructure.Data.Seeders.EducationDataSeeder.SeedAsync(context);
        await MiniBilge.Infrastructure.Data.Seeders.AvatarDataSeeder.SeedAsync(context);
        await MiniBilge.Infrastructure.Data.Seeders.AvatarItemsDataSeeder.SeedAsync(context);
        await MiniBilge.Infrastructure.Data.Seeders.ChildProfileInitialPointsSeeder.SeedAsync(context);
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Database migration/seed failed. The application will start but DB may be unavailable.");
    }
}

// Middleware
app.UseMiddleware<CorrelationIdMiddleware>();
app.UseSwagger();
app.UseSwaggerUI();

// Enable CORS
app.UseCors("AllowWebApp");

if (app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapHealthChecks("/health/live", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
{
    Predicate = _ => false
});
app.MapHealthChecks("/health/ready", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready")
});
app.MapHub<LeaderboardHub>("/hubs/leaderboard");
app.MapHub<MatchHub>("/hubs/match");
app.MapHub<SocialHub>("/hubs/social");

app.Run();
