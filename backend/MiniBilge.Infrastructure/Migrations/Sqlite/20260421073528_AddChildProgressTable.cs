using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniBilge.Infrastructure.Migrations.Sqlite
{
    /// <inheritdoc />
    public partial class AddChildProgressTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "child_progress",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    ChildId = table.Column<Guid>(type: "TEXT", nullable: false),
                    TotalScore = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    TotalStars = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    CompletedLevelsCount = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_child_progress", x => x.Id);
                    table.ForeignKey(
                        name: "FK_child_progress_child_profiles_ChildId",
                        column: x => x.ChildId,
                        principalTable: "child_profiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_child_progress_ChildId",
                table: "child_progress",
                column: "ChildId",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "child_progress");
        }
    }
}
