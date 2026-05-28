import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppWideTheme {
  static const Color primaryColour = Color(0xFFFFCC8C);
  static const Color secondaryColour = Color(0xFF3D426B);
  static const Color successColour = Color(0xFF34D399);
  static const Color warningColour = Color(0xFFFBBF24);
  static const Color errorColour = Color(0xFFEF4444);
  static const Color backgroundColour = Color(0xFFFAFAFB);
  static const Color surfaceColour = Color(
      0xFFFFFFFF); //basically background of ui components that sits on top of the background

  static const Color textPrimary = Color(0xFF2E2E2E);   // dark grey
  static const Color textSecondary = Color(0xFF5F5F5F);// lighter grey

  static ThemeData lightTheme = ThemeData(
    //more modern look for our app using version 3
    useMaterial3: true,
    primaryColor: primaryColour,
    scaffoldBackgroundColor: backgroundColour,

    //using colourscheme so flutter can automatically set a consistem theme throughout our app
    colorScheme: const ColorScheme.light(
      primary: primaryColour,
      secondary: secondaryColour,
      error: errorColour,
      surface: surfaceColour,
    ),

    textTheme: GoogleFonts.interTextTheme().copyWith(
      bodyLarge: const TextStyle(color: textPrimary),
      bodyMedium: const TextStyle(color: textPrimary),
      bodySmall: const TextStyle(color: textSecondary),
      titleLarge: const TextStyle(color: textPrimary),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor:
          primaryColour, //the background colour of our app bar will be the primary colour
      foregroundColor: Colors.black87,
      centerTitle: true,
      elevation: 2,
    ),

    cardTheme: CardThemeData(
      color: surfaceColour,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),

    //new flutter buttontheme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColour,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColour,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),

      //when the border of the input field is inactive
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColour),
      ),

      //when the border of the input field is active/clicked on
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    ),
  );
}
