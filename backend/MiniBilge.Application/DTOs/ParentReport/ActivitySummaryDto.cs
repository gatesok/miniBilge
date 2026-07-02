namespace MiniBilge.Application.DTOs.ParentReport;

public class ActivitySummaryDto
{
    public Guid ChildId { get; set; }
    public int PodcastsCompleted { get; set; }
    public int ChallengesTotal { get; set; }
    public int ChallengesWon { get; set; }
    public int ChallengesLost { get; set; }
    public int AssignmentsCompleted { get; set; }
}
