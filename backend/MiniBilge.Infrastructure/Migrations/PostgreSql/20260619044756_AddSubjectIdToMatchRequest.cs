using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniBilge.Infrastructure.Migrations.PostgreSql
{
    /// <inheritdoc />
    public partial class AddSubjectIdToMatchRequest : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<int>(
                name: "GradeLevel",
                table: "topics",
                type: "integer",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AddColumn<int>(
                name: "EnglishLevel",
                table: "topics",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "SubjectId",
                table: "match_requests",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "EnglishLevel",
                table: "child_profiles",
                type: "integer",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EnglishLevel",
                table: "topics");

            migrationBuilder.DropColumn(
                name: "SubjectId",
                table: "match_requests");

            migrationBuilder.DropColumn(
                name: "EnglishLevel",
                table: "child_profiles");

            migrationBuilder.AlterColumn<int>(
                name: "GradeLevel",
                table: "topics",
                type: "integer",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);
        }
    }
}
