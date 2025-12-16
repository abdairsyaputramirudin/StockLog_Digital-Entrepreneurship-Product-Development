import 'package:flutter/material.dart';

class AppTheme {
  static const Color blue = Color(0xFF0B57FF);
  static const Color bg = Color(0xFFF2F2F2);
  static const Color card = Colors.white;
  static const Color soft = Color(0xFFE9EEF9);
  static const Color border = Color(0xFFE5E5E5);

  static ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
    );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        headlineSmall:
            const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        bodyMedium: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        hintStyle:
            const TextStyle(color: Colors.black38, fontWeight: FontWeight.w600),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(blue),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          padding:
              WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: border),
        ),
      ),
    );
  }
}
