import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light({double textScale = 1.0}) {
    return _build(
      brightness: Brightness.light,
      primary: const Color(0xFF28664A),
      surface: const Color(0xFFFFFFFF),
      background: const Color(0xFFF7F8F4),
      textScale: textScale,
    );
  }

  static ThemeData dark({double textScale = 1.0}) {
    return _build(
      brightness: Brightness.dark,
      primary: const Color(0xFF88BD98),
      surface: const Color(0xFF202D24),
      background: const Color(0xFF17221B),
      textScale: textScale,
    );
  }

  static const _baseTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57),
    displayMedium: TextStyle(fontSize: 45),
    displaySmall: TextStyle(fontSize: 36),
    headlineLarge: TextStyle(fontSize: 32),
    headlineMedium: TextStyle(fontSize: 28),
    headlineSmall: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
    bodySmall: TextStyle(fontSize: 13, height: 1.45),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.88,
    ),
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color surface,
    required Color background,
    required double textScale,
  }) {
    final colors = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(surface: surface);

    final safeTextScale = textScale.clamp(0.85, 1.5).toDouble();
    final textTheme = _baseTextTheme.apply(
      bodyColor: colors.onSurface,
      displayColor: colors.onSurface,
      fontSizeFactor: safeTextScale,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        titleTextStyle: textTheme.titleLarge,
      ),
    );
  }
}
