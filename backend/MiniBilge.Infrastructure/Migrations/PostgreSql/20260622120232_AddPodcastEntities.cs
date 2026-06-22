using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniBilge.Infrastructure.Migrations.PostgreSql
{
    /// <inheritdoc />
    public partial class AddPodcastEntities : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "badges",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Key = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "text", nullable: false),
                    Emoji = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    Category = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    Rarity = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false, defaultValue: "bronze"),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_badges", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "collectible_cards",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "text", nullable: false),
                    Series = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Rarity = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false, defaultValue: "common"),
                    ImageAsset = table.Column<string>(type: "text", nullable: false),
                    CardNumber = table.Column<int>(type: "integer", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_collectible_cards", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "podcast_episodes",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "text", nullable: false),
                    EnglishLevel = table.Column<int>(type: "integer", nullable: false),
                    DisplayOrder = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_podcast_episodes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "child_badges",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ChildProfileId = table.Column<Guid>(type: "uuid", nullable: false),
                    BadgeId = table.Column<Guid>(type: "uuid", nullable: false),
                    EarnedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_child_badges", x => x.Id);
                    table.ForeignKey(
                        name: "FK_child_badges_badges_BadgeId",
                        column: x => x.BadgeId,
                        principalTable: "badges",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_child_badges_child_profiles_ChildProfileId",
                        column: x => x.ChildProfileId,
                        principalTable: "child_profiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "card_drop_log",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ChildProfileId = table.Column<Guid>(type: "uuid", nullable: false),
                    CardId = table.Column<Guid>(type: "uuid", nullable: false),
                    Source = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    EarnedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_card_drop_log", x => x.Id);
                    table.ForeignKey(
                        name: "FK_card_drop_log_child_profiles_ChildProfileId",
                        column: x => x.ChildProfileId,
                        principalTable: "child_profiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_card_drop_log_collectible_cards_CardId",
                        column: x => x.CardId,
                        principalTable: "collectible_cards",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "child_cards",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ChildProfileId = table.Column<Guid>(type: "uuid", nullable: false),
                    CardId = table.Column<Guid>(type: "uuid", nullable: false),
                    Count = table.Column<int>(type: "integer", nullable: false, defaultValue: 1),
                    FirstEarnedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    LastEarnedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_child_cards", x => x.Id);
                    table.ForeignKey(
                        name: "FK_child_cards_child_profiles_ChildProfileId",
                        column: x => x.ChildProfileId,
                        principalTable: "child_profiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_child_cards_collectible_cards_CardId",
                        column: x => x.CardId,
                        principalTable: "collectible_cards",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "podcast_lines",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    EpisodeId = table.Column<Guid>(type: "uuid", nullable: false),
                    SpeakerName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    SpeakerGender = table.Column<int>(type: "integer", nullable: false),
                    Text = table.Column<string>(type: "text", nullable: false),
                    TranslationTr = table.Column<string>(type: "text", nullable: true),
                    DisplayOrder = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_podcast_lines", x => x.Id);
                    table.ForeignKey(
                        name: "FK_podcast_lines_podcast_episodes_EpisodeId",
                        column: x => x.EpisodeId,
                        principalTable: "podcast_episodes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_badges_Key",
                table: "badges",
                column: "Key",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_card_drop_log_CardId",
                table: "card_drop_log",
                column: "CardId");

            migrationBuilder.CreateIndex(
                name: "IX_card_drop_log_ChildProfileId",
                table: "card_drop_log",
                column: "ChildProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_child_badges_BadgeId",
                table: "child_badges",
                column: "BadgeId");

            migrationBuilder.CreateIndex(
                name: "IX_child_badges_ChildProfileId",
                table: "child_badges",
                column: "ChildProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_child_cards_CardId",
                table: "child_cards",
                column: "CardId");

            migrationBuilder.CreateIndex(
                name: "IX_child_cards_ChildProfileId",
                table: "child_cards",
                column: "ChildProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_podcast_episodes_EnglishLevel",
                table: "podcast_episodes",
                column: "EnglishLevel");

            migrationBuilder.CreateIndex(
                name: "IX_podcast_lines_EpisodeId",
                table: "podcast_lines",
                column: "EpisodeId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "card_drop_log");

            migrationBuilder.DropTable(
                name: "child_badges");

            migrationBuilder.DropTable(
                name: "child_cards");

            migrationBuilder.DropTable(
                name: "podcast_lines");

            migrationBuilder.DropTable(
                name: "badges");

            migrationBuilder.DropTable(
                name: "collectible_cards");

            migrationBuilder.DropTable(
                name: "podcast_episodes");
        }
    }
}
