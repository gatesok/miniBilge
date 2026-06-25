using MiniBilge.Application.DTOs.RolePlay;

namespace MiniBilge.Application.Interfaces;

public interface IRolePlayService
{
    List<ScenarioDto> GetScenarios(string level);
    Task<StartRolePlayResponse> StartSessionAsync(StartRolePlayRequest request);
    Task<SendTurnResponse> SendTurnAsync(SendTurnRequest request);
    Task<EndSessionResponse> EndSessionAsync(EndSessionRequest request);
}
