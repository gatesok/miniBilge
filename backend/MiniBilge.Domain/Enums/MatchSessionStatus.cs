namespace MiniBilge.Domain.Enums;

public enum MatchSessionStatus
{
    Created = 0,
    InProgress = 1,
    Completed = 2,
    Abandoned = 3,
    // İki oyuncu da katılmadan hiç başlamayan oturum: rezerve edilen kota iade edilir,
    // geçmiş/sıralama/galibiyet sorgularına dahil edilmez.
    Cancelled = 4
}
