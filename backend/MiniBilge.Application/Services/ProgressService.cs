using MiniBilge.Application.DTOs.Progress;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Services;

public class ProgressService : IProgressService
{
    private readonly IProgressRepository _progressRepository;
    private const int PointsPerCorrectAnswer = 10;
    private const int SpeedBonusPoints = 5;
    private const int SpeedBonusThresholdSeconds = 10; // 10 saniyeden hızlı cevap verirse bonus

    public ProgressService(IProgressRepository progressRepository)
    {
        _progressRepository = progressRepository;
    }

    // Task 4: Puan Hesaplama
    public int CalculateScore(int correctCount, int totalQuestions, int? timeTakenSeconds = null)
    {
        if (correctCount < 0 || totalQuestions <= 0)
            return 0;

        // Her doğru cevap için temel puan
        int baseScore = correctCount * PointsPerCorrectAnswer;

        // Hız bonusu (opsiyonel)
        int bonusScore = 0;
        if (timeTakenSeconds.HasValue && timeTakenSeconds.Value > 0)
        {
            // Her doğru cevap için ortalama süre
            int averageTimePerQuestion = timeTakenSeconds.Value / correctCount;
            
            // Eğer ortalama cevap süresi threshold'dan hızlıysa bonus ver
            if (averageTimePerQuestion <= SpeedBonusThresholdSeconds)
            {
                bonusScore = correctCount * SpeedBonusPoints;
            }
        }

        return baseScore + bonusScore;
    }

    // Task 5: Yıldız Hesaplama
    public int CalculateStars(decimal successPercentage)
    {
        if (successPercentage < 0 || successPercentage > 100)
            return 0;

        // ⭐ 1 yıldız: %30-49
        if (successPercentage >= 30 && successPercentage < 50)
            return 1;

        // ⭐⭐ 2 yıldız: %50-79
        if (successPercentage >= 50 && successPercentage < 80)
            return 2;

        // ⭐⭐⭐ 3 yıldız: %80-100
        if (successPercentage >= 80)
            return 3;

        // %30'un altında yıldız yok
        return 0;
    }

    // Task 6: Level Unlock Kontrolü
    public async Task<bool> CheckLevelUnlockAsync(Guid childId, Guid levelId)
    {
        // Mevcut level sonucunu kontrol et
        var currentLevelResult = await _progressRepository.GetLevelResultAsync(childId, levelId);
        
        // Eğer daha önce çözülmüşse ve %70+ başarılıysa unlock
        if (currentLevelResult != null && currentLevelResult.SuccessPercentage >= 70)
        {
            return true;
        }

        // İlk level her zaman unlock (Level.DisplayOrder = 1)
        // Bu kontrolü Level entity'den almak gerekir, şimdilik basit tutuyoruz
        // Production'da Level repository'den çekip DisplayOrder kontrolü yapılmalı
        
        return false;
    }

    // Progress kaydetme
    public async Task SaveProgressAsync(SaveProgressRequest request)
    {
        // LevelResult oluştur veya güncelle
        var existingResult = await _progressRepository.GetLevelResultAsync(request.ChildId, request.LevelId);

        if (existingResult == null)
        {
            // Yeni sonuç
            var levelResult = new LevelResult
            {
                Id = Guid.NewGuid(),
                ChildId = request.ChildId,
                LevelId = request.LevelId,
                Score = request.Score,
                Stars = request.Stars,
                CorrectCount = request.CorrectCount,
                TotalQuestions = request.TotalQuestions,
                SuccessPercentage = request.SuccessPercentage,
                IsUnlocked = true,
                CompletedAt = DateTime.UtcNow
            };

            await _progressRepository.CreateLevelResultAsync(levelResult);
        }
        else
        {
            // Mevcut sonucu güncelle (daha iyi skor varsa)
            if (request.Score > existingResult.Score)
            {
                existingResult.Score = request.Score;
                existingResult.Stars = request.Stars;
                existingResult.CorrectCount = request.CorrectCount;
                existingResult.TotalQuestions = request.TotalQuestions;
                existingResult.SuccessPercentage = request.SuccessPercentage;
                existingResult.CompletedAt = DateTime.UtcNow;

                await _progressRepository.UpdateLevelResultAsync(existingResult);
            }
        }

        // ChildProgress'i güncelle
        var childProgress = await _progressRepository.GetChildProgressAsync(request.ChildId);

        if (childProgress == null)
        {
            // İlk progress kaydı
            childProgress = new ChildProgress
            {
                Id = Guid.NewGuid(),
                ChildId = request.ChildId,
                TotalScore = request.Score,
                TotalStars = request.Stars,
                CompletedLevelsCount = 1
            };

            await _progressRepository.CreateChildProgressAsync(childProgress);
        }
        else
        {
            // Mevcut progress'i güncelle
            childProgress.TotalScore += request.Score;
            childProgress.TotalStars += request.Stars;
            
            // Completed levels count güncelle
            var completedLevels = await _progressRepository.GetLevelResultsByChildIdAsync(request.ChildId);
            childProgress.CompletedLevelsCount = completedLevels.Count;

            await _progressRepository.UpdateChildProgressAsync(childProgress);
        }
    }

    // Progress getirme
    public async Task<ChildProgressDto> GetProgressAsync(Guid childId)
    {
        var progress = await _progressRepository.GetChildProgressAsync(childId);

        if (progress == null)
        {
            // Henüz progress yoksa sıfır değerleriyle dön
            return new ChildProgressDto
            {
                Id = Guid.Empty,
                ChildId = childId,
                TotalScore = 0,
                TotalStars = 0,
                CompletedLevelsCount = 0
            };
        }

        return new ChildProgressDto
        {
            Id = progress.Id,
            ChildId = progress.ChildId,
            TotalScore = progress.TotalScore,
            TotalStars = progress.TotalStars,
            CompletedLevelsCount = progress.CompletedLevelsCount
        };
    }

    // Answer attempt kaydetme
    public async Task SaveAnswerAttemptAsync(SaveAnswerAttemptRequest request)
    {
        var answerAttempt = new AnswerAttempt
        {
            Id = Guid.NewGuid(),
            ChildId = request.ChildId,
            QuestionId = request.QuestionId,
            SubmittedAnswer = request.SubmittedAnswer,
            IsCorrect = request.IsCorrect,
            TimeTakenSeconds = request.TimeTakenSeconds,
            AttemptedAt = DateTime.UtcNow
        };

        await _progressRepository.CreateAnswerAttemptAsync(answerAttempt);
    }

    // Level results getirme
    public async Task<List<LevelResultDto>> GetLevelResultsAsync(Guid childId)
    {
        var results = await _progressRepository.GetLevelResultsByChildIdAsync(childId);

        return results.Select(r => new LevelResultDto
        {
            Id = r.Id,
            ChildId = r.ChildId,
            LevelId = r.LevelId,
            Score = r.Score,
            Stars = r.Stars,
            CorrectCount = r.CorrectCount,
            TotalQuestions = r.TotalQuestions,
            SuccessPercentage = r.SuccessPercentage,
            IsUnlocked = r.IsUnlocked,
            CompletedAt = r.CompletedAt
        }).ToList();
    }
}
