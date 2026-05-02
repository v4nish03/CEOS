import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de Colores Principal
  static const Color primary = Color(0xFF1A535C); // Verde Petróleo
  static const Color secondary = Color(0xFF4ECDC4); // Turquesa
  static const Color background = Color(0xFFF7FFF7); // Blanco Menta
  static const Color accent = Color(0xFFFF6B6B); // Coral (Alertas/Error)
  static const Color warning = Color(0xFFFFE66D); // Amarillo (Pendientes)
  static const Color success = Color(0xFF2ECC71); // Verde Esmeralda (Aprobados)

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: background,
        error: accent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1A1A1A), // Texto casi negro
      ),
      
      // Configuración de Tipografía
      // Nota: Asegúrate de agregar Poppins y Roboto en tu pubspec.yaml
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          color: Color(0xFF1A1A1A),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: Color(0xFF4A4A4A),
        ),
      ),

      // Estilo de los Inputs (Formularios)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(color: primary),
      ),

      // Estilo de los Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // Estilo de las Cards (Inventario)
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // AppBar personalizada
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}