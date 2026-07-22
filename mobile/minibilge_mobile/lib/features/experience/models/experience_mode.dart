enum ExperienceMode {
  family,
  child,
  adult;

  String get apiValue => switch (this) {
    ExperienceMode.family => 'Family',
    ExperienceMode.child => 'Child',
    ExperienceMode.adult => 'Adult',
  };

  static ExperienceMode fromApi(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'child' => ExperienceMode.child,
      'adult' => ExperienceMode.adult,
      _ => ExperienceMode.family,
    };
  }
}
