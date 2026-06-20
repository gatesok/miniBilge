using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniBilge.Infrastructure.Migrations.PostgreSql
{
    /// <inheritdoc />
    public partial class AddBadgeSystem : Migration
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
                    IsActive = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_badges", x => x.Id);
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
                        name: "FK_child_badges_child_profiles_ChildProfileId",
                        column: x => x.ChildProfileId,
                        principalTable: "child_profiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_child_badges_badges_BadgeId",
                        column: x => x.BadgeId,
                        principalTable: "badges",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_badges_Key",
                table: "badges",
                column: "Key",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_child_badges_ChildProfileId",
                table: "child_badges",
                column: "ChildProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_child_badges_ChildProfileId_BadgeId",
                table: "child_badges",
                columns: new[] { "ChildProfileId", "BadgeId" },
                unique: true);

            // Seed: tüm rozet tanımları
            var now = new DateTime(2026, 6, 20, 0, 0, 0, DateTimeKind.Utc);

            migrationBuilder.InsertData(
                table: "badges",
                columns: new[] { "Id", "Key", "Name", "Description", "Emoji", "Category", "Rarity", "IsActive", "CreatedAt", "IsDeleted" },
                values: new object[,]
                {
                    // Learning
                    { Guid.Parse("a1000001-0000-0000-0000-000000000001"), "first_quiz", "İlk Adım", "İlk quiz'ini tamamladın!", "📚", "learning", "bronze", true, now, false },
                    { Guid.Parse("a1000001-0000-0000-0000-000000000002"), "topic_master", "Konu Ustası", "Bir konunun tüm seviyelerini tamamladın", "🎓", "learning", "silver", true, now, false },
                    { Guid.Parse("a1000001-0000-0000-0000-000000000003"), "perfectionist", "Mükemmeliyetçi", "Bir seviyeyi %100 başarıyla bitirdin", "💯", "learning", "silver", true, now, false },
                    { Guid.Parse("a1000001-0000-0000-0000-000000000004"), "busy_bee", "Çalışkan Arı", "Tek günde 3 farklı konu çalıştın", "🐝", "learning", "gold", true, now, false },
                    // Speed
                    { Guid.Parse("a1000001-0000-0000-0000-000000000005"), "lightning", "Şimşek", "Bir soruyu 5 saniyede doğru yanıtladın", "⚡", "speed", "silver", true, now, false },
                    { Guid.Parse("a1000001-0000-0000-0000-000000000006"), "speed_train", "Hız Treni", "Bir quiz'i 2 dakika altında bitirdin", "🚄", "speed", "gold", true, now, false },
                    // Streak
                    { Guid.Parse("a1000001-0000-0000-0000-000000000007"), "streak_3", "Isınıyorum", "3 günlük seri yaptın", "🔥", "streak", "bronze", true, now, false },
                    { Guid.Parse("a1000001-0000-0000-0000-000000000008"), "streak_7", "Ateş Topu", "7 günlük seri yaptın", "🔥", "streak", "silver", true, now, false },
                    { Guid.Parse("a1000001-0000-0000-0000-000000000009"), "streak_30", "Yanmıyor", "30 günlük seri yaptın", "🌋", "streak", "legendary", true, now, false },
                    // Match
                    { Guid.Parse("a1000001-0000-0000-0000-000000000010"), "first_win", "İlk Zafer", "İlk canlı yarış galibiyetini kazandın", "⚔️", "match", "bronze", true, now, false },
                    { Guid.Parse("a1000001-0000-0000-0000-000000000011"), "win_streak_5", "Seri Katil", "Arka arkaya 5 yarış kazandın", "🏹", "match", "gold", true, now, false },
                    { Guid.Parse("a1000001-0000-0000-0000-000000000012"), "champion_50", "Turnuva Şampiyonu", "50 yarış kazandın", "🏆", "match", "legendary", true, now, false },
                    // Subject
                    { Guid.Parse("a1000001-0000-0000-0000-000000000013"), "math_master", "Sayıların Efendisi", "Matematik'te 10 konu tamamladın", "🧮", "learning", "gold", true, now, false },
                    { Guid.Parse("a1000001-0000-0000-0000-000000000014"), "english_a1", "Kelime Avcısı", "İngilizce A1 tüm seviyelerini bitirdin", "🌍", "learning", "silver", true, now, false },
                    { Guid.Parse("a1000001-0000-0000-0000-000000000015"), "english_b1", "CEFR Yolcusu", "İngilizce B1 seviyesine ulaştın", "🌍", "learning", "gold", true, now, false },
                    // Special
                    { Guid.Parse("a1000001-0000-0000-0000-000000000016"), "early_bird", "Erken Kuş", "İlk 100 kullanıcıdan birisin", "🌟", "special", "legendary", true, now, false },
                    { Guid.Parse("a1000001-0000-0000-0000-000000000017"), "beta_hero", "Beta Kahramanı", "v1.0 döneminde aktif kullanıcısın", "🦸", "special", "gold", true, now, false },
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(name: "child_badges");
            migrationBuilder.DropTable(name: "badges");
        }
    }
}
