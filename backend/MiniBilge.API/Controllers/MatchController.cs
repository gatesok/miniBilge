using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Education;
using MiniBilge.Application.DTOs.Match;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Enums;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class MatchController : ControllerBase
{
    private readonly IMatchmakingService _matchmakingService;
    private readonly IMatchRepository _matchRepository;
    private readonly IChildProfileRepository _childProfileRepository;

    public MatchController(
        IMatchmakingService matchmakingService,
        IMatchRepository matchRepository,
        IChildProfileRepository childProfileRepository)
    {
        _matchmakingService = matchmakingService;
        _matchRepository = matchRepository;
        _childProfileRepository = childProfileRepository;
    }

    /// <summary>
    /// Request a new match
    /// </summary>
    [HttpPost("request")]
    public async Task<IActionResult> RequestMatch([FromBody] RequestMatchDto request)
    {
        try
        {
            var matchRequest = await _matchmakingService.RequestMatchAsync(request.ChildId);
            
            return Ok(new
            {
                RequestId = matchRequest.Id,
                Status = matchRequest.Status.ToString(),
                RequestedAt = matchRequest.RequestedAt,
                MatchSessionId = matchRequest.MatchSessionId
            });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An error occurred while requesting match", details = ex.Message });
        }
    }

    /// <summary>
    /// Cancel an active match request
    /// </summary>
    [HttpDelete("request")]
    public async Task<IActionResult> CancelMatchRequest([FromQuery] Guid childId)
    {
        try
        {
            var cancelled = await _matchmakingService.CancelMatchRequestAsync(childId);
            
            if (!cancelled)
            {
                return NotFound(new { message = "No active match request found" });
            }
            
            return Ok(new { message = "Match request cancelled" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An error occurred while cancelling request", details = ex.Message });
        }
    }

    /// <summary>
    /// Get match session details
    /// </summary>
    [HttpGet("{matchId}")]
    public async Task<IActionResult> GetMatchSession(Guid matchId)
    {
        try
        {
            var matchSession = await _matchRepository.GetMatchSessionAsync(matchId, includeAll: true);
            
            if (matchSession == null)
            {
                return NotFound(new { message = "Match session not found" });
            }

            var participants = matchSession.Participants.ToList();
            if (participants.Count < 2)
            {
                return BadRequest(new { message = "Invalid match session" });
            }

            var player1 = participants[0];
            var player2 = participants[1];

            var winner = matchSession.WinnerId.HasValue
                ? participants.FirstOrDefault(p => p.ChildProfileId == matchSession.WinnerId.Value)
                : null;

            var dto = new MatchSessionDto
            {
                Id = matchSession.Id,
                CreatedAt = matchSession.CreatedAt,
                StartedAt = matchSession.StartedAt,
                EndedAt = matchSession.EndedAt,
                Status = matchSession.Status.ToString(),
                TimePerQuestion = MatchmakingService.TimePerQuestion,
                Player1 = new MatchParticipantDto
                {
                    ChildId = player1.ChildProfileId,
                    Name = player1.ChildProfile.Name,
                    Score = player1.Score,
                    AvatarImageUrl = player1.ChildProfile.AvatarImageUrl
                },
                Player2 = new MatchParticipantDto
                {
                    ChildId = player2.ChildProfileId,
                    Name = player2.ChildProfile.Name,
                    Score = player2.Score,
                    AvatarImageUrl = player2.ChildProfile.AvatarImageUrl
                },
                Winner = winner != null ? new MatchParticipantDto
                {
                    ChildId = winner.ChildProfileId,
                    Name = winner.ChildProfile.Name,
                    Score = winner.Score,
                    AvatarImageUrl = winner.ChildProfile.AvatarImageUrl
                } : null,
                Questions = matchSession.Questions
                    .OrderBy(mq => mq.QuestionOrder)
                    .Select(mq => new QuestionDto
                    {
                        Id = mq.Question.Id,
                        LevelId = mq.Question.LevelId,
                        QuestionText = mq.Question.QuestionText,
                        QuestionType = mq.Question.QuestionType,
                        Explanation = mq.Question.Explanation,
                        HasLatex = mq.Question.HasLatex,
                        Options = mq.Question.Options
                            .OrderBy(o => o.DisplayOrder)
                            .Select(o => new QuestionOptionDto
                            {
                                Id = o.Id,
                                OptionText = o.OptionText,
                                DisplayOrder = o.DisplayOrder,
                                HasLatex = o.HasLatex
                            }).ToList()
                    }).ToList()
            };

            return Ok(dto);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An error occurred while fetching match session", details = ex.Message });
        }
    }

    /// <summary>
    /// Get match history for a child
    /// </summary>
    [HttpGet("history")]
    public async Task<IActionResult> GetMatchHistory([FromQuery] Guid childId, [FromQuery] int pageSize = 10, [FromQuery] int pageNumber = 1)
    {
        try
        {
            var matchSessions = await _matchRepository.GetMatchHistoryAsync(childId, pageSize, pageNumber);
            
            var dtos = matchSessions.Select(ms =>
            {
                var participants = ms.Participants.ToList();
                var player1 = participants[0];
                var player2 = participants[1];
                var winner = ms.WinnerId.HasValue
                    ? participants.FirstOrDefault(p => p.ChildProfileId == ms.WinnerId.Value)
                    : null;

                return new MatchSessionDto
                {
                    Id = ms.Id,
                    CreatedAt = ms.CreatedAt,
                    StartedAt = ms.StartedAt,
                    EndedAt = ms.EndedAt,
                    Status = ms.Status.ToString(),
                    TimePerQuestion = MatchmakingService.TimePerQuestion,
                    Player1 = new MatchParticipantDto
                    {
                        ChildId = player1.ChildProfileId,
                        Name = player1.ChildProfile.Name,
                        Score = player1.Score,
                        AvatarImageUrl = player1.ChildProfile.AvatarImageUrl
                    },
                    Player2 = new MatchParticipantDto
                    {
                        ChildId = player2.ChildProfileId,
                        Name = player2.ChildProfile.Name,
                        Score = player2.Score,
                        AvatarImageUrl = player2.ChildProfile.AvatarImageUrl
                    },
                    Winner = winner != null ? new MatchParticipantDto
                    {
                        ChildId = winner.ChildProfileId,
                        Name = winner.ChildProfile.Name,
                        Score = winner.Score,
                        AvatarImageUrl = winner.ChildProfile.AvatarImageUrl
                    } : null
                };
            }).ToList();

            return Ok(dtos);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An error occurred while fetching match history", details = ex.Message });
        }
    }

    /// <summary>
    /// Get match statistics for a child
    /// </summary>
    [HttpGet("stats/{childId}")]
    public async Task<IActionResult> GetMatchStats(Guid childId)
    {
        try
        {
            var (totalMatches, wins, losses) = await _matchRepository.GetMatchStatsAsync(childId);
            
            var winRate = totalMatches > 0 ? (double)wins / totalMatches * 100 : 0;

            var dto = new MatchStatsDto
            {
                TotalMatches = totalMatches,
                Wins = wins,
                Losses = losses,
                WinRate = Math.Round(winRate, 2)
            };

            return Ok(dto);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An error occurred while fetching match stats", details = ex.Message });
        }
    }
}

public class RequestMatchDto
{
    public Guid ChildId { get; set; }
}
