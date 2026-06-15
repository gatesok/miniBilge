using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.EntityFrameworkCore.Migrations;
using MiniBilge.Infrastructure.Migrations;

namespace MiniBilge.Infrastructure.Data;

/// <summary>
/// Design-time factory used by EF Core CLI tools (dotnet ef migrations add / update).
///
/// The active provider is read from the MINIBILGE_DB_PROVIDER environment variable.
/// Falls back to "PostgreSQL" if not set.
///
/// Usage examples:
///
///   # Generate PostgreSQL migration:
///   MINIBILGE_DB_PROVIDER=PostgreSQL \
///   dotnet ef migrations add InitialCreate \
///     --project MiniBilge.Infrastructure \
///     --startup-project MiniBilge.API \
///     --output-dir Migrations/PostgreSql \
///     --namespace MiniBilge.Infrastructure.Migrations.PostgreSql
///
///   # Generate SQLite migration:
///   MINIBILGE_DB_PROVIDER=SQLite \
///   dotnet ef migrations add SomeMigration \
///     --project MiniBilge.Infrastructure \
///     --startup-project MiniBilge.API \
///     --output-dir Migrations/Sqlite \
///     --namespace MiniBilge.Infrastructure.Migrations.Sqlite
/// </summary>
public class ApplicationDbContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
{
    public ApplicationDbContext CreateDbContext(string[] args)
    {
        // Read provider from env var — set this before running dotnet ef CLI commands.
        // Falls back to "PostgreSQL" as the default for this project.
        var provider = (Environment.GetEnvironmentVariable("MINIBILGE_DB_PROVIDER") ?? "PostgreSQL")
            .Trim().ToUpperInvariant();

        var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();

        switch (provider)
        {
            case "SQLITE":
                optionsBuilder.UseSqlite(
                    "Data Source=minibilge.db",
                    sql => sql.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.FullName)
                              .MigrationsHistoryTable("__EFMigrationsHistory_SQLite"));
                optionsBuilder.ReplaceService<IMigrationsAssembly, SqliteMigrationsAssembly>();
                break;

            case "POSTGRESQL":
                optionsBuilder.UseNpgsql(
                    Environment.GetEnvironmentVariable("ConnectionStrings__PostgreSQL")
                        ?? "Host=localhost;Port=5432;Database=minibilge_db;Username=minibilge_user;Password=dev_local",
                    npgsql => npgsql.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.FullName)
                                    .MigrationsHistoryTable("__EFMigrationsHistory_PostgreSQL"));
                optionsBuilder.ReplaceService<IMigrationsAssembly, PostgreSqlMigrationsAssembly>();
                break;

            default:
                throw new InvalidOperationException(
                    $"Unknown DatabaseProvider: '{provider}'. Supported: 'SQLite', 'PostgreSQL'.");
        }

        return new ApplicationDbContext(optionsBuilder.Options);
    }
}
