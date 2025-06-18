import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Neon renkler
  static const Color neonTurquoise = Color(0xFF00E5FF);
  static const Color neonPurple = Color(0xFF9C27B0);
  static const Color neonOrange = Color(0xFFFF6D00);

  // Karanlık tonlar
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color cardBackground = Color(0xFF1A1A1A);
  static const Color surfaceColor = Color(0xFF2A2A2A);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme.copyWith(
          titleLarge: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineSmall: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: neonTurquoise,
          ),
          titleSmall: const TextStyle(fontSize: 15, color: Colors.white),
          bodyMedium: const TextStyle(fontSize: 15, color: Colors.white),
          bodySmall: const TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonTurquoise,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: neonTurquoise,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
