import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Theme Colors
  static const Color darkNavy = Color(0xFF0B0C1E);
  static const Color cardNavy = Color(0xFF14152C);
  static const Color cardNavyLight = Color(0xFF1E2042);
  
  static const Color neonPurple = Color(0xFF9D4EDD);
  static const Color deepPurple = Color(0xFF6B1D9F);
  static const Color neonPink = Color(0xFFE01E79);
  static const Color neonBlue = Color(0xFF4EA8DE);
  
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFF8B8C9E);
  static const Color textMuted = Color(0xFF5B5C6E);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [deepPurple, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [neonPink, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x1AFFFFFF),
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [
      Color(0xFF080918),
      Color(0xFF12132A),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: neonPurple,
      scaffoldBackgroundColor: darkNavy,
      cardColor: cardNavy,
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: textWhite),
          displayMedium: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: textWhite),
          titleLarge: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: textWhite),
          bodyLarge: GoogleFonts.outfit(fontSize: 16, color: textWhite),
          bodyMedium: GoogleFonts.outfit(fontSize: 14, color: textGrey),
          labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: textWhite),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: neonPurple,
        secondary: neonPink,
        background: darkNavy,
        surface: cardNavy,
        onPrimary: textWhite,
        onSecondary: textWhite,
      ),
      useMaterial3: true,
    );
  }
}
