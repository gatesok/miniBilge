#pragma warning disable EF1001 // Internal EF Core API – required for MigrationsAssembly override

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Migrations.Internal;
using MiniBilge.Infrastructure.Data;
using System.Reflection;

namespace MiniBilge.Infrastructure.Migrations;

/// <summary>
/// Filters EF Core migration discovery to only the migrations and ModelSnapshot
/// that belong to the active database provider's namespace.
///
/// This allows SQLite and PostgreSQL migrations to coexist in the same assembly
/// under separate subfolders (Migrations/Sqlite/ and Migrations/PostgreSql/)
/// without interfering with each other at runtime.
/// </summary>
public abstract class ProviderAwareMigrationsAssembly : MigrationsAssembly
{
    private readonly string _namespaceFilter;
    private readonly Assembly _infraAssembly;

    private IReadOnlyDictionary<string, TypeInfo>? _filteredMigrations;
    private ModelSnapshot? _filteredSnapshot;
    private bool _snapshotInitialized;

    protected ProviderAwareMigrationsAssembly(
        ICurrentDbContext currentContext,
        IDbContextOptions options,
        IMigrationsIdGenerator idGenerator,
        IDiagnosticsLogger<DbLoggerCategory.Migrations> logger,
        string namespaceFilter)
        : base(currentContext, options, idGenerator, logger)
    {
        _namespaceFilter = namespaceFilter;
        _infraAssembly = typeof(ApplicationDbContext).Assembly;
    }

    /// <summary>
    /// Returns only the migrations whose namespace contains the provider's filter token
    /// (e.g. "Sqlite" or "PostgreSql").
    /// </summary>
    public override IReadOnlyDictionary<string, TypeInfo> Migrations
        => _filteredMigrations ??= base.Migrations
            .Where(m => m.Value.Namespace?.Contains(_namespaceFilter, StringComparison.OrdinalIgnoreCase) == true)
            .ToDictionary(m => m.Key, m => m.Value);

    /// <summary>
    /// Returns the ModelSnapshot that belongs to the active provider's namespace.
    /// Needed because both providers' snapshots compile into the same assembly.
    /// </summary>
    public override ModelSnapshot? ModelSnapshot
    {
        get
        {
            if (!_snapshotInitialized)
            {
                _filteredSnapshot = _infraAssembly.GetTypes()
                    .Where(t => t.IsClass && !t.IsAbstract && !t.IsGenericTypeDefinition
                                && t.IsSubclassOf(typeof(ModelSnapshot))
                                && t.Namespace?.Contains(_namespaceFilter, StringComparison.OrdinalIgnoreCase) == true)
                    .Select(t => (ModelSnapshot)Activator.CreateInstance(t)!)
                    .FirstOrDefault();

                _snapshotInitialized = true;
            }

            return _filteredSnapshot;
        }
    }
}

/// <summary>Filters migrations to those under Migrations/Sqlite/.</summary>
public sealed class SqliteMigrationsAssembly : ProviderAwareMigrationsAssembly
{
    public SqliteMigrationsAssembly(
        ICurrentDbContext currentContext,
        IDbContextOptions options,
        IMigrationsIdGenerator idGenerator,
        IDiagnosticsLogger<DbLoggerCategory.Migrations> logger)
        : base(currentContext, options, idGenerator, logger, namespaceFilter: "Sqlite") { }
}

/// <summary>Filters migrations to those under Migrations/PostgreSql/.</summary>
public sealed class PostgreSqlMigrationsAssembly : ProviderAwareMigrationsAssembly
{
    public PostgreSqlMigrationsAssembly(
        ICurrentDbContext currentContext,
        IDbContextOptions options,
        IMigrationsIdGenerator idGenerator,
        IDiagnosticsLogger<DbLoggerCategory.Migrations> logger)
        : base(currentContext, options, idGenerator, logger, namespaceFilter: "PostgreSql") { }
}

#pragma warning restore EF1001
