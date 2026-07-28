class ExternalLoginStatus {
  const ExternalLoginStatus({
    required this.hasPassword,
    required this.providers,
  });

  final bool hasPassword;
  final Set<String> providers;

  bool isLinked(String provider) {
    return providers.any(
      (value) => value.toLowerCase() == provider.toLowerCase(),
    );
  }

  factory ExternalLoginStatus.fromJson(Map<String, dynamic> json) {
    final values =
        (json['Providers'] ?? json['providers']) as List<dynamic>? ??
        const <dynamic>[];
    return ExternalLoginStatus(
      hasPassword:
          (json['HasPassword'] ?? json['hasPassword']) as bool? ?? false,
      providers: values.map((value) => value.toString()).toSet(),
    );
  }
}
