using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Education;
using MiniBilge.Application.DTOs.Match;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
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
    private readonly IMatchInvitationService _matchInvitationService;

    public MatchController(
        IMatchmakingService matchmakingService,
        IMatchRepository matchRepository,
        IChildProfileRepository childProfileRepository,
        IMatchInvitationService matchInvitationService)
    {
        _matchmakingService      = matchmakingService;
        _matchRepository         = matchRepository;
        _childProfileRepository  = childProfileRepository;
        _matchInvitationService  = matchInvitationService;
    }

    /// <summary>
    /// Request a new match
    /// </summary>
    [HttpPost("request")]
    public async Task<IActionResult> RequestMatch([FromBody] RequestMatchDto request)
    {
        try
        {
            var matchRequest = await _matchmakingService.RequestMatchAsync(request.ChildId, request.SubjectId);
            
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
            return StatusCode(500, new { message = "Maç isteği sırasında bir hata oluştu" });
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
                return NotFound(new { message = "Aktif maç isteği bulunamadı" });
            }
            
            return Ok(new { message = "Maç isteği iptal edildi" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "İptal işlemi sırasında bir hata oluştu" });
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
                return NotFound(new { message = "Maç oturumu bulunamadı" });
            }

            var participants = matchSession.Participants.ToList();
            if (participants.Count < 2)
            {
                return BadRequest(new { message = "Geçersiz maç oturumu" });
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
                        Options = mq.Question.Options
                            .OrderBy(o => o.DisplayOrder)
                            .Select(o => new QuestionOptionDto
                            {
                                Id = o.Id,
                                OptionText = o.OptionText,
                                DisplayOrder = o.DisplayOrder
                            }).ToList()
                    }).ToList()
            };

            return Ok(dto);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Maç oturumu yüklenirken bir hata oluştu" });
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
            return StatusCode(500, new { message = "Maç geçmişi yüklenirken bir hata oluştu" });
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
            return StatusCode(500, new { message = "Maç istatistikleri yüklenirken bir hata oluştu" });
        }
    }

    // ── Yarış Davetleri ──────────────────────────────────────────────────────

    /// <summary>Arkadaşa yarış daveti gönderir.</summary>
    [HttpPost("invite")]
    public async Task<IActionResult> SendInvite([FromBody] SendMatchInviteDto request)
    {
        try
        {
            var dto = await _matchInvitationService.SendInviteAsync(
                request.InviterId, request.InviteeId, request.SubjectId);
            return Ok(dto);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    /// <summary>Yarış davetini kabul veya reddeder.</summary>
    [HttpPut("invite/{id}/respond")]
    public async Task<IActionResult> RespondInvite(Guid id, [FromBody] RespondMatchInviteDto request)
    {
        try
        {
            var dto = await _matchInvitationService.RespondAsync(id, request.InviteeId, request.Accept);
            return Ok(dto);
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    /// <summary>Invitee'nin bekleyen davetlerini listeler.</summary>
    [HttpGet("invites/pending")]
    public async Task<IActionResult> GetPendingInvites([FromQuery] Guid inviteeId)
    {
        try
        {
            var list = await _matchInvitationService.GetPendingForInviteeAsync(inviteeId);
            return Ok(list);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    /// <summary>Inviter'ın gönderdiği bekleyen davetleri listeler.</summary>
    [HttpGet("invites/sent-pending")]
    public async Task<IActionResult> GetSentPendingInvites([FromQuery] Guid inviterId)
    {
        try
        {
            var list = await _matchInvitationService.GetPendingForInviterAsync(inviterId);
            return Ok(list);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    /// <summary>Inviter kendi g\u00f6nderdi\u011fi daveti iptal eder.</summary>
    [HttpDelete("invite/{id}")]
    public async Task<IActionResult> CancelInvite(Guid id, [FromQuery] Guid inviterId)
    {
        try
        {
            await _matchInvitationService.CancelAsync(id, inviterId);
            return NoContent();
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }
}

public class RequestMatchDto
{
    public Guid ChildId { get; set; }
    public Guid? SubjectId { get; set; }
}

