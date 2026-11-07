import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _Merek {
  static const merah = Color(0xFFE62727);
  static const krem = Color(0xFFF3F2EC);
  static const abu = Color(0xFFDCDCDC);
  static const teal = Color(0xFF1E93AB);
}

ThemeData _bangunTema(Brightness kecerahan) {
  final merah = ColorScheme.fromSeed(
    seedColor: _Merek.merah,
    brightness: kecerahan,
  );
  final teal = ColorScheme.fromSeed(
    seedColor: _Merek.teal,
    brightness: kecerahan,
  );

  var skema = merah.copyWith(
    secondary: teal.primary,
    onSecondary: teal.onPrimary,
    secondaryContainer: teal.primaryContainer,
    onSecondaryContainer: teal.onPrimaryContainer,
  );

  if (kecerahan == Brightness.light) {
    skema = skema.copyWith(
      surface: _Merek.krem,
      outlineVariant: _Merek.abu,
    );
  }

  final dasar = ThemeData(
    useMaterial3: true,
    colorScheme: skema,
    brightness: kecerahan,
  );

  return dasar.copyWith(
    scaffoldBackgroundColor: skema.surface,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(dasar.textTheme),
    cardTheme: CardThemeData(
      elevation: 0,
      color: skema.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: skema.outlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

final ThemeData temaTerang = _bangunTema(Brightness.light);
final ThemeData temaGelap = _bangunTema(Brightness.dark);