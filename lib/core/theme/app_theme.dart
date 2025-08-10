import 'package:flutter/material.dart';

/// Tema aplikasi SiSantri dengan desain Material 3
class AppTheme {
  // Warna utama aplikasi (hijau islami)
  static const Color primaryColor = Color(0xFF1B5E20);
  static const Color primaryVariant = Color(0xFF2E7D32);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color surfaceColor = Color(0xFFF5F5F5);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFD32F2F);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: primaryColor,
            brightness: Brightness.light,
          ).copyWith(
            primary: primaryColor,
            secondary: secondaryColor,
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: const Color(0xFF2E2E2E),
          ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),

      // Card theme - minimalis tanpa shadow
      cardTheme: const CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),

      // AppBar theme - clean minimalis
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF2E2E2E),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E2E2E),
        ),
      ),

      // Bottom navigation theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Color(0xFF9CA3AF),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Elevated button theme - flat minimalis
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input decoration theme - minimalis
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Dialog theme - clean tanpa shadow
      dialogTheme: const DialogThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Floating action button - minimalis
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),
    );
  }
}
