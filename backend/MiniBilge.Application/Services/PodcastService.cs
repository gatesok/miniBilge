using MiniBilge.Application.DTOs.Podcast;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

public class PodcastService : IPodcastService
{
    private readonly IPodcastRepository _repository;

    public PodcastService(IPodcastRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<PodcastEpisodeSummaryDto>> GetEpisodesByLevelAsync(int englishLevel)
    {
        var level = (EnglishLevel)englishLevel;
        var episodes = await _repository.GetEpisodesByLevelAsync(level);

        return episodes.Select(e => new PodcastEpisodeSummaryDto
        {
            Id = e.Id,
            Title = e.Title,
            Description = e.Description,
            EnglishLevel = (int)e.EnglishLevel,
            DisplayOrder = e.DisplayOrder,
            LineCount = e.Lines.Count,
            EstimatedDurationSeconds = (int)(e.Lines.Sum(l => l.Text.Length) / 13.0),
            SpeakerNames = e.Lines
                .Select(l => l.SpeakerName)
                .Distinct()
                .ToList()
        });
    }

    public async Task<PodcastEpisodeDto?> GetEpisodeAsync(Guid episodeId)
    {
        var episode = await _repository.GetEpisodeWithLinesAsync(episodeId);
        if (episode is null) return null;

        return new PodcastEpisodeDto
        {
            Id = episode.Id,
            Title = episode.Title,
            Description = episode.Description,
            EnglishLevel = (int)episode.EnglishLevel,
            DisplayOrder = episode.DisplayOrder,
            Lines = episode.Lines
                .OrderBy(l => l.DisplayOrder)
                .Select(l => new PodcastLineDto
                {
                    Id = l.Id,
                    SpeakerName = l.SpeakerName,
                    SpeakerGender = (int)l.SpeakerGender,
                    Text = l.Text,
                    TranslationTr = l.TranslationTr,
                    DisplayOrder = l.DisplayOrder,
                    AudioUrl = l.AudioUrl,
                    VoiceKey = l.VoiceKey
                })
                .ToList()
        };
    }
}
