using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniBilge.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddLevelResultsTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "level_results",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    ChildId = table.Column<Guid>(type: "TEXT", nullable: false),
                    LevelId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Score = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    Stars = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    CorrectCount = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    TotalQuestions = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    SuccessPercentage = table.Column<decimal>(type: "TEXT", precision: 5, scale: 2, nullable: false, defaultValue: 0m),
                    IsUnlocked = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    CompletedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_level_results", x => x.Id);
                    table.ForeignKey(
                        name: "FK_level_results_child_profiles_ChildId",
                        column: x => x.ChildId,
                        principalTable: "child_profiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_level_results_levels_LevelId",
                        column: x => x.LevelId,
                        principalTable: "levels",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_level_results_ChildId",
                table: "level_results",
                column: "ChildId");

            migrationBuilder.CreateIndex(
                name: "IX_level_results_ChildId_LevelId",
                table: "level_results",
                columns: new[] { "ChildId", "LevelId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_level_results_CompletedAt",
                table: "level_results",
                column: "CompletedAt");

            migrationBuilder.CreateIndex(
                name: "IX_level_results_LevelId",
                table: "level_results",
                column: "LevelId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "level_results");
        }
    }
}
