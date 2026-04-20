import 'package:flutter/material.dart';

/// App color palette supporting both light and dark themes
class AppColors {
  // Primary colors - Light theme
  static const Color primaryLight = Color(0xFF6C63FF);
  static const Color primaryLightVariant = Color(0xFF9C96FF);
  static const Color primaryDark = Color(0xFF3D35CC);
  
  // Primary colors - Dark theme
  static const Color primaryDarkTheme = Color(0xFF8B83FF);
  static const Color primaryDarkVariant = Color(0xFFB0AAFF);
  
  // Secondary colors - Light theme
  static const Color secondaryLight = Color(0xFFFF6584);
  static const Color secondaryLightVariant = Color(0xFFFF96AD);
  
  // Secondary colors - Dark theme
  static const Color secondaryDarkTheme = Color(0xFFFF7A9A);
  static const Color secondaryDarkVariant = Color(0xFFFFAABF);
  
  // Background colors - Light theme
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  
  // Background colors - Dark theme
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2C2C2C);
  
  // Text colors - Light theme
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textDisabledLight = Color(0xFF9CA3AF);
  
  // Text colors - Dark theme
  static const Color textPrimaryDark = Color(0xFFE5E5E5);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF707070);
  
  // Status colors (same for both themes but with opacity variations)
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Game colors (consistent across themes)
  static const Color coin = Color(0xFFFFD700);
  static const Color star = Color(0xFFFFA500);
  static const Color diamond = Color(0xFF00D9FF);
  
  // Gradient colors for buttons and cards
  static const List<Color> primaryGradientLight = [
    Color(0xFF6C63FF),
    Color(0xFF9C96FF),
  ];
  
  static const List<Color> primaryGradientDark = [
    Color(0xFF8B83FF),
    Color(0xFFB0AAFF),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFFFF6584),
    Color(0xFFFF96AD),
  ];
  
  // Shadow colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
  
  // Divider colors
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF374151);
}
