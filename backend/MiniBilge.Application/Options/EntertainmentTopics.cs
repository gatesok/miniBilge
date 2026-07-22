namespace MiniBilge.Application.Options;

/// <summary>Eğlence quiz topic tanımları — DB'siz, statik config.</summary>
public sealed record TopicConfig(
    string Label,
    string Emoji,
    string SystemHint,
    IReadOnlyList<string> SubCategories);

public static class EntertainmentTopics
{
    public static readonly IReadOnlyDictionary<string, TopicConfig> All =
        new Dictionary<string, TopicConfig>(StringComparer.OrdinalIgnoreCase)
        {
            ["spor"] = new TopicConfig(
                Label:       "Spor",
                Emoji:       "⚽",
                SystemHint:  "Turkish and world sports, athletes, records, championships, Olympic games",
                SubCategories: [
                    "futbol", "basketbol", "atletizm", "yüzme", "tenis",
                    "türk sporcular", "olimpiyat", "dünya kupası", "formula 1", "voleybol"
                ]),

            ["genel_kultur"] = new TopicConfig(
                Label:       "Genel Kültür",
                Emoji:       "🌍",
                SystemHint:  "History, geography, science, art, Turkish culture and general knowledge",
                SubCategories: [
                    "tarih", "coğrafya", "bilim", "sanat", "edebiyat",
                    "türkiye", "dünya", "keşifler", "icatlar", "ödüller"
                ]),

            ["muzik"] = new TopicConfig(
                Label:       "Müzik",
                Emoji:       "🎵",
                SystemHint:  "Turkish pop, world music, artists, albums, music history and awards",
                SubCategories: [
                    "türk pop", "türk sanat müziği", "rock", "klasik müzik",
                    "sanatçılar", "albümler", "müzik tarihi", "eurovision", "festivaller"
                ]),

            ["sinema"] = new TopicConfig(
                Label:       "Sinema & Dizi",
                Emoji:       "🎬",
                SystemHint:  "Turkish and world movies, series, directors, actors and awards",
                SubCategories: [
                    "türk filmleri", "hollywood", "animasyon", "oscar ödülleri",
                    "yönetmenler", "oyuncular", "türk dizileri", "netflix", "klasik filmler"
                ]),

            ["teknoloji"] = new TopicConfig(
                Label:       "Teknoloji",
                Emoji:       "💻",
                SystemHint:  "Technology, science, inventions, companies and digital world",
                SubCategories: [
                    "sosyal medya", "yazılım", "yapay zeka", "uzay teknolojisi",
                    "akıllı cihazlar", "internet tarihi", "büyük şirketler", "icatlar"
                ]),

            ["sanat"] = new TopicConfig(
                Label:       "Sanat",
                Emoji:       "🎨",
                SystemHint:  "Visual arts, paintings, sculptures, artists, Turkish and world art history",
                SubCategories: [
                    "resim", "heykel", "türk sanatçılar", "dünya sanatçıları",
                    "müzeler", "mimari", "fotoğrafçılık", "sanat akımları"
                ]),

            ["ingilizce"] = new TopicConfig(
                Label: "İngilizce",
                Emoji: "🇬🇧",
                SystemHint: "Adult English vocabulary, grammar, idioms and everyday communication. Write questions and answer choices in English",
                SubCategories: ["vocabulary", "grammar", "idioms", "travel English", "business English"]),

            ["kelime"] = new TopicConfig(
                Label: "Kelime Yarışı",
                Emoji: "🔤",
                SystemHint: "Turkish words, meanings, synonyms, spelling and word puzzles for adults",
                SubCategories: ["kelime anlamı", "eş anlamlılar", "yazım", "deyimler", "kelime kökeni"]),
        };

    /// <summary>Tüm topic key listesi.</summary>
    public static IReadOnlyList<string> Keys =>
        All.Keys.ToList();
}
