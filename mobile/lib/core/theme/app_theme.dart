import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF345995),
        brightness: Brightness.light,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF8CB4FF),
        brightness: Brightness.dark,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      );
}
