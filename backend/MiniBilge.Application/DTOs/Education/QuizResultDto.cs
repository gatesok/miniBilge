namespace MiniBilge.Application.DTOs.Education;

public class QuizResultDto
{
    public int TotalQuestions { get; set; }
    public int CorrectAnswers { get; set; }
    public int WrongAnswers { get; set; }
    public double SuccessPercentage { get; set; }
    public int EarnedCoins { get; set; }
    public int EarnedStars { get; set; }
    public bool IsPassed { get; set; }
}
