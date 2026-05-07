using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using MiniBilge.Infrastructure.Data;
using MiniBilge.Infrastructure.Migrations;

namespace MiniBilge.Infrastructure.Extensions;

public static class DatabaseServiceExtensions
{
    /// <summary>
    /// Registers ApplicationDbContext with the provider specified in configuration.
    /// Set "DatabaseProvider" to "SQLite" or "PostgreSQL" in appsettings.json.
    /// Each provider uses its own Migrations subfolder so they never conflict.
    /// </summary>
    public static IServiceCollection AddDatabaseProvider(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var provider = configuration["DatabaseProvider"]
            ?? throw new InvalidOperationException(
                "\"DatabaseProvider\" key is missing from configuration. " +
                "Set it to \"SQLite\" or \"PostgreSQL\".");

        services.AddDbContext<ApplicationDbContext>(options =>
        {
            switch (provider.Trim().ToUpperInvariant())
            {
                case "SQLITE":
                {
                    var connectionString = configuration.GetConnectionString("SQLite")
                        ?? throw new InvalidOperationException(
                            "ConnectionStrings:SQLite is missing from configuration.");

                    options.UseSqlite(
                        connectionString,
                        sql => sql.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.FullName)
                                  .MigrationsHistoryTable("__EFMigrationsHistory_SQLite"));

                    // Only discover migrations from Migrations/Sqlite/
                    options.ReplaceService<IMigrationsAssembly, SqliteMigrationsAssembly>();
                    break;
                }

                case "POSTGRESQL":
                {
                    var connectionString = configuration.GetConnectionString("PostgreSQL")
                        ?? throw new InvalidOperationException(
                            "ConnectionStrings:PostgreSQL is missing from configuration.");

                    options.UseNpgsql(
                        connectionString,
                        npgsql => npgsql.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.FullName)
                                        .MigrationsHistoryTable("__EFMigrationsHistory_PostgreSQL"));

                    // Only discover migrations from Migrations/PostgreSql/
                    options.ReplaceService<IMigrationsAssembly, PostgreSqlMigrationsAssembly>();
                    break;
                }

                default:
                    throw new InvalidOperationException(
                        $"Unsupported DatabaseProvider: \"{provider}\". " +
                        "Supported values: \"SQLite\", \"PostgreSQL\".");
            }
        });

        return services;
    }
}
