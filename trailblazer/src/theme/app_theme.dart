import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _lightGreen = Color(0xFF28664A);
  static const _darkGreen = Color(0xFF88BD98);

  static final ThemeData light = _buildTheme(
    brightness: Brightness.light,
    seed: _lightGreen,
    scaffold: const Color(0xFFF7F8F4),
    surface: const Color(0xFFFFFFFF),
    foreground: const Color(0xFF202B24),
  );

  static final ThemeData dark = _buildTheme(
    brightness: Brightness.dark,
    seed: _darkGreen,
    scaffold: const Color(0xFF17221B),
    surface: const Color(0xFF202D24),
    foreground: const Color(0xFFEDF3EE),
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color seed,
    required Color scaffold,
    required Color surface,
    required Color foreground,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffold,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: foreground,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: brightness == Brightness.light
            ? const Color(0xFFDFEADF)
            : const Color(0xFF24382A),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.primary,
        textColor: foreground,
      ),
    );
  }
}
