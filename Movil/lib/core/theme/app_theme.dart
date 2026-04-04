import 'package:flutter/material.dart';

class AppTheme {
  static const _black = Color(0xFF111111);
  static const _white = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF6F6F6);
  static const _border = Color(0xFFE5E5E5);
  static const _muted = Color(0xFF6B6B6B);

  static ThemeData get light {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: _black,
      onPrimary: _white,
      secondary: const Color(0xFF2B2B2B),
      onSecondary: _white,
      error: const Color(0xFFB00020),
      onError: _white,
      surface: _white,
      onSurface: _black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _surface,
      dividerColor: _border,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: _surface,
        foregroundColor: _black,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _black),
      ),
      cardTheme: CardThemeData(
        color: _white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _white,
        hintStyle: const TextStyle(color: _muted),
        labelStyle: const TextStyle(color: _muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _black, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _black,
          foregroundColor: _white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: _border),
        backgroundColor: _white,
        selectedColor: _black,
        labelStyle: const TextStyle(color: _black, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.black, brightness: Brightness.dark);
    return ThemeData(useMaterial3: true, colorScheme: scheme);
  }
}
