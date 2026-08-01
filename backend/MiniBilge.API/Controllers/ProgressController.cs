using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Common;
using MiniBilge.Application.DTOs.Progress;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;
namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Parent")]
public class ProgressController : ControllerBase
{
    private readonly IProgressService _progressService;
    private readonly IBadgeService _badgeService;
    private readonly ICardDropService _cardDropService;
    private readonly ApplicationDbContext _db;

    public ProgressController(
        IProgressService progressService,
        IBadgeService badgeService,
        ICardDropService cardDropService,
        ApplicationDbContext db)
    {
        _progressService = progressService;
        _badgeService = badgeService;
        _cardDropService = cardDropService;
        _db = db;
    }

    /// <summary>
    /// Çocuğun bölüm sonuç ilerlemesini kaydeder
    /// </summary>
    /// <param name="request">Bölüm sonuç bilgileri</param>
    [HttpPost]
    public async Task<ActionResult> SaveProgress([FromBody] SaveProgressRequest request)
    {
        try
        {
            // Puan ve yıldız hesapla
            var calculatedScore = _progressService.CalculateScore(
                request.CorrectCount, 
                request.TotalQuestions
            );
            
            var calculatedStars = _progressService.CalculateStars(request.SuccessPercentage);

            request.Score = calculatedScore;
            request.Stars = calculatedStars;

            await _progressService.SaveProgressAsync(request);

            // ── Rozet context hazırlığı ──────────────────────────────────────
            // Geçme eşiği: mevcut sistemle tutarlı olması için ≥7 doğru.
            const int passThreshold = 7;

            // Level → Topic → Subject bilgisini çek (grade, İngilizce seviyesi, ders adı)
            var levelInfo = await _db.Set<Level>()
                .Where(l => l.Id == request.LevelId)
                .Select(l => new
                {
                    l.TopicId,
                    GradeLevel = l.Topic.GradeLevel,
                    EnglishLevel = l.Topic.EnglishLevel,
                    SubjectId = l.Topic.SubjectId,
                    SubjectName = l.Topic.Subject.Name,
                })
                .FirstOrDefaultAsync();

            // Child'ın sınıf seviyesi
            var childGrade = await _db.Set<ChildProfile>()
                .Where(c => c.Id == request.ChildId)
                .Select(c => c.GradeLevel)
                .FirstOrDefaultAsync();

            // Backend'de normalize edilmiş ders ve İngilizce seviyesi (client'a güvenilmez)
            string? subjectName = levelInfo?.SubjectName ?? request.SubjectName;
            string? normalizedEnglishLevel = levelInfo?.EnglishLevel?.ToString(); // "A1".."C2"
            bool isEnglishQuiz = normalizedEnglishLevel != null
                || !string.IsNullOrEmpty(request.EnglishLevel);

            // Bu level daha önce ≥7 doğru ile geçilmiş mi? (şu anki kayıt hariç)
            var previousPass = await _db.Set<LevelResult>()
                .Where(lr => lr.ChildId == request.ChildId
                          && lr.LevelId == request.LevelId
                          && lr.CorrectCount >= passThreshold
                          && lr.CreatedAt < DateTime.UtcNow.AddSeconds(-5)) // az önce kaydettiğimizi hariç tut
                .AnyAsync();

            // Kural: ≥7 doğru VE (İngilizce quiz VEYA level grade'i child grade'inden küçük değil) VE daha önce geçilmemiş
            int levelGradeInt = levelInfo?.GradeLevel.HasValue == true
                ? (int)levelInfo.GradeLevel!.Value : 0;
            int childGradeInt = (int)childGrade;

            bool isEligibleForFirstQuiz = request.CorrectCount >= passThreshold
                && (isEnglishQuiz || levelGradeInt >= childGradeInt)
                && !previousPass;

            // İlk Adım rozeti: çocuğun tamamladığı ilk quiz (başarı şartı yok, herhangi seviye).
            // Rozet açıklamasıyla ("İlk quiz'ini tamamladın!") uyumludur.
            bool isFirstEverQuiz = !await _db.Set<LevelResult>()
                .Where(lr => lr.ChildId == request.ChildId
                          && lr.CreatedAt < DateTime.UtcNow.AddSeconds(-5)) // az önce kaydettiğimizi hariç tut
                .AnyAsync();

            // ── Backend-hesaplı konu metrikleri (rozet koşulları) ─────────────
            bool topicJustCompleted = false;
            int? mathTopicsCompleted = null;
            bool englishA1Completed = false;
            bool englishReachedB1 = false;
            int topicsCompletedToday = 0;

            if (levelInfo != null)
            {
                // Konu Ustası: bu konunun tüm aktif seviyeleri geçildi mi?
                var currentTopicLevelIds = await _db.Set<Level>()
                    .Where(l => l.TopicId == levelInfo.TopicId && l.IsActive)
                    .Select(l => l.Id)
                    .ToListAsync();
                if (currentTopicLevelIds.Count > 0)
                {
                    var passedInTopic = await _db.Set<LevelResult>()
                        .Where(lr => lr.ChildId == request.ChildId
                                  && lr.CorrectCount >= passThreshold
                                  && currentTopicLevelIds.Contains(lr.LevelId))
                        .Select(lr => lr.LevelId)
                        .Distinct()
                        .CountAsync();
                    topicJustCompleted = passedInTopic == currentTopicLevelIds.Count;
                }

                // Sayıların Efendisi: yalnızca tamamen bitirilmiş MATEMATİK konuları
                if (subjectName == "Matematik")
                {
                    var mathLevels = await _db.Set<Level>()
                        .Where(l => l.IsActive && l.Topic.IsActive
                                 && l.Topic.Subject.Name == "Matematik")
                        .Select(l => new { l.Id, l.TopicId })
                        .ToListAsync();
                    var mathLevelIds = mathLevels.Select(x => x.Id).ToList();
                    var passedMath = (await _db.Set<LevelResult>()
                        .Where(lr => lr.ChildId == request.ChildId
                                  && lr.CorrectCount >= passThreshold
                                  && mathLevelIds.Contains(lr.LevelId))
                        .Select(lr => lr.LevelId)
                        .Distinct()
                        .ToListAsync()).ToHashSet();
                    mathTopicsCompleted = mathLevels
                        .GroupBy(x => x.TopicId)
                        .Count(g => g.All(l => passedMath.Contains(l.Id)));
                }

                // Kelime Avcısı: tüm A1 İngilizce içeriği tamamlandı mı?
                // CEFR Yolcusu: B1 seviyesinde en az bir seviye geçildi mi?
                if (isEnglishQuiz)
                {
                    var a1LevelIds = await _db.Set<Level>()
                        .Where(l => l.IsActive && l.Topic.IsActive
                                 && l.Topic.EnglishLevel == EnglishLevel.A1)
                        .Select(l => l.Id)
                        .ToListAsync();
                    if (a1LevelIds.Count > 0)
                    {
                        var passedA1 = await _db.Set<LevelResult>()
                            .Where(lr => lr.ChildId == request.ChildId
                                      && lr.CorrectCount >= passThreshold
                                      && a1LevelIds.Contains(lr.LevelId))
                            .Select(lr => lr.LevelId)
                            .Distinct()
                            .CountAsync();
                        englishA1Completed = passedA1 == a1LevelIds.Count;
                    }

                    englishReachedB1 = await _db.Set<LevelResult>()
                        .AnyAsync(lr => lr.ChildId == request.ChildId
                                     && lr.CorrectCount >= passThreshold
                                     && lr.Level.IsActive
                                     && lr.Level.Topic.IsActive
                                     && lr.Level.Topic.EnglishLevel == EnglishLevel.B1);
                }

                // Çalışkan Arı: bugün tamamen bitirilen farklı konu sayısı
                var todayUtc = DateTime.UtcNow.Date;
                var topicsTouchedToday = await _db.Set<LevelResult>()
                    .Where(lr => lr.ChildId == request.ChildId
                              && lr.CorrectCount >= passThreshold
                              && lr.CreatedAt >= todayUtc)
                    .Select(lr => lr.Level.TopicId)
                    .Distinct()
                    .ToListAsync();
                if (topicsTouchedToday.Count > 0)
                {
                    var todayLevels = await _db.Set<Level>()
                        .Where(l => l.IsActive && topicsTouchedToday.Contains(l.TopicId))
                        .Select(l => new { l.Id, l.TopicId })
                        .ToListAsync();
                    var todayLevelIds = todayLevels.Select(x => x.Id).ToList();
                    var passedToday = (await _db.Set<LevelResult>()
                        .Where(lr => lr.ChildId == request.ChildId
                                  && lr.CorrectCount >= passThreshold
                                  && todayLevelIds.Contains(lr.LevelId))
                        .Select(lr => lr.LevelId)
                        .Distinct()
                        .ToListAsync()).ToHashSet();
                    topicsCompletedToday = todayLevels
                        .GroupBy(x => x.TopicId)
                        .Count(g => g.All(l => passedToday.Contains(l.Id)));
                }
            }

            var badgeCtx = new BadgeTriggerContext
            {
                SuccessPercentage = (double)request.SuccessPercentage,
                SubjectName = subjectName,
                EnglishLevel = normalizedEnglishLevel ?? request.EnglishLevel,
                QuizDurationSeconds = request.QuizDurationSeconds,
                QuestionAnswerSeconds = request.FastestCorrectAnswerSeconds,
                IsEligibleNewQuiz = isFirstEverQuiz,
                TopicJustCompleted = topicJustCompleted,
                MathTopicsCompleted = mathTopicsCompleted,
                EnglishA1Completed = englishA1Completed,
                EnglishReachedB1 = englishReachedB1,
                TopicsCompletedToday = topicsCompletedToday,
            };

            var earnedBadges = await _badgeService.CheckAndAwardAsync(
                request.ChildId,
                BadgeTrigger.QuizCompleted,
                badgeCtx);

            // ── Günlük seri (streak) güncelle ve seri rozetlerini değerlendir ──
            var streakBadges = await UpdateStreakAndAwardAsync(request.ChildId);
            var allEarnedBadges = earnedBadges.Concat(streakBadges).ToList();

            // ── Kart drop ───────────────────────────────────────────────────
            // Sadece grade uygun quizlerde kart düşer; common kolay, nadirler zor
            var cardDrop = await _cardDropService.TryDropAsync(
                request.ChildId,
                "quiz_complete",
                isGradeEligible: isEligibleForFirstQuiz,
                successPercent: (int)request.SuccessPercentage,
                difficulty: request.EnglishLevel,
                idempotencyKey: $"level-result:{await _db.LevelResults
                    .Where(x => x.ChildId == request.ChildId && x.LevelId == request.LevelId)
                    .OrderByDescending(x => x.CreatedAt)
                    .Select(x => x.Id)
                    .FirstAsync()}");

            return Ok(new 
            { 
                message = "Progress kaydedildi",
                score = calculatedScore,
                stars = calculatedStars,
                earnedBadges = allEarnedBadges,
                cardDrop,
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Aktivite gerçekleştiğinde profilin günlük serisini backend'de günceller
    /// ve seri rozetlerini (streak_3/7/30) değerlendirir.
    /// </summary>
    private async Task<IReadOnlyList<string>> UpdateStreakAndAwardAsync(Guid childId)
    {
        var profile = await _db.Set<ChildProfile>().FirstOrDefaultAsync(c => c.Id == childId);
        if (profile == null) return Array.Empty<string>();

        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        if (profile.LastActivityDate != today)
        {
            var newStreak = StreakCalculator.Next(profile.CurrentStreak, profile.LastActivityDate, today);
            profile.CurrentStreak = newStreak;
            if (newStreak > profile.LongestStreak) profile.LongestStreak = newStreak;
            profile.LastActivityDate = today;
            await _db.SaveChangesAsync();
        }

        return await _badgeService.CheckAndAwardAsync(
            childId,
            BadgeTrigger.StreakUpdated,
            new BadgeTriggerContext { CurrentStreak = profile.CurrentStreak });
    }

    /// <summary>
    /// Çocuğun genel ilerlemesini getirir
    /// </summary>
    /// <param name="childId">Çocuk ID</param>
    [HttpGet("{childId}")]
    public async Task<ActionResult<ChildProgressDto>> GetProgress(Guid childId)
    {
        try
        {
            var progress = await _progressService.GetProgressAsync(childId);
            return Ok(progress);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Çocuğun tüm bölüm sonuçlarını getirir
    /// </summary>
    /// <param name="childId">Çocuk ID</param>
    [HttpGet("{childId}/level-results")]
    public async Task<ActionResult<List<LevelResultDto>>> GetLevelResults(Guid childId)
    {
        try
        {
            var results = await _progressService.GetLevelResultsAsync(childId);
            return Ok(results);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Soru çözüm denemesini kaydeder
    /// </summary>
    /// <param name="request">Cevap denemesi bilgileri</param>
    [HttpPost("attempt")]
    public async Task<ActionResult> SaveAnswerAttempt([FromBody] SaveAnswerAttemptRequest request)
    {
        try
        {
            await _progressService.SaveAnswerAttemptAsync(request);
            return Ok(new { message = "Answer attempt kaydedildi" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Level'ın unlock olup olmadığını kontrol eder
    /// </summary>
    /// <param name="childId">Çocuk ID</param>
    /// <param name="levelId">Level ID</param>
    [HttpGet("{childId}/check-unlock/{levelId}")]
    public async Task<ActionResult<bool>> CheckLevelUnlock(Guid childId, Guid levelId)
    {
        try
        {
            var isUnlocked = await _progressService.CheckLevelUnlockAsync(childId, levelId);
            return Ok(new { isUnlocked });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
