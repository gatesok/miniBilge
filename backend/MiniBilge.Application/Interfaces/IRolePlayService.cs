using MiniBilge.Application.DTOs.RolePlay;

namespace MiniBilge.Application.Interfaces;

public interface IRolePlayService
{
    Task<List<ScenarioDto>> GetScenariosAsync(string level);
    Task<StartRolePlayResponse> StartSessionAsync(StartRolePlayRequest request);
    Task<SendTurnResponse> SendTurnAsync(SendTurnRequest request);
    Task<EndSessionResponse> EndSessionAsync(EndSessionRequest request);
}
