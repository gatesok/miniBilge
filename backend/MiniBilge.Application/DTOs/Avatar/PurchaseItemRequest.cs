namespace MiniBilge.Application.DTOs.Avatar;

public class PurchaseItemRequest
{
    public Guid ChildProfileId { get; set; }
    public Guid ItemId { get; set; }
}

public class PurchaseItemResponse
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public int RemainingPoints { get; set; }
    public AvatarItemDto? PurchasedItem { get; set; }
}
