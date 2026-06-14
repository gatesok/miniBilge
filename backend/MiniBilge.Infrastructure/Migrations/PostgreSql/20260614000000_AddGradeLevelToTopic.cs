using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniBilge.Infrastructure.Migrations.PostgreSql
{
    /// <inheritdoc />
    public partial class AddGradeLevelToTopic : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "GradeLevel",
                table: "topics",
                type: "integer",
                nullable: false,
                defaultValue: 1);

            // Mevcut '4.sınıf Deneme Sorular' topic'ini Grade4 (4) olarak işaretle
            migrationBuilder.Sql(
                "UPDATE topics SET \"GradeLevel\" = 4 WHERE \"Name\" = '4.sınıf Deneme Sorular'");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "GradeLevel",
                table: "topics");
        }
    }
}
