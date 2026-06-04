/// API Configuration
class ApiConstants {
  ApiConstants._();

  // Base URLs
  static const String baseUrl = 'https://minibilge-api-465589060611.us-central1.run.app/api';
  
  // For iOS Simulator, use:
  //static const String baseUrl = 'http://127.0.0.1:5077/api';
  
  // For Android Emulator, use:
  // static const String baseUrl = 'http://10.0.2.2:5077/api';
  
  // For real device, use your machine's IP:
  // static const String baseUrl = 'http://192.168.1.x:5077/api';

  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Endpoints
  static const String auth = '/auth';
  static const String childProfile = '/childprofile';
  
  // Auth endpoints
  static const String register = '$auth/register';
  static const String login = '$auth/login';
  static const String refresh = '$auth/refresh';
  static const String logout = '$auth/logout';
}

/// Storage Keys
class StorageKeys {
  StorageKeys._();

  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
}

/// App Constants
class AppConstants {
  AppConstants._();

  static const String appName = 'MiniBilge';
  static const String appVersion = '1.0.0';
  
  // Grade levels
  static const Map<int, String> gradeLevels = {
    0: 'Okul Öncesi',
    1: '1. Sınıf',
    2: '2. Sınıf',
    3: '3. Sınıf',
    4: '4. Sınıf',
  };
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 100;
  static const int phoneNumberLength = 10;
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

/// Regular Expressions
class RegexPatterns {
  RegexPatterns._();

  static final RegExp email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp password = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$',
  );
  
  static final RegExp phone = RegExp(r'^[0-9]{10}$');
  
  static final RegExp name = RegExp(r"^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]+$");
}
