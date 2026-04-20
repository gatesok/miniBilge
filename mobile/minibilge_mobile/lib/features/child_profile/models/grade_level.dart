enum GradeLevel {
  preSchool(0, 'Okul Öncesi'),
  grade1(1, '1. Sınıf'),
  grade2(2, '2. Sınıf'),
  grade3(3, '3. Sınıf'),
  grade4(4, '4. Sınıf');

  final int value;
  final String displayName;

  const GradeLevel(this.value, this.displayName);

  static GradeLevel fromValue(int value) {
    return GradeLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GradeLevel.preSchool,
    );
  }

  static GradeLevel? fromString(String? str) {
    if (str == null) return null;
    
    switch (str.toLowerCase()) {
      case 'preschool':
        return GradeLevel.preSchool;
      case 'grade1':
        return GradeLevel.grade1;
      case 'grade2':
        return GradeLevel.grade2;
      case 'grade3':
        return GradeLevel.grade3;
      case 'grade4':
        return GradeLevel.grade4;
      default:
        return null;
    }
  }

  String toBackendString() {
    switch (this) {
      case GradeLevel.preSchool:
        return 'PreSchool';
      case GradeLevel.grade1:
        return 'Grade1';
      case GradeLevel.grade2:
        return 'Grade2';
      case GradeLevel.grade3:
        return 'Grade3';
      case GradeLevel.grade4:
        return 'Grade4';
    }
  }
}
