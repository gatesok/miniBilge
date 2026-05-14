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
using MiniBilge.Infrastructure.Data;
using MiniBilge.Infrastructure.Extensions;
using MiniBilge.Infrastructure.Repositories;
using MiniBilge.Infrastructure.Services;
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
builder.Services.AddScoped<IEducationRepository, EducationRepository>();
builder.Services.AddScoped<IProgressRepository, ProgressRepository>();
builder.Services.AddScoped<IAvatarRepository, AvatarRepository>();
builder.Services.AddScoped<IMatchRepository, MatchRepository>();

// Services
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IChildProfileService, ChildProfileService>();
builder.Services.AddScoped<IEducationService, EducationService>();
builder.Services.AddScoped<IProgressService, ProgressService>();
builder.Services.AddScoped<IAvatarService, AvatarService>();
builder.Services.AddScoped<ILeaderboardService, LeaderboardService>();
builder.Services.AddScoped<ILeaderboardNotifier, LeaderboardHubNotifier>();
builder.Services.AddScoped<IParentReportingService, ParentReportingService>();
builder.Services.AddScoped<IMatchmakingService, MatchmakingService>();
builder.Services.AddScoped<IMatchNotifier, MatchHubNotifier>();
builder.Services.AddScoped<IJwtService, JwtService>();
builder.Services.AddScoped<IPasswordHasher, PasswordHasher>();

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = null; // Use PascalCase
    });

builder.Services.AddEndpointsApiExplorer();

// SignalR with PascalCase JSON serialization
builder.Services.AddSignalR()
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

var app = builder.Build();

// Run migrations and seed database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    try
    {
        await context.Database.MigrateAsync();
    }
    catch (Exception)
    {
        // Tables may already exist from a previous EnsureCreated run; ensure schema is present
        await context.Database.EnsureCreatedAsync();
    }
    await MiniBilge.Infrastructure.Data.Seeders.EducationDataSeeder.SeedAsync(context);
    await MiniBilge.Infrastructure.Data.Seeders.AvatarDataSeeder.SeedAsync(context);
    await MiniBilge.Infrastructure.Data.Seeders.AvatarItemsDataSeeder.SeedAsync(context);
    await MiniBilge.Infrastructure.Data.Seeders.ChildProfileInitialPointsSeeder.SeedAsync(context);
}

// Middleware
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Enable CORS
app.UseCors("AllowWebApp");

if (app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapHub<LeaderboardHub>("/hubs/leaderboard");
app.MapHub<MatchHub>("/hubs/match");

app.Run();
