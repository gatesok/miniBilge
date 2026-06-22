using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniBilge.Infrastructure.Migrations.PostgreSql
{
    /// <inheritdoc />
    public partial class AddCanUseOnlineSpeech : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
                ALTER TABLE users ADD COLUMN IF NOT EXISTS ""CanUseOnlineSpeech"" BOOLEAN NOT NULL DEFAULT false;
                ALTER TABLE podcast_lines ADD COLUMN IF NOT EXISTS audio_url TEXT;
                ALTER TABLE podcast_lines ADD COLUMN IF NOT EXISTS voice_key VARCHAR(20);
                ALTER TABLE child_profiles ADD COLUMN IF NOT EXISTS ""PodcastListeningMode"" INTEGER NOT NULL DEFAULT 0;
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CanUseOnlineSpeech",
                table: "users");

            migrationBuilder.DropColumn(
                name: "audio_url",
                table: "podcast_lines");

            migrationBuilder.DropColumn(
                name: "voice_key",
                table: "podcast_lines");

            migrationBuilder.DropColumn(
                name: "PodcastListeningMode",
                table: "child_profiles");
        }
    }
}
