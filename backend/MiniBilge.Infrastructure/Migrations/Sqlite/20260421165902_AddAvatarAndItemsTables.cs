using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniBilge.Infrastructure.Migrations.Sqlite
{
    /// <inheritdoc />
    public partial class AddAvatarAndItemsTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "AvatarId",
                table: "child_profiles",
                type: "TEXT",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "avatar_items",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    Name = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    ItemType = table.Column<int>(type: "INTEGER", nullable: false),
                    PointCost = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    ImageUrl = table.Column<string>(type: "TEXT", maxLength: 500, nullable: false),
                    Category = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_avatar_items", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "avatars",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    Name = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    ImageUrl = table.Column<string>(type: "TEXT", maxLength: 500, nullable: false),
                    IsDefault = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_avatars", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "child_equipped_items",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    ChildProfileId = table.Column<Guid>(type: "TEXT", nullable: false),
                    ItemId = table.Column<Guid>(type: "TEXT", nullable: false),
                    EquippedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_child_equipped_items", x => x.Id);
                    table.ForeignKey(
                        name: "FK_child_equipped_items_avatar_items_ItemId",
                        column: x => x.ItemId,
                        principalTable: "avatar_items",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_child_equipped_items_child_profiles_ChildProfileId",
                        column: x => x.ChildProfileId,
                        principalTable: "child_profiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "child_owned_items",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    ChildProfileId = table.Column<Guid>(type: "TEXT", nullable: false),
                    ItemId = table.Column<Guid>(type: "TEXT", nullable: false),
                    PurchasedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_child_owned_items", x => x.Id);
                    table.ForeignKey(
                        name: "FK_child_owned_items_avatar_items_ItemId",
                        column: x => x.ItemId,
                        principalTable: "avatar_items",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_child_owned_items_child_profiles_ChildProfileId",
                        column: x => x.ChildProfileId,
                        principalTable: "child_profiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_child_profiles_AvatarId",
                table: "child_profiles",
                column: "AvatarId");

            migrationBuilder.CreateIndex(
                name: "IX_avatar_items_IsActive",
                table: "avatar_items",
                column: "IsActive");

            migrationBuilder.CreateIndex(
                name: "IX_avatar_items_ItemType",
                table: "avatar_items",
                column: "ItemType");

            migrationBuilder.CreateIndex(
                name: "IX_avatar_items_PointCost",
                table: "avatar_items",
                column: "PointCost");

            migrationBuilder.CreateIndex(
                name: "IX_avatars_IsActive",
                table: "avatars",
                column: "IsActive");

            migrationBuilder.CreateIndex(
                name: "IX_avatars_IsDefault",
                table: "avatars",
                column: "IsDefault");

            migrationBuilder.CreateIndex(
                name: "IX_child_equipped_items_ChildProfileId_ItemId",
                table: "child_equipped_items",
                columns: new[] { "ChildProfileId", "ItemId" },
                unique: true,
                filter: "\"IsDeleted\" = FALSE");

            migrationBuilder.CreateIndex(
                name: "IX_child_equipped_items_ItemId",
                table: "child_equipped_items",
                column: "ItemId");

            migrationBuilder.CreateIndex(
                name: "IX_child_owned_items_ChildProfileId_ItemId",
                table: "child_owned_items",
                columns: new[] { "ChildProfileId", "ItemId" },
                unique: true,
                filter: "\"IsDeleted\" = FALSE");

            migrationBuilder.CreateIndex(
                name: "IX_child_owned_items_ItemId",
                table: "child_owned_items",
                column: "ItemId");

            migrationBuilder.AddForeignKey(
                name: "FK_child_profiles_avatars_AvatarId",
                table: "child_profiles",
                column: "AvatarId",
                principalTable: "avatars",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_child_profiles_avatars_AvatarId",
                table: "child_profiles");

            migrationBuilder.DropTable(
                name: "avatars");

            migrationBuilder.DropTable(
                name: "child_equipped_items");

            migrationBuilder.DropTable(
                name: "child_owned_items");

            migrationBuilder.DropTable(
                name: "avatar_items");

            migrationBuilder.DropIndex(
                name: "IX_child_profiles_AvatarId",
                table: "child_profiles");

            migrationBuilder.DropColumn(
                name: "AvatarId",
                table: "child_profiles");
        }
    }
}
