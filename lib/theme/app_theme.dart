import 'package:flutter/material.dart';

class AppTheme {
  static const ink = Color(0xFF20243A);
  static const muted = Color(0xFF85899B);
  static const violet = Color(0xFF6658D3);
  static const canvas = Color(0xFFF7F7FB);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: violet,
      brightness: Brightness.light,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: canvas,
        hintStyle: const TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: violet, width: 1.4),
        ),
      ),
    );
  }
}
