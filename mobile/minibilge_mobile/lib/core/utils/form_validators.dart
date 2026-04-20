import '../../../core/constants/app_constants.dart';

class FormValidators {
  FormValidators._();

  /// Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email adresi gereklidir';
    }
    
    if (!RegexPatterns.email.hasMatch(value)) {
      return 'Geçerli bir email adresi giriniz';
    }
    
    return null;
  }

  /// Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gereklidir';
    }
    
    if (!RegexPatterns.password.hasMatch(value)) {
      return 'Şifre en az 8 karakter, 1 büyük harf, 1 küçük harf ve 1 rakam içermelidir';
    }
    
    return null;
  }

  /// Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gereklidir';
    }
    
    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }
    
    return null;
  }

  /// Name validation
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gereklidir';
    }
    
    if (value.length < 2) {
      return '$fieldName en az 2 karakter olmalıdır';
    }
    
    return null;
  }

  /// Phone validation (optional)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    if (!RegexPatterns.phone.hasMatch(value)) {
      return 'Geçerli bir telefon numarası giriniz';
    }
    
    return null;
  }
}
