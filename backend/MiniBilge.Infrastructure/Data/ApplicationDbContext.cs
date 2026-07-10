using Microsoft.EntityFrameworkCore;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Infrastructure.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<ParentProfile> ParentProfiles => Set<ParentProfile>();
    public DbSet<ChildProfile> ChildProfiles => Set<ChildProfile>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<PasswordResetToken> PasswordResetTokens => Set<PasswordResetToken>();
    
    // Education entities
    public DbSet<Subject> Subjects => Set<Subject>();
    public DbSet<Topic> Topics => Set<Topic>();
    public DbSet<Level> Levels => Set<Level>();
    public DbSet<Question> Questions => Set<Question>();
    public DbSet<QuestionOption> QuestionOptions => Set<QuestionOption>();
    
    // Progress entities
    public DbSet<ChildProgress> ChildProgresses => Set<ChildProgress>();
    public DbSet<AnswerAttempt> AnswerAttempts => Set<AnswerAttempt>();
    public DbSet<LevelResult> LevelResults => Set<LevelResult>();
    
    // Avatar entities
    public DbSet<Avatar> Avatars => Set<Avatar>();
    public DbSet<AvatarItem> AvatarItems => Set<AvatarItem>();
    public DbSet<ChildOwnedItem> ChildOwnedItems => Set<ChildOwnedItem>();
    public DbSet<ChildEquippedItem> ChildEquippedItems => Set<ChildEquippedItem>();
    
    // Match entities
    public DbSet<MatchRequest> MatchRequests => Set<MatchRequest>();
    public DbSet<MatchSession> MatchSessions => Set<MatchSession>();
    public DbSet<MatchParticipant> MatchParticipants => Set<MatchParticipant>();
    public DbSet<MatchQuestion> MatchQuestions => Set<MatchQuestion>();
    public DbSet<MatchAnswer> MatchAnswers => Set<MatchAnswer>();

    // Notification entities
    public DbSet<DeviceToken> DeviceTokens => Set<DeviceToken>();

    // Badge entities
    public DbSet<Badge> Badges => Set<Badge>();
    public DbSet<ChildBadge> ChildBadges => Set<ChildBadge>();

    // Card collection entities
    public DbSet<CollectibleCard> CollectibleCards => Set<CollectibleCard>();
    public DbSet<ChildCard> ChildCards => Set<ChildCard>();
    public DbSet<CardDropLog> CardDropLogs => Set<CardDropLog>();

    // Podcast entities
    public DbSet<PodcastEpisode> PodcastEpisodes => Set<PodcastEpisode>();
    public DbSet<PodcastLine> PodcastLines => Set<PodcastLine>();
    public DbSet<PodcastQuestion> PodcastQuestions => Set<PodcastQuestion>();
    public DbSet<PodcastQuestionOption> PodcastQuestionOptions => Set<PodcastQuestionOption>();
    public DbSet<PodcastQuizResult> PodcastQuizResults => Set<PodcastQuizResult>();

    // Flashcard entities
    public DbSet<FlashcardDeck> FlashcardDecks => Set<FlashcardDeck>();
    public DbSet<Flashcard> Flashcards => Set<Flashcard>();
    public DbSet<FlashcardProgress> FlashcardProgresses => Set<FlashcardProgress>();

    // RolePlay entities
    public DbSet<RolePlaySession> RolePlaySessions => Set<RolePlaySession>();
    public DbSet<RolePlayTurn> RolePlayTurns => Set<RolePlayTurn>();
    public DbSet<RolePlayScenario> RolePlayScenarios => Set<RolePlayScenario>();

    // Social entities
    public DbSet<Friendship>      Friendships      => Set<Friendship>();
    public DbSet<MatchInvitation> MatchInvitations => Set<MatchInvitation>();

    // Challenge entities
    public DbSet<Challenge> Challenges => Set<Challenge>();

    // In-App Notification inbox
    public DbSet<AppNotification> AppNotifications => Set<AppNotification>();

    // Classroom entities
    public DbSet<Classroom>           Classrooms           => Set<Classroom>();
    public DbSet<ClassroomMember>     ClassroomMembers     => Set<ClassroomMember>();
    public DbSet<ClassroomAssignment> ClassroomAssignments => Set<ClassroomAssignment>();
    public DbSet<AssignmentProgress>  AssignmentProgresses => Set<AssignmentProgress>();

    // Adaptive AI Quiz
    public DbSet<AiGeneratedQuestion> AiGeneratedQuestions => Set<AiGeneratedQuestion>();

    // Wordle (Sprint W1)
    public DbSet<WordPool>              WordPool              => Set<WordPool>();
    public DbSet<DailyWordAssignment>   DailyWordAssignments  => Set<DailyWordAssignment>();
    public DbSet<WordGuessResult>       WordGuessResults      => Set<WordGuessResult>();

    // Wordle Seviyeleri (Sprint W2)
    public DbSet<WordleLevelProgress>  WordleLevelProgresses  => Set<WordleLevelProgress>();
    public DbSet<WordleLevelAttempt>   WordleLevelAttempts    => Set<WordleLevelAttempt>();
    public DbSet<WordleLevelPool>      WordleLevelPool        => Set<WordleLevelPool>();

    // Entertainment DB içerik havuzu
    public DbSet<EntertainmentQuizQuestion> EntertainmentQuizQuestions => Set<EntertainmentQuizQuestion>();
    public DbSet<EntertainmentFactFiction>  EntertainmentFactFictions  => Set<EntertainmentFactFiction>();
    public DbSet<EntertainmentKimBu>        EntertainmentKimBus        => Set<EntertainmentKimBu>();
    public DbSet<EntertainmentNeOrtak>      EntertainmentNeOrtaks      => Set<EntertainmentNeOrtak>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Friendship: her çift yalnızca bir kez (unique index) — Requester→Addressee yönü
        modelBuilder.Entity<Friendship>()
            .HasIndex(f => new { f.RequesterId, f.AddresseeId })
            .IsUnique();

        // Friendship navigations (iki FK, her ikisi de ChildProfile'a)
        modelBuilder.Entity<Friendship>()
            .HasOne(f => f.Requester)
            .WithMany(c => c.FriendshipsAsRequester)
            .HasForeignKey(f => f.RequesterId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Friendship>()
            .HasOne(f => f.Addressee)
            .WithMany(c => c.FriendshipsAsAddressee)
            .HasForeignKey(f => f.AddresseeId)
            .OnDelete(DeleteBehavior.Cascade);

        // MatchInvitation navigations
        modelBuilder.Entity<MatchInvitation>()
            .HasOne(i => i.Inviter)
            .WithMany()
            .HasForeignKey(i => i.InviterId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<MatchInvitation>()
            .HasOne(i => i.Invitee)
            .WithMany()
            .HasForeignKey(i => i.InviteeId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<MatchInvitation>()
            .HasOne(i => i.MatchSession)
            .WithMany()
            .HasForeignKey(i => i.MatchSessionId)
            .OnDelete(DeleteBehavior.SetNull);

        // Challenge navigations
        modelBuilder.Entity<Challenge>()
            .ToTable("challenges")
            .HasOne(c => c.Challenger)
            .WithMany()
            .HasForeignKey(c => c.ChallengerId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Challenge>()
            .HasOne(c => c.Challengee)
            .WithMany()
            .HasForeignKey(c => c.ChallengeeId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Challenge>()
            .HasOne(c => c.Level)
            .WithMany()
            .HasForeignKey(c => c.LevelId)
            .OnDelete(DeleteBehavior.Cascade);

        // Classroom mappings
        modelBuilder.Entity<Classroom>()
            .ToTable("classrooms");

        modelBuilder.Entity<Classroom>()
            .HasOne(c => c.Owner)
            .WithMany()
            .HasForeignKey(c => c.OwnerId)
            .IsRequired()
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<ClassroomMember>()
            .ToTable("classroom_members")
            .HasKey(m => new { m.ClassroomId, m.ChildProfileId });

        modelBuilder.Entity<ClassroomMember>()
            .HasOne(m => m.Classroom)
            .WithMany(c => c.Members)
            .HasForeignKey(m => m.ClassroomId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ClassroomMember>()
            .HasOne(m => m.ChildProfile)
            .WithMany()
            .HasForeignKey(m => m.ChildProfileId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ClassroomAssignment>()
            .ToTable("classroom_assignments");

        modelBuilder.Entity<AssignmentProgress>()
            .ToTable("assignment_progress")
            .HasKey(p => new { p.AssignmentId, p.ChildProfileId });

        modelBuilder.Entity<AssignmentProgress>()
            .HasOne(p => p.Assignment)
            .WithMany(a => a.Progress)
            .HasForeignKey(p => p.AssignmentId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<AssignmentProgress>()
            .HasOne(p => p.ChildProfile)
            .WithMany()
            .HasForeignKey(p => p.ChildProfileId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);

        // Adaptive AI Quiz
        modelBuilder.Entity<AiGeneratedQuestion>()
            .ToTable("ai_generated_questions")
            .HasOne(q => q.Child)
            .WithMany()
            .HasForeignKey(q => q.ChildId)
            .OnDelete(DeleteBehavior.Cascade);
    }
    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        foreach (var entry in ChangeTracker.Entries<BaseEntity>())
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.CreatedAt = DateTime.UtcNow;
                    break;
                case EntityState.Modified:
                    entry.Entity.UpdatedAt = DateTime.UtcNow;
                    break;
            }
        }
        
        return base.SaveChangesAsync(cancellationToken);
    }
}
