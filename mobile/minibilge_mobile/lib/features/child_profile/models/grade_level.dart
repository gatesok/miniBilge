enum GradeLevel {
  preSchool(0, 'Okul Öncesi'),
  grade1(1, '1. Sınıf'),
  grade2(2, '2. Sınıf'),
  grade3(3, '3. Sınıf'),
  grade4(4, '4. Sınıf'),
  grade5(5, '5. Sınıf'),
  grade6(6, '6. Sınıf'),
  grade7(7, '7. Sınıf'),
  grade8(8, '8. Sınıf'),
  grade9(9, '9. Sınıf'),
  grade10(10, '10. Sınıf'),
  grade11(11, '11. Sınıf'),
  grade12(12, '12. Sınıf'),
  adult(13, 'Yetişkin');

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
      case 'okul öncesi':
        return GradeLevel.preSchool;
      case 'grade1':
      case '1. sınıf':
        return GradeLevel.grade1;
      case 'grade2':
      case '2. sınıf':
        return GradeLevel.grade2;
      case 'grade3':
      case '3. sınıf':
        return GradeLevel.grade3;
      case 'grade4':
      case '4. sınıf':
        return GradeLevel.grade4;
      case 'grade5':
      case '5. sınıf':
        return GradeLevel.grade5;
      case 'grade6':
      case '6. sınıf':
        return GradeLevel.grade6;
      case 'grade7':
      case '7. sınıf':
        return GradeLevel.grade7;
      case 'grade8':
      case '8. sınıf':
        return GradeLevel.grade8;
      case 'grade9':
      case '9. sınıf':
        return GradeLevel.grade9;
      case 'grade10':
      case '10. sınıf':
        return GradeLevel.grade10;
      case 'grade11':
      case '11. sınıf':
        return GradeLevel.grade11;
      case 'grade12':
      case '12. sınıf':
        return GradeLevel.grade12;
      case 'adult':
      case 'yetişkin':
        return GradeLevel.adult;
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
      case GradeLevel.grade5:
        return 'Grade5';
      case GradeLevel.grade6:
        return 'Grade6';
      case GradeLevel.grade7:
        return 'Grade7';
      case GradeLevel.grade8:
        return 'Grade8';
      case GradeLevel.grade9:
        return 'Grade9';
      case GradeLevel.grade10:
        return 'Grade10';
      case GradeLevel.grade11:
        return 'Grade11';
      case GradeLevel.grade12:
        return 'Grade12';
      case GradeLevel.adult:
        return 'Adult';
    }
  }
}
