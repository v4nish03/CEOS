import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Color(0xFF1E1E1E);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light).copyWith(
      primary: const Color(0xFF111111),
      secondary: const Color(0xFF3A3A3A),
      surface: Colors.white,
      onSurface: const Color(0xFF111111),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark).copyWith(
      primary: Colors.white,
      secondary: const Color(0xFFB0B0B0),
    );
    return ThemeData(useMaterial3: true, colorScheme: scheme);
  }
}
