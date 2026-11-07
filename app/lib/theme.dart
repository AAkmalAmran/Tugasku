import 'package:flutter/material.dart';

/// Brand colors. May ONLY be used in this file.
class _Brand {
  static const red = Color(0xFFE62727);
  static const cream = Color(0xFFF3F2EC);
  static const gray = Color(0xFFDCDCDC);
  static const teal = Color(0xFF1E93AB);
}

ThemeData _buildTheme(Brightness brightness) {
  final redScheme = ColorScheme.fromSeed(
    seedColor: _Brand.red,
    brightness: brightness,
  );
  final tealScheme = ColorScheme.fromSeed(
    seedColor: _Brand.teal,
    brightness: brightness,
  );

  var scheme = redScheme.copyWith(
    secondary: tealScheme.primary,
    onSecondary: tealScheme.onPrimary,
    secondaryContainer: tealScheme.primaryContainer,
    onSecondaryContainer: tealScheme.onPrimaryContainer,
  );

  if (brightness == Brightness.light) {
    scheme = scheme.copyWith(
      surface: _Brand.cream,
      outlineVariant: _Brand.gray,
    );
  }

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: brightness,
    fontFamily: 'PlusJakartaSans',
  );

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

final ThemeData lightTheme = _buildTheme(Brightness.light);
final ThemeData darkTheme = _buildTheme(Brightness.dark);