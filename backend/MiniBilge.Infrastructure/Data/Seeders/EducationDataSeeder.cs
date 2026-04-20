using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Data.Seeders;

public static class EducationDataSeeder
{
    public static async Task SeedAsync(ApplicationDbContext context)
    {
        // Matematik subject'i oluştur
        var mathSubject = new Subject
        {
            Id = Guid.NewGuid(),
            Name = "Matematik",
            DisplayOrder = 1,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        if (!context.Subjects.Any(s => s.Name == "Matematik"))
        {
            context.Subjects.Add(mathSubject);
            await context.SaveChangesAsync();
        }
        else
        {
            mathSubject = context.Subjects.First(s => s.Name == "Matematik");
        }

        // Topic'leri oluştur
        var topics = new List<Topic>();
        
        var sayiGorselTopic = new Topic
        {
            Id = Guid.NewGuid(),
            SubjectId = mathSubject.Id,
            Name = "Sayı & Görsel",
            Description = "Sayıları tanıma ve görsel olarak sayma",
            DisplayOrder = 1,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var toplamaTopic = new Topic
        {
            Id = Guid.NewGuid(),
            SubjectId = mathSubject.Id,
            Name = "Toplama",
            Description = "Toplama işlemi",
            DisplayOrder = 2,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var cikarmaTopic = new Topic
        {
            Id = Guid.NewGuid(),
            SubjectId = mathSubject.Id,
            Name = "Çıkarma",
            Description = "Çıkarma işlemi",
            DisplayOrder = 3,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var problemlerTopic = new Topic
        {
            Id = Guid.NewGuid(),
            SubjectId = mathSubject.Id,
            Name = "Problemler",
            Description = "Sözel matematik problemleri",
            DisplayOrder = 4,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        if (!context.Topics.Any(t => t.SubjectId == mathSubject.Id))
        {
            topics.AddRange(new[] { sayiGorselTopic, toplamaTopic, cikarmaTopic, problemlerTopic });
            context.Topics.AddRange(topics);
            await context.SaveChangesAsync();
        }
        else
        {
            sayiGorselTopic = context.Topics.First(t => t.Name == "Sayı & Görsel");
            toplamaTopic = context.Topics.First(t => t.Name == "Toplama");
            cikarmaTopic = context.Topics.First(t => t.Name == "Çıkarma");
            problemlerTopic = context.Topics.First(t => t.Name == "Problemler");
        }

        // Level'leri oluştur
        var sayiGorselLevel = new Level
        {
            Id = Guid.NewGuid(),
            TopicId = sayiGorselTopic.Id,
            Name = "Okul Öncesi",
            Description = "1-10 arası sayılar",
            Difficulty = 1,
            DisplayOrder = 1,
            MinCorrectToPass = 7,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var toplamaLevel = new Level
        {
            Id = Guid.NewGuid(),
            TopicId = toplamaTopic.Id,
            Name = "Seviye 1",
            Description = "Basit toplama işlemleri",
            Difficulty = 2,
            DisplayOrder = 1,
            MinCorrectToPass = 4,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var cikarmaLevel = new Level
        {
            Id = Guid.NewGuid(),
            TopicId = cikarmaTopic.Id,
            Name = "Seviye 1",
            Description = "Basit çıkarma işlemleri",
            Difficulty = 2,
            DisplayOrder = 1,
            MinCorrectToPass = 4,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var problemlerLevel = new Level
        {
            Id = Guid.NewGuid(),
            TopicId = problemlerTopic.Id,
            Name = "Seviye 1",
            Description = "Basit sözel problemler",
            Difficulty = 3,
            DisplayOrder = 1,
            MinCorrectToPass = 4,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        if (!context.Levels.Any(l => l.TopicId == sayiGorselTopic.Id))
        {
            context.Levels.AddRange(new[] { sayiGorselLevel, toplamaLevel, cikarmaLevel, problemlerLevel });
            await context.SaveChangesAsync();
        }
        else
        {
            sayiGorselLevel = context.Levels.First(l => l.TopicId == sayiGorselTopic.Id);
            toplamaLevel = context.Levels.First(l => l.TopicId == toplamaTopic.Id);
            cikarmaLevel = context.Levels.First(l => l.TopicId == cikarmaTopic.Id);
            problemlerLevel = context.Levels.First(l => l.TopicId == problemlerTopic.Id);
        }

        // Sayı & Görsel Soruları
        if (!context.Questions.Any(q => q.LevelId == sayiGorselLevel.Id))
        {
            var sayiGorselQuestions = new List<Question>
            {
                new Question
                {
                    Id = Guid.NewGuid(),
                    LevelId = sayiGorselLevel.Id,
                    QuestionText = "🍎🍎 kaç tane elma var?",
                    QuestionType = QuestionType.MultipleChoice,
                    CorrectAnswer = "B",
                    Explanation = "İki tane elma var.",
                    DisplayOrder = 1,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Question
                {
                    Id = Guid.NewGuid(),
                    LevelId = sayiGorselLevel.Id,
                    QuestionText = "🐶🐶🐶 kaç köpek var?",
                    QuestionType = QuestionType.MultipleChoice,
                    CorrectAnswer = "B",
                    DisplayOrder = 2,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Question
                {
                    Id = Guid.NewGuid(),
                    LevelId = sayiGorselLevel.Id,
                    QuestionText = "Hangisi daha büyüktür?",
                    QuestionType = QuestionType.MultipleChoice,
                    CorrectAnswer = "B",
                    DisplayOrder = 3,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Question
                {
                    Id = Guid.NewGuid(),
                    LevelId = sayiGorselLevel.Id,
                    QuestionText = "Hangisi daha küçüktür?",
                    QuestionType = QuestionType.MultipleChoice,
                    CorrectAnswer = "B",
                    DisplayOrder = 4,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Question
                {
                    Id = Guid.NewGuid(),
                    LevelId = sayiGorselLevel.Id,
                    QuestionText = "🍌🍌🍌🍌 kaç muz var?",
                    QuestionType = QuestionType.MultipleChoice,
                    CorrectAnswer = "B",
                    DisplayOrder = 5,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Question
                {
                    Id = Guid.NewGuid(),
                    LevelId = sayiGorselLevel.Id,
                    QuestionText = "Boşluğu doldur: 1, 2, __, 4",
                    QuestionType = QuestionType.NumericInput,
                    CorrectAnswer = "3",
                    DisplayOrder = 6,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Question
                {
                    Id = Guid.NewGuid(),
                    LevelId = sayiGorselLevel.Id,
                    QuestionText = "Hangisi 10'dan küçüktür?",
                    QuestionType = QuestionType.MultipleChoice,
                    CorrectAnswer = "B",
                    DisplayOrder = 7,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Question
                {
                    Id = Guid.NewGuid(),
                    LevelId = sayiGorselLevel.Id,
                    QuestionText = "3'ten sonra hangi sayı gelir?",
                    QuestionType = QuestionType.MultipleChoice,
                    CorrectAnswer = "A",
                    DisplayOrder = 8,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Question
                {
                    Id = Guid.NewGuid(),
                    LevelId = sayiGorselLevel.Id,
                    QuestionText = "5'ten önce hangi sayı gelir?",
                    QuestionType = QuestionType.MultipleChoice,
                    CorrectAnswer = "A",
                    DisplayOrder = 9,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Question
                {
                    Id = Guid.NewGuid(),
                    LevelId = sayiGorselLevel.Id,
                    QuestionText = "En büyük sayı hangisi?",
                    QuestionType = QuestionType.MultipleChoice,
                    CorrectAnswer = "B",
                    DisplayOrder = 10,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                }
            };

            context.Questions.AddRange(sayiGorselQuestions);
            await context.SaveChangesAsync();

            // Şıkları ekle
            var options = new List<QuestionOption>
            {
                // Soru 1: 🍎🍎
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[0].Id, OptionText = "1", DisplayOrder = 0, CreatedAt = DateTime.UtcNow },
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[0].Id, OptionText = "2", DisplayOrder = 1, CreatedAt = DateTime.UtcNow },
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[0].Id, OptionText = "3", DisplayOrder = 2, CreatedAt = DateTime.UtcNow },
                
                // Soru 2: 🐶🐶🐶
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[1].Id, OptionText = "2", DisplayOrder = 0, CreatedAt = DateTime.UtcNow },
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[1].Id, OptionText = "3", DisplayOrder = 1, CreatedAt = DateTime.UtcNow },
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[1].Id, OptionText = "4", DisplayOrder = 2, CreatedAt = DateTime.UtcNow },
                
                // Soru 3: Hangisi daha büyük (2 vs 5)
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[2].Id, OptionText = "2", DisplayOrder = 0, CreatedAt = DateTime.UtcNow },
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[2].Id, OptionText = "5", DisplayOrder = 1, CreatedAt = DateTime.UtcNow },
                
                // Soru 4: Hangisi daha küçük (7 vs 3)
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[3].Id, OptionText = "7", DisplayOrder = 0, CreatedAt = DateTime.UtcNow },
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[3].Id, OptionText = "3", DisplayOrder = 1, CreatedAt = DateTime.UtcNow },
                
                // Soru 5: 🍌🍌🍌🍌
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[4].Id, OptionText = "3", DisplayOrder = 0, CreatedAt = DateTime.UtcNow },
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[4].Id, OptionText = "4", DisplayOrder = 1, CreatedAt = DateTime.UtcNow },
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[4].Id, OptionText = "5", DisplayOrder = 2, CreatedAt = DateTime.UtcNow },
                
                // Soru 7: 10'dan küçük
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[6].Id, OptionText = "12", DisplayOrder = 0, CreatedAt = DateTime.UtcNow },
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[6].Id, OptionText = "8", DisplayOrder = 1, CreatedAt = DateTime.UtcNow },
                
                // Soru 8: 3'ten sonra
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[7].Id, OptionText = "4", DisplayOrder = 0, CreatedAt = DateTime.UtcNow },
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[7].Id, OptionText = "5", DisplayOrder = 1, CreatedAt = DateTime.UtcNow },
                
                // Soru 9: 5'ten önce
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[8].Id, OptionText = "4", DisplayOrder = 0, CreatedAt = DateTime.UtcNow },
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[8].Id, OptionText = "6", DisplayOrder = 1, CreatedAt = DateTime.UtcNow },
                
                // Soru 10: En büyük (6, 9, 7)
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[9].Id, OptionText = "6", DisplayOrder = 0, CreatedAt = DateTime.UtcNow },
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[9].Id, OptionText = "9", DisplayOrder = 1, CreatedAt = DateTime.UtcNow },
                new QuestionOption { Id = Guid.NewGuid(), QuestionId = sayiGorselQuestions[9].Id, OptionText = "7", DisplayOrder = 2, CreatedAt = DateTime.UtcNow }
            };

            context.QuestionOptions.AddRange(options);
            await context.SaveChangesAsync();
        }

        // Toplama Soruları
        if (!context.Questions.Any(q => q.LevelId == toplamaLevel.Id))
        {
            var toplamaQuestions = new List<Question>
            {
                new Question { Id = Guid.NewGuid(), LevelId = toplamaLevel.Id, QuestionText = "2 + 3 = ?", QuestionType = QuestionType.NumericInput, CorrectAnswer = "5", DisplayOrder = 1, IsActive = true, CreatedAt = DateTime.UtcNow },
                new Question { Id = Guid.NewGuid(), LevelId = toplamaLevel.Id, QuestionText = "4 + 1 = ?", QuestionType = QuestionType.NumericInput, CorrectAnswer = "5", DisplayOrder = 2, IsActive = true, CreatedAt = DateTime.UtcNow },
                new Question { Id = Guid.NewGuid(), LevelId = toplamaLevel.Id, QuestionText = "5 + 2 = ?", QuestionType = QuestionType.NumericInput, CorrectAnswer = "7", DisplayOrder = 3, IsActive = true, CreatedAt = DateTime.UtcNow },
                new Question { Id = Guid.NewGuid(), LevelId = toplamaLevel.Id, QuestionText = "3 + 6 = ?", QuestionType = QuestionType.NumericInput, CorrectAnswer = "9", DisplayOrder = 4, IsActive = true, CreatedAt = DateTime.UtcNow },
                new Question { Id = Guid.NewGuid(), LevelId = toplamaLevel.Id, QuestionText = "7 + 1 = ?", QuestionType = QuestionType.NumericInput, CorrectAnswer = "8", DisplayOrder = 5, IsActive = true, CreatedAt = DateTime.UtcNow }
            };

            context.Questions.AddRange(toplamaQuestions);
            await context.SaveChangesAsync();
        }

        // Çıkarma Soruları
        if (!context.Questions.Any(q => q.LevelId == cikarmaLevel.Id))
        {
            var cikarmaQuestions = new List<Question>
            {
                new Question { Id = Guid.NewGuid(), LevelId = cikarmaLevel.Id, QuestionText = "5 - 2 = ?", QuestionType = QuestionType.NumericInput, CorrectAnswer = "3", DisplayOrder = 1, IsActive = true, CreatedAt = DateTime.UtcNow },
                new Question { Id = Guid.NewGuid(), LevelId = cikarmaLevel.Id, QuestionText = "7 - 3 = ?", QuestionType = QuestionType.NumericInput, CorrectAnswer = "4", DisplayOrder = 2, IsActive = true, CreatedAt = DateTime.UtcNow },
                new Question { Id = Guid.NewGuid(), LevelId = cikarmaLevel.Id, QuestionText = "9 - 1 = ?", QuestionType = QuestionType.NumericInput, CorrectAnswer = "8", DisplayOrder = 3, IsActive = true, CreatedAt = DateTime.UtcNow },
                new Question { Id = Guid.NewGuid(), LevelId = cikarmaLevel.Id, QuestionText = "8 - 2 = ?", QuestionType = QuestionType.NumericInput, CorrectAnswer = "6", DisplayOrder = 4, IsActive = true, CreatedAt = DateTime.UtcNow },
                new Question { Id = Guid.NewGuid(), LevelId = cikarmaLevel.Id, QuestionText = "6 - 3 = ?", QuestionType = QuestionType.NumericInput, CorrectAnswer = "3", DisplayOrder = 5, IsActive = true, CreatedAt = DateTime.UtcNow }
            };

            context.Questions.AddRange(cikarmaQuestions);
            await context.SaveChangesAsync();
        }

        // Problem Soruları
        if (!context.Questions.Any(q => q.LevelId == problemlerLevel.Id))
        {
            var problemQuestions = new List<Question>
            {
                new Question { Id = Guid.NewGuid(), LevelId = problemlerLevel.Id, QuestionText = "Ali'nin 2 elması var. 2 tane daha aldı. Kaç oldu?", QuestionType = QuestionType.NumericInput, CorrectAnswer = "4", Explanation = "2 + 2 = 4", DisplayOrder = 1, IsActive = true, CreatedAt = DateTime.UtcNow },
                new Question { Id = Guid.NewGuid(), LevelId = problemlerLevel.Id, QuestionText = "Ayşe'nin 5 kalemi var. 1 tanesi kırıldı. Kaç kaldı?", QuestionType = QuestionType.NumericInput, CorrectAnswer = "4", Explanation = "5 - 1 = 4", DisplayOrder = 2, IsActive = true, CreatedAt = DateTime.UtcNow },
                new Question { Id = Guid.NewGuid(), LevelId = problemlerLevel.Id, QuestionText = "Bir sepette 3 elma vardı. 3 tane daha eklendi. Kaç oldu?", QuestionType = QuestionType.NumericInput, CorrectAnswer = "6", Explanation = "3 + 3 = 6", DisplayOrder = 3, IsActive = true, CreatedAt = DateTime.UtcNow },
                new Question { Id = Guid.NewGuid(), LevelId = problemlerLevel.Id, QuestionText = "4 kuş vardı. 1'i uçtu. Kaç kaldı?", QuestionType = QuestionType.NumericInput, CorrectAnswer = "3", Explanation = "4 - 1 = 3", DisplayOrder = 4, IsActive = true, CreatedAt = DateTime.UtcNow },
                new Question { Id = Guid.NewGuid(), LevelId = problemlerLevel.Id, QuestionText = "7 balon vardı. 2'si patladı. Kaç kaldı?", QuestionType = QuestionType.NumericInput, CorrectAnswer = "5", Explanation = "7 - 2 = 5", DisplayOrder = 5, IsActive = true, CreatedAt = DateTime.UtcNow }
            };

            context.Questions.AddRange(problemQuestions);
            await context.SaveChangesAsync();
        }
    }
}
