using MiniBilge.Application.DTOs.Premium;

namespace MiniBilge.Application.Interfaces.Services;

/// <summary>
/// App Store Server Notification (V2) signedPayload'ını JWS x5c zinciri ile
/// Apple Root CA'ya kadar doğrular ve içeriğini çözer.
/// </summary>
public interface IAppStoreNotificationVerifier
{
    AppStoreServerNotification Verify(string signedPayload);
}
