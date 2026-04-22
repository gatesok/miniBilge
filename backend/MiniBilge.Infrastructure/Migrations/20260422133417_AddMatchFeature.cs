using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniBilge.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddMatchFeature : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "match_sessions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    StartedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    EndedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    Status = table.Column<int>(type: "INTEGER", nullable: false),
                    WinnerId = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_match_sessions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "match_participants",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    MatchSessionId = table.Column<Guid>(type: "TEXT", nullable: false),
                    ChildProfileId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Score = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    JoinedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsReady = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_match_participants", x => x.Id);
                    table.ForeignKey(
                        name: "FK_match_participants_child_profiles_ChildProfileId",
                        column: x => x.ChildProfileId,
                        principalTable: "child_profiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_match_participants_match_sessions_MatchSessionId",
                        column: x => x.MatchSessionId,
                        principalTable: "match_sessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "match_questions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    MatchSessionId = table.Column<Guid>(type: "TEXT", nullable: false),
                    QuestionId = table.Column<Guid>(type: "TEXT", nullable: false),
                    QuestionOrder = table.Column<int>(type: "INTEGER", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_match_questions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_match_questions_match_sessions_MatchSessionId",
                        column: x => x.MatchSessionId,
                        principalTable: "match_sessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_match_questions_questions_QuestionId",
                        column: x => x.QuestionId,
                        principalTable: "questions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "match_requests",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    ChildProfileId = table.Column<Guid>(type: "TEXT", nullable: false),
                    RequestedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    Status = table.Column<int>(type: "INTEGER", nullable: false),
                    MatchedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    MatchSessionId = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_match_requests", x => x.Id);
                    table.ForeignKey(
                        name: "FK_match_requests_child_profiles_ChildProfileId",
                        column: x => x.ChildProfileId,
                        principalTable: "child_profiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_match_requests_match_sessions_MatchSessionId",
                        column: x => x.MatchSessionId,
                        principalTable: "match_sessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "match_answers",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    MatchSessionId = table.Column<Guid>(type: "TEXT", nullable: false),
                    ParticipantId = table.Column<Guid>(type: "TEXT", nullable: false),
                    QuestionId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Answer = table.Column<string>(type: "TEXT", maxLength: 500, nullable: false),
                    IsCorrect = table.Column<bool>(type: "INTEGER", nullable: false),
                    AnsweredAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    PointsEarned = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_match_answers", x => x.Id);
                    table.ForeignKey(
                        name: "FK_match_answers_match_participants_ParticipantId",
                        column: x => x.ParticipantId,
                        principalTable: "match_participants",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_match_answers_match_sessions_MatchSessionId",
                        column: x => x.MatchSessionId,
                        principalTable: "match_sessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_match_answers_questions_QuestionId",
                        column: x => x.QuestionId,
                        principalTable: "questions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_match_answers_MatchSessionId",
                table: "match_answers",
                column: "MatchSessionId");

            migrationBuilder.CreateIndex(
                name: "IX_match_answers_ParticipantId",
                table: "match_answers",
                column: "ParticipantId");

            migrationBuilder.CreateIndex(
                name: "IX_match_answers_ParticipantId_QuestionId",
                table: "match_answers",
                columns: new[] { "ParticipantId", "QuestionId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_match_answers_QuestionId",
                table: "match_answers",
                column: "QuestionId");

            migrationBuilder.CreateIndex(
                name: "IX_match_participants_ChildProfileId",
                table: "match_participants",
                column: "ChildProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_match_participants_MatchSessionId",
                table: "match_participants",
                column: "MatchSessionId");

            migrationBuilder.CreateIndex(
                name: "IX_match_questions_MatchSessionId",
                table: "match_questions",
                column: "MatchSessionId");

            migrationBuilder.CreateIndex(
                name: "IX_match_questions_MatchSessionId_QuestionOrder",
                table: "match_questions",
                columns: new[] { "MatchSessionId", "QuestionOrder" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_match_questions_QuestionId",
                table: "match_questions",
                column: "QuestionId");

            migrationBuilder.CreateIndex(
                name: "IX_match_requests_ChildProfileId",
                table: "match_requests",
                column: "ChildProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_match_requests_MatchSessionId",
                table: "match_requests",
                column: "MatchSessionId");

            migrationBuilder.CreateIndex(
                name: "IX_match_requests_RequestedAt",
                table: "match_requests",
                column: "RequestedAt");

            migrationBuilder.CreateIndex(
                name: "IX_match_requests_Status",
                table: "match_requests",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_match_sessions_CreatedAt",
                table: "match_sessions",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_match_sessions_Status",
                table: "match_sessions",
                column: "Status");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "match_answers");

            migrationBuilder.DropTable(
                name: "match_questions");

            migrationBuilder.DropTable(
                name: "match_requests");

            migrationBuilder.DropTable(
                name: "match_participants");

            migrationBuilder.DropTable(
                name: "match_sessions");
        }
    }
}
