import 'package:flutter/material.dart';

class AppTheme {
  // CEOS tiene un logo sobrio (letras negras sobre blanco). La app toma esa
  // base editorial y agrega acentos clínicos suaves para estados y acciones.
  static const Color ink = Color(0xFF111111);
  static const Color graphite = Color(0xFF2F3437);
  static const Color slate = Color(0xFF667085);
  static const Color porcelain = Color(0xFFF7F8FA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE4E7EC);
  static const Color clinicalTeal = Color(0xFF0F766E);
  static const Color softTeal = Color(0xFFE6F4F1);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: clinicalTeal,
      brightness: Brightness.light,
      primary: ink,
      secondary: clinicalTeal,
      surface: card,
      error: danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: ink,
        onPrimary: Colors.white,
        secondary: clinicalTeal,
        onSecondary: Colors.white,
        surface: card,
        onSurface: ink,
        error: danger,
      ),
      scaffoldBackgroundColor: porcelain,
      dividerColor: border,
      cardColor: card,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.6),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.3),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ink),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ink),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: graphite),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: slate),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: porcelain,
        foregroundColor: ink,
        surfaceTintColor: porcelain,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: ink, width: 1.6)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: danger)),
        labelStyle: const TextStyle(color: slate, fontWeight: FontWeight.w600),
        prefixIconColor: slate,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: card,
        indicatorColor: softTeal,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
            color: states.contains(WidgetState.selected) ? ink : slate,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(color: states.contains(WidgetState.selected) ? clinicalTeal : slate),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
