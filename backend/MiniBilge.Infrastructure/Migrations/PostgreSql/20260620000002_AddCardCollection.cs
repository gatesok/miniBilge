using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniBilge.Infrastructure.Migrations.PostgreSql
{
    /// <inheritdoc />
    public partial class AddCardCollection : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
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

            migrationBuilder.CreateIndex(
                name: "IX_child_cards_ChildProfileId",
                table: "child_cards",
                column: "ChildProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_child_cards_ChildProfileId_CardId",
                table: "child_cards",
                columns: new[] { "ChildProfileId", "CardId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_card_drop_log_ChildProfileId",
                table: "card_drop_log",
                column: "ChildProfileId");

            // -------------------------------------------------------
            // Seed: 40 kart (Kenney.nl CC0 asset'leri kullanılacak)
            // ⚠️ ImageAsset = 'assets/cards/<dosya>.png' — Flutter asset path
            // Kenney Animal Pack Redux, Character Pack, Creature Mixer
            // -------------------------------------------------------
            var now = new DateTime(2026, 6, 20, 0, 0, 0, DateTimeKind.Utc);

            migrationBuilder.InsertData(
                table: "collectible_cards",
                columns: new[] { "Id", "Name", "Description", "Series", "Rarity", "ImageAsset", "CardNumber", "IsActive", "CreatedAt", "IsDeleted" },
                values: new object[,]
                {
                    // === HAYVAN SERİSİ (1-15) — Kenney Animal Pack Redux ===
                    { Guid.Parse("c1000001-0000-0000-0000-000000000001"), "Bilge Baykuş", "Kitap okuyan akıllı baykuş", "animals", "common", "assets/cards/animals/owl.png", 1, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000002"), "Cesur Aslan", "Ormandaki kral", "animals", "rare", "assets/cards/animals/lion.png", 2, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000003"), "Hızlı Kaplan", "Rüzgar gibi koşan", "animals", "rare", "assets/cards/animals/tiger.png", 3, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000004"), "Kurnaz Tilki", "Her şeyi bilen kızıl dost", "animals", "common", "assets/cards/animals/fox.png", 4, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000005"), "Sevimli Penguen", "Soğuktan korkmayan", "animals", "common", "assets/cards/animals/penguin.png", 5, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000006"), "Şakacı Maymun", "Dal daldan atlayan", "animals", "common", "assets/cards/animals/monkey.png", 6, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000007"), "Çalışkan Arı", "Bal yapan küçük dost", "animals", "common", "assets/cards/animals/bee.png", 7, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000008"), "Meraklı Kirpi", "Her şeyi inceleyen", "animals", "common", "assets/cards/animals/hedgehog.png", 8, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000009"), "Güçlü Fil", "Hafızası güçlü dev", "animals", "rare", "assets/cards/animals/elephant.png", 9, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000010"), "Uçan Kartal", "Gökyüzünün efendisi", "animals", "epic", "assets/cards/animals/eagle.png", 10, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000011"), "Renkli Papağan", "Kelime ustası", "animals", "rare", "assets/cards/animals/parrot.png", 11, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000012"), "Gizli Kaplumbağa", "Yavaş ama kararlı", "animals", "common", "assets/cards/animals/turtle.png", 12, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000013"), "Sihirli Unicorn", "Efsanevi at", "animals", "legendary", "assets/cards/animals/unicorn.png", 13, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000014"), "Akıllı Yunus", "Denizin zekası", "animals", "epic", "assets/cards/animals/dolphin.png", 14, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000015"), "Kutup Ayısı", "Buz ülkesinin bekçisi", "animals", "rare", "assets/cards/animals/polar_bear.png", 15, true, now, false },

                    // === KAHRAMAN SERİSİ (16-30) — Kenney Character Pack ===
                    { Guid.Parse("c1000001-0000-0000-0000-000000000016"), "Mini Bilim İnsanı", "Deney yapan küçük dahi", "heroes", "common", "assets/cards/heroes/scientist.png", 16, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000017"), "Küçük Kaşif", "Haritası her zaman yanında", "heroes", "common", "assets/cards/heroes/explorer.png", 17, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000018"), "Genç Doktor", "İyi hissettiren kahraman", "heroes", "rare", "assets/cards/heroes/doctor.png", 18, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000019"), "Mini Astronot", "Yıldızlara yolculuk", "heroes", "epic", "assets/cards/heroes/astronaut.png", 19, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000020"), "Küçük Mühendis", "Her şeyi yapabilen", "heroes", "rare", "assets/cards/heroes/engineer.png", 20, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000021"), "Mini Şef", "Mutfağın yıldızı", "heroes", "common", "assets/cards/heroes/chef.png", 21, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000022"), "Genç Ressam", "Renklerin ustası", "heroes", "common", "assets/cards/heroes/artist.png", 22, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000023"), "Küçük Müzisyen", "Notalar onun dili", "heroes", "rare", "assets/cards/heroes/musician.png", 23, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000024"), "Mini Sporcu", "Ter döken şampiyon", "heroes", "common", "assets/cards/heroes/athlete.png", 24, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000025"), "Genç Öğretmen", "Bilgiyi paylaşan", "heroes", "rare", "assets/cards/heroes/teacher.png", 25, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000026"), "Küçük Pilot", "Gökyüzünde özgür", "heroes", "epic", "assets/cards/heroes/pilot.png", 26, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000027"), "Mini Dalgıç", "Denizin derinliklerinde", "heroes", "rare", "assets/cards/heroes/diver.png", 27, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000028"), "Genç Arkeolog", "Tarihin izinde", "heroes", "epic", "assets/cards/heroes/archaeologist.png", 28, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000029"), "Süper Kahraman", "Maskeli kurtarıcı", "heroes", "legendary", "assets/cards/heroes/superhero.png", 29, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000030"), "Mini Sihirbaz", "Sihirli şapkalı dost", "heroes", "epic", "assets/cards/heroes/magician.png", 30, true, now, false },

                    // === EFSANE SERİSİ (31-40) — Kenney Creature Mixer / özel ===
                    { Guid.Parse("c1000001-0000-0000-0000-000000000031"), "Bilge Newton", "Elmayı düşüren dahi", "legends", "rare", "assets/cards/legends/newton.png", 31, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000032"), "Meraklı Curie", "Radyumu keşfeden kahraman", "legends", "epic", "assets/cards/legends/curie.png", 32, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000033"), "Yaratıcı Einstein", "Göreceli dahi", "legends", "legendary", "assets/cards/legends/einstein.png", 33, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000034"), "Kaşif Kolomb", "Yeni dünyaları bulan", "legends", "rare", "assets/cards/legends/columbus.png", 34, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000035"), "Mucitçi Edison", "Ampulü yakan dahi", "legends", "epic", "assets/cards/legends/edison.png", 35, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000036"), "Uçan Bernoulli", "Uçuşu anlayan bilge", "legends", "rare", "assets/cards/legends/bernoulli.png", 36, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000037"), "Matematikçi Öklid", "Geometrinin babası", "legends", "epic", "assets/cards/legends/euclid.png", 37, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000038"), "Dahi da Vinci", "Her şeyi yapabilen sanatçı", "legends", "legendary", "assets/cards/legends/da_vinci.png", 38, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000039"), "Yıldız Hawking", "Evrenin sırlarını çözen", "legends", "legendary", "assets/cards/legends/hawking.png", 39, true, now, false },
                    { Guid.Parse("c1000001-0000-0000-0000-000000000040"), "Bilge Atatürk", "Cumhuriyetin kurucusu", "legends", "legendary", "assets/cards/legends/ataturk.png", 40, true, now, false },
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(name: "card_drop_log");
            migrationBuilder.DropTable(name: "child_cards");
            migrationBuilder.DropTable(name: "collectible_cards");
        }
    }
}
