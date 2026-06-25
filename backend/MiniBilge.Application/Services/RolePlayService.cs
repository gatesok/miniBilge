using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.DTOs.RolePlay;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Services;

public class RolePlayService : IRolePlayService
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IRolePlayRepository _rolePlayRepository;
    private readonly IRolePlayScenarioRepository _scenarioRepository;
    private readonly IChildProfileRepository _childProfileRepository;
    private readonly ILogger<RolePlayService> _logger;

    private const int MaxTurnsPerSession = 20;
    private const int ContextTurns = 10;     // GPT'ye gönderilecek son tur sayısı
    private const int CoinsHigh = 25; private const int StarsHigh = 2;
    private const int CoinsMid  = 15; private const int StarsMid  = 1;
    private const int CoinsLow  = 5;  private const int StarsLow  = 0;

    public RolePlayService(
        IHttpClientFactory httpClientFactory,
        IRolePlayRepository rolePlayRepository,
        IRolePlayScenarioRepository scenarioRepository,
        IChildProfileRepository childProfileRepository,
        ILogger<RolePlayService> logger)
    {
        _httpClientFactory = httpClientFactory;
        _rolePlayRepository = rolePlayRepository;
        _scenarioRepository = scenarioRepository;
        _childProfileRepository = childProfileRepository;
        _logger = logger;
    }

    // ─── GetScenariosAsync ───────────────────────────────────────────────────

    public async Task<List<ScenarioDto>> GetScenariosAsync(string level)
    {
        var scenarios = await _scenarioRepository.GetByLevelAsync(level);
        return scenarios.Select(s => new ScenarioDto
        {
            Key           = s.Key,
            Title         = s.Title,
            Description   = s.Description,
            Level         = s.Level,
            CharacterName = s.CharacterName,
            CharacterRole = s.CharacterRole,
            Emoji         = s.Emoji,
        }).ToList();
    }

    // ─── StartSessionAsync ───────────────────────────────────────────────────

    public async Task<StartRolePlayResponse> StartSessionAsync(StartRolePlayRequest request)
    {
        var scenario = await _scenarioRepository.GetByKeyAsync(request.ScenarioKey)
            ?? throw new InvalidOperationException($"Senaryo bulunamadı: {request.ScenarioKey}");

        // DB'de oturum oluştur
        var session = await _rolePlayRepository.CreateSessionAsync(new RolePlaySession
        {
            ChildProfileId = request.ChildProfileId,
            ScenarioKey    = request.ScenarioKey,
            Level          = request.Level,
            Status         = "active",
        });

        // Açılış cümlesini assistant turn olarak kaydet
        await _rolePlayRepository.AddTurnAsync(new RolePlayTurn
        {
            SessionId   = session.Id,
            Role        = "assistant",
            Content     = scenario.OpeningLine,
            GrammarNote = null,
        });

        return new StartRolePlayResponse
        {
            SessionId        = session.Id,
            AssistantMessage = scenario.OpeningLine,
            CharacterName    = scenario.CharacterName,
            CharacterRole    = scenario.CharacterRole,
            ScenarioTitle    = scenario.Title,
            Emoji            = scenario.Emoji,
        };
    }

    // ─── SendTurnAsync ───────────────────────────────────────────────────────

    public async Task<SendTurnResponse> SendTurnAsync(SendTurnRequest request)
    {
        var session = await _rolePlayRepository.GetSessionAsync(request.SessionId)
            ?? throw new InvalidOperationException("Oturum bulunamadı.");

        if (session.Status == "completed")
            throw new InvalidOperationException("Bu oturum tamamlanmış.");

        var scenario = await _scenarioRepository.GetByKeyAsync(session.ScenarioKey)
            ?? throw new InvalidOperationException("Senaryo bulunamadı.");

        // Kullanıcı turunu kaydet
        await _rolePlayRepository.AddTurnAsync(new RolePlayTurn
        {
            SessionId = session.Id,
            Role      = "user",
            Content   = request.UserMessage,
        });
        await _rolePlayRepository.IncrementTurnCountAsync(session.Id);

        // Son N turu GPT bağlamı için al
        var allTurns = await _rolePlayRepository.GetTurnsAsync(session.Id);
        var contextTurns = allTurns.TakeLast(ContextTurns).ToList();

        // ── Dinamik sistem yönergesi ─────────────────────────────────────────
        var userTurnCount = allTurns.Count(t => t.Role == "user");
        var phaseNote = userTurnCount switch
        {
            <= 2 => "OPENING — Warmly introduce yourself and the setting. Make the child feel welcome and curious.",
            <= 6 => "MIDDLE — You are the conversation DRIVER. Each turn, introduce ONE new topic or angle (a new item, a detail, a fun fact, a suggestion) that has NOT come up yet, then ask a focused question that naturally steers the child toward exploring it.",
            _    => "CLOSING — Bring the interaction to a natural, warm conclusion. Summarise what happened and say goodbye."
        };

        // Seviye bazlı zorluk ve kalıp yönergesi
        var levelGuidance = session.Level switch
        {
            "A1" =>
                "LEVEL A1: Use only very simple words and short sentences. " +
                "Ask one basic question at a time (yes/no or single-word answers are fine). " +
                "Be patient and encouraging.",

            "A2" =>
                "LEVEL A2: Use simple but slightly varied sentence structures. " +
                "Ask questions that require short phrases (2-5 words). " +
                "Gently introduce common expressions (e.g. 'I would like…', 'How about…?'). " +
                "Encourage the child to form complete sentences.",

            "B1" =>
                "LEVEL B1: Use natural conversational English with modal verbs (would, could, should, might). " +
                "Ask for REASONS and OPINIONS, not just facts — e.g. 'Why do you prefer that?', 'What do you think about…?'. " +
                "Challenge the child to give 2-3 sentence answers. " +
                "Introduce one idiomatic expression per turn and weave it naturally into your message.",

            "B2" =>
                "LEVEL B2: Use rich, natural English including conditionals ('If you could…', 'What would happen if…'), " +
                "present perfect, passive voice, and idiomatic phrases. " +
                "PUSH the learner: ask hypothetical questions, challenge their opinions politely, " +
                "ask them to explain or justify their choices in detail. " +
                "Expect 3-5 sentence responses. If their answer is too short, follow up with 'Can you tell me more about that?'. " +
                "Introduce at least one new idiom or collocation per turn.",

            "C1" =>
                "LEVEL C1: Use sophisticated, near-native English with nuanced vocabulary and complex sentence structures. " +
                "Engage the learner in abstract thinking — ask for analysis, evaluation, and elaboration. " +
                "Challenge their word choice: if they use a basic word, model a more precise alternative naturally in your reply. " +
                "Ask open-ended questions that require well-structured, multi-sentence answers (5+ sentences). " +
                "Introduce formal register alternatives, collocations, and phrasal verbs. " +
                "Probe deeper with follow-ups like 'What are the implications of that?' or 'How would you weigh that against…?'.",

            "C2" =>
                "LEVEL C2: Communicate at a fully fluent, educated-native level. " +
                "Discuss subtle distinctions, cultural nuances, and abstract or academic concepts naturally woven into the scenario. " +
                "Debate, counter-argue politely, and challenge assumptions. " +
                "Use literary expressions, proverbs, or culturally rich references where appropriate, then invite the learner to react. " +
                "Expect articulate, nuanced responses; push back gently if the answer lacks depth: " +
                "'That's interesting — but have you considered the other side of that?' " +
                "Vary your rhetorical style: rhetorical questions, concession + contrast ('While X is true, wouldn't you say…?').",

            _ =>
                "Use age-appropriate, clear English suited to the scenario level."
        };

        // Bağlamdaki önceki AI mesajlarını GPT'ye hatırlat (tekrar önlemek için)
        var previousAiSnippets = contextTurns
            .Where(t => t.Role == "assistant")
            .Select(t => t.Content.Length > 80 ? t.Content[..80] + "…" : t.Content)
            .ToList();

        var coveredNote = previousAiSnippets.Count > 0
            ? $"\nAlready covered (do NOT revisit): [{string.Join(" | ", previousAiSnippets)}]."
            : string.Empty;

        var dynamicSuffix =
            $"\n\n[Turn {userTurnCount}] {phaseNote}{coveredNote}" +
            $"\n{levelGuidance}" +
            "\nYour move: pick ONE fresh angle the child has not engaged with yet. " +
            "Make an interesting observation, offer, or fun fact that opens that angle — " +
            "then ask exactly ONE guiding question to draw the child into it. " +
            "Never ask the same type of question twice.";

        var systemContent  = scenario.SystemPrompt + dynamicSuffix;
        // ────────────────────────────────────────────────────────────────────

        // GPT mesaj geçmişi oluştur
        var messages = new List<object>
        {
            new { role = "system", content = systemContent }
        };
        foreach (var turn in contextTurns)
        {
            messages.Add(new { role = turn.Role, content = turn.Content });
        }

        var raw = await CallGptAsync(messages);

        string assistantMessage;
        string? grammarNote = null;

        try
        {
            using var doc = JsonDocument.Parse(raw);
            var root = doc.RootElement;
            assistantMessage = root.TryGetProperty("message", out var msg)
                ? msg.GetString() ?? "..."
                : "...";
            grammarNote = root.TryGetProperty("grammar_note", out var gn)
                ? gn.GetString()
                : null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "RolePlay tur parse hatası. Raw: {Raw}", raw);
            assistantMessage = "I see! Tell me more.";
        }

        // Assistant turunu kaydet
        await _rolePlayRepository.AddTurnAsync(new RolePlayTurn
        {
            SessionId   = session.Id,
            Role        = "assistant",
            Content     = assistantMessage,
            GrammarNote = grammarNote,
        });

        var newTurnCount = session.TurnCount + 1;
        var maxReached = newTurnCount >= MaxTurnsPerSession;

        return new SendTurnResponse
        {
            AssistantMessage = assistantMessage,
            GrammarNote      = grammarNote,
            TurnCount        = newTurnCount,
            MaxTurnsReached  = maxReached,
        };
    }

    // ─── EndSessionAsync ─────────────────────────────────────────────────────

    public async Task<EndSessionResponse> EndSessionAsync(EndSessionRequest request)
    {
        var session = await _rolePlayRepository.GetSessionAsync(request.SessionId)
            ?? throw new InvalidOperationException("Oturum bulunamadı.");

        var turns  = await _rolePlayRepository.GetTurnsAsync(request.SessionId);
        var scenario = await _scenarioRepository.GetByKeyAsync(session.ScenarioKey);

        var userTurns = turns.Where(t => t.Role == "user").ToList();
        if (userTurns.Count == 0)
        {
            await _rolePlayRepository.CompleteSessionAsync(request.SessionId, 0, "Konuşma çok kısa oldu.");
            return new EndSessionResponse { Score = 0, Feedback = "Konuşma çok kısa oldu.", TurnCount = 0 };
        }

        // Konuşma geçmişini özetle
        var conversation = string.Join("\n", turns.Select(t => $"{t.Role.ToUpper()}: {t.Content}"));

        var evalSystem =
            $"You are an English teacher evaluating a role-play conversation between a child (age 6-12) and a character. " +
            $"The scenario was: \"{scenario?.Title ?? session.ScenarioKey}\" at CEFR {session.Level} level. " +
            $"Evaluate the child's (USER) messages only. Be encouraging and constructive. " +
            $"Return ONLY valid JSON with keys: " +
            $"\"score\" (integer 0-100), " +
            $"\"feedback\" (string in Turkish, 2-3 encouraging sentences, mention what they did well).";

        var evalUser = $"Conversation:\n{conversation}";

        var raw = await CallGptAsync(new List<object>
        {
            new { role = "system", content = evalSystem },
            new { role = "user",   content = evalUser },
        });

        int score = 60;
        string feedback = "Harika bir konuşma yaptın! Devam et!";

        try
        {
            using var doc = JsonDocument.Parse(raw);
            var root = doc.RootElement;
            if (root.TryGetProperty("score", out var s)) score = Math.Clamp(s.GetInt32(), 0, 100);
            if (root.TryGetProperty("feedback", out var f)) feedback = f.GetString() ?? feedback;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "RolePlay bitiş değerlendirme parse hatası. Raw: {Raw}", raw);
        }

        await _rolePlayRepository.CompleteSessionAsync(request.SessionId, score, feedback);

        // Ödül
        int coins = 0, stars = 0;
        if (request.ChildProfileId.HasValue)
        {
            (coins, stars) = score >= 80 ? (CoinsHigh, StarsHigh)
                           : score >= 50 ? (CoinsMid,  StarsMid)
                           :               (CoinsLow,  StarsLow);

            var child = await _childProfileRepository.GetByIdAsync(request.ChildProfileId.Value);
            if (child is not null)
            {
                child.TotalCoins += coins;
                child.TotalStars += stars;
                await _childProfileRepository.UpdateAsync(child);
            }
        }

        return new EndSessionResponse
        {
            Score       = score,
            Feedback    = feedback,
            TurnCount   = userTurns.Count,
            CoinsEarned = coins,
            StarsEarned = stars,
        };
    }

    // ─── Helper ──────────────────────────────────────────────────────────────

    private async Task<string> CallGptAsync(List<object> messages)
    {
        var client = _httpClientFactory.CreateClient("openai");

        var body = new
        {
            model           = "gpt-4o-mini",
            messages        = messages,
            response_format = new { type = "json_object" },
            max_tokens      = 400,
            temperature     = 0.8,
        };

        var json     = JsonSerializer.Serialize(body);
        var content  = new StringContent(json, Encoding.UTF8, "application/json");
        var response = await client.PostAsync("chat/completions", content);
        response.EnsureSuccessStatusCode();

        var responseJson = await response.Content.ReadAsStringAsync();
        using var doc    = JsonDocument.Parse(responseJson);
        return doc.RootElement
            .GetProperty("choices")[0]
            .GetProperty("message")
            .GetProperty("content")
            .GetString() ?? "{}";
    }
}
