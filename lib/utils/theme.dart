import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'palette.dart';

final pokeFlutterTheme = ThemeData(
  primarySwatch: gray,
  textTheme: TextTheme(
    displaySmall: GoogleFonts.roboto(
      fontSize: 36.sp,
      fontWeight: FontWeight.w400,
      color: gray[500]
    ),
    titleLarge: GoogleFonts.roboto(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: gray
    ),
    titleMedium: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: gray,
      letterSpacing: 0.15
    ),
    titleSmall: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: gray[500],
      letterSpacing: 0.1
    ),
    headlineLarge: GoogleFonts.roboto(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: gray
    ),
    headlineMedium: GoogleFonts.roboto(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: gray
    ),
    headlineSmall: GoogleFonts.roboto(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: gray
    ),
    labelMedium: GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: gray,
      letterSpacing: 0.5
    ),
    labelSmall: GoogleFonts.roboto(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: gray,
      letterSpacing: 0.5
    ),
    bodyLarge: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: gray,
      letterSpacing: 0.15
    ),
    bodyMedium: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: gray,
      letterSpacing: 0.25
    ),
    bodySmall: GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: gray,
      letterSpacing: 0.4
    )
  ),
  colorScheme: .fromSeed(seedColor: Colors.deepPurple),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: gray[500],
    unselectedItemColor: gray[300],
    backgroundColor: Colors.white
  )
);