enum EnglishLevel {
  a1(1, 'A1 - Başlangıç'),
  a2(2, 'A2 - Temel'),
  b1(3, 'B1 - Orta Altı'),
  b2(4, 'B2 - Orta'),
  c1(5, 'C1 - Orta Üstü'),
  c2(6, 'C2 - Ustalık');

  final int value;
  final String displayName;

  const EnglishLevel(this.value, this.displayName);

  static EnglishLevel? fromValue(int? value) {
    if (value == null) return null;
    return EnglishLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EnglishLevel.a1,
    );
  }

  static EnglishLevel? fromString(String? str) {
    if (str == null) return null;
    switch (str.toLowerCase()) {
      case 'a1 - başlangıç':
      case 'a1':
        return EnglishLevel.a1;
      case 'a2 - temel':
      case 'a2':
        return EnglishLevel.a2;
      case 'b1 - orta altı':
      case 'b1':
        return EnglishLevel.b1;
      case 'b2 - orta':
      case 'b2':
        return EnglishLevel.b2;
      case 'c1 - orta üstü':
      case 'c1':
        return EnglishLevel.c1;
      case 'c2 - ustalık':
      case 'c2':
        return EnglishLevel.c2;
      default:
        return null;
    }
  }
}
