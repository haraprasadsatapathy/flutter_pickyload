// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class AppTheme {
//   static const Color primaryOrange = Color(0xFFF59E0B);
//   static const Color primaryBlue = Color(0xFF1E40AF);
//   static const Color secondaryOrange = Color(0xFFFBBF24);
//   static const Color accentColor = Color(0xFF10B981);
//   static const Color errorColor = Color(0xFFEF4444);
//   static const Color successColor = Color(0xFF22C55E);
//   static const Color warningColor = Color(0xFFF59E0B);

//   static ThemeData lightTheme = ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.light,
//     primaryColor: primaryOrange,
//     scaffoldBackgroundColor: const Color(0xFFF9FAFB),
//     colorScheme: const ColorScheme.light(
//       primary: primaryOrange,
//       secondary: primaryBlue,
//       surface: Colors.white,
//       error: errorColor,
//       onPrimary: Colors.white,
//       onSecondary: Colors.white,
//       onSurface: Color(0xFF111827),
//       onError: Colors.white,
//     ),
//     textTheme: GoogleFonts.poppinsTextTheme().apply(
//       bodyColor: const Color(0xFF111827),
//       displayColor: const Color(0xFF111827),
//     ),
//     appBarTheme: AppBarTheme(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       iconTheme: const IconThemeData(color: Color(0xFF111827)),
//       titleTextStyle: GoogleFonts.poppins(
//         color: const Color(0xFF111827),
//         fontSize: 20,
//         fontWeight: FontWeight.w600,
//       ),
//     ),
//     cardTheme: CardThemeData(
//         color: Colors.white,
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     ),
//     // cardTheme: CardTheme(
//     //   color: Colors.white,
//     //   elevation: 2,
//     //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     // ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: primaryOrange,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         textStyle: GoogleFonts.poppins(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: const Color(0xFFF3F4F6),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: primaryOrange, width: 2),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: errorColor, width: 1),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//     ),
//   );

//   static ThemeData darkTheme = ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.dark,
//     primaryColor: primaryOrange,
//     scaffoldBackgroundColor: const Color(0xFF111827),
//     colorScheme: const ColorScheme.dark(
//       primary: primaryOrange,
//       secondary: primaryBlue,
//       surface: Color(0xFF1F2937),
//       error: errorColor,
//       onPrimary: Colors.white,
//       onSecondary: Colors.white,
//       onSurface: Color(0xFFF9FAFB),
//       onError: Colors.white,
//     ),
//     textTheme: GoogleFonts.poppinsTextTheme().apply(
//       bodyColor: const Color(0xFFF9FAFB),
//       displayColor: const Color(0xFFF9FAFB),
//     ),
//     appBarTheme: AppBarTheme(
//       backgroundColor: const Color(0xFF1F2937),
//       elevation: 0,
//       iconTheme: const IconThemeData(color: Color(0xFFF9FAFB)),
//       titleTextStyle: GoogleFonts.poppins(
//         color: const Color(0xFFF9FAFB),
//         fontSize: 20,
//         fontWeight: FontWeight.w600,
//       ),
//     ),
//     // cardTheme: CardTheme(
//     //   color: const Color(0xFF1F2937),
//     //   elevation: 2,
//     //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     // ),
//     cardTheme: CardThemeData(
//       color:  const Color(0xFF1F2937),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: primaryOrange,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         textStyle: GoogleFonts.poppins(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: const Color(0xFF374151),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: primaryOrange, width: 2),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: errorColor, width: 1),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//     ),
//   );
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary colors - Turquoise/Teal theme
  static const Color primaryTeal = Color(0xFF14B8A6);
  static const Color primaryTurquoise = Color(0xFF06B6D4);
  static const Color secondaryTeal = Color(0xFF2DD4BF);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentBlue = Color(0xFF0891B2);

  // Status colors
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF22C55E);
  static const Color warningColor = Color(0xFFF59E0B);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryTeal,
    scaffoldBackgroundColor: const Color(0xFFF0FDFA), // Light teal background
    colorScheme: const ColorScheme.light(
      primary: primaryTeal,
      secondary: primaryTurquoise,
      surface: Colors.white,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF111827),
      onError: Colors.white,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: const Color(0xFF111827),
      displayColor: const Color(0xFF111827),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF111827)),
      titleTextStyle: GoogleFonts.poppins(
        color: const Color(0xFF111827),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFCCFBF1), // Light teal fill
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryTeal,
    scaffoldBackgroundColor: const Color(0xFF134E4A), // Dark teal background
    colorScheme: const ColorScheme.dark(
      primary: primaryTeal,
      secondary: primaryTurquoise,
      surface: Color(0xFF115E59), // Darker teal surface
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFFF0FDFA),
      onError: Colors.white,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: const Color(0xFFF0FDFA),
      displayColor: const Color(0xFFF0FDFA),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF115E59),
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFFF0FDFA)),
      titleTextStyle: GoogleFonts.poppins(
        color: const Color(0xFFF0FDFA),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF115E59),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0F766E), // Medium teal fill
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  // Gradient for splash/loading screens (like in the image)
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF5EEAD4), // Light turquoise
      Color(0xFF14B8A6), // Teal
      Color(0xFF0D9488), // Darker teal
    ],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2DD4BF), // Bright turquoise
      Color(0xFF14B8A6), // Teal
      Color(0xFF0F766E), // Dark teal
      Color(0xFF134E4A), // Darker teal
    ],
  );
}
