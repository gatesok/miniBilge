namespace MiniBilge.Application.DTOs.Podcast;

public class PodcastLineDto
{
    public Guid Id { get; set; }
    public string SpeakerName { get; set; } = string.Empty;
    public int SpeakerGender { get; set; }  // 0: Male, 1: Female
    public string Text { get; set; } = string.Empty;
    public string? TranslationTr { get; set; }
    public int DisplayOrder { get; set; }
    public string? AudioUrl { get; set; }
    public string? VoiceKey { get; set; }
}

public class PodcastEpisodeSummaryDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int EnglishLevel { get; set; }
    public int DisplayOrder { get; set; }
    public int LineCount { get; set; }
    public List<string> SpeakerNames { get; set; } = new();
}

public class PodcastEpisodeDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int EnglishLevel { get; set; }
    public int DisplayOrder { get; set; }
    public List<PodcastLineDto> Lines { get; set; } = new();
}
