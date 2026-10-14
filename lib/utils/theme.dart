import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'palette.dart';

/// Roboto is bundled with the app (assets/fonts), so text renders correctly
/// offline and without a first-run download.
const _fontFamily = 'Roboto';

TextStyle _roboto({
  required double fontSize,
  required FontWeight fontWeight,
  Color? color,
  double? letterSpacing,
}) => TextStyle(
  fontFamily: _fontFamily,
  fontSize: fontSize,
  fontWeight: fontWeight,
  color: color,
  letterSpacing: letterSpacing,
);

/// Background of every regular page. The status bar is drawn over it
/// (edge-to-edge), so [pageOverlayStyle] keeps the two in sync.
const pageBackground = Colors.white;

/// System bars for pages on [pageBackground]: transparent bars (so the page
/// colour shows through) with dark icons, and a navigation bar that matches
/// the bottom navigation bar.
const pageOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light, // iOS
  systemNavigationBarColor: Colors.white,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarDividerColor: Colors.transparent,
  systemNavigationBarContrastEnforced: false,
  systemStatusBarContrastEnforced: false,
);

/// System bars for pages with a coloured background and white content
/// (the Pokémon detail page).
final coloredPageOverlayStyle = pageOverlayStyle.copyWith(
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);

final pokeFlutterTheme = ThemeData(
  useMaterial3: true,
  fontFamily: _fontFamily,
  scaffoldBackgroundColor: pageBackground,
  colorScheme: ColorScheme.fromSeed(seedColor: gray),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: gray[500],
    unselectedItemColor: gray[300],
    backgroundColor: Colors.white,
  ),
  textTheme: TextTheme(
    displaySmall: _roboto(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: gray[500],
    ),
    titleLarge: _roboto(fontSize: 22, fontWeight: FontWeight.w400, color: gray),
    titleMedium: _roboto(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: gray,
      letterSpacing: 0.15,
    ),
    titleSmall: _roboto(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: gray[500],
      letterSpacing: 0.1,
    ),
    headlineLarge: _roboto(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: gray,
    ),
    headlineMedium: _roboto(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: gray,
    ),
    headlineSmall: _roboto(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: gray,
    ),
    labelLarge: _roboto(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: gray,
      letterSpacing: 0.1,
    ),
    labelMedium: _roboto(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: gray,
      letterSpacing: 0.5,
    ),
    labelSmall: _roboto(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: gray,
      letterSpacing: 0.5,
    ),
    bodyLarge: _roboto(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: gray,
      letterSpacing: 0.15,
    ),
    bodyMedium: _roboto(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: gray,
      letterSpacing: 0.25,
    ),
    bodySmall: _roboto(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: gray,
      letterSpacing: 0.4,
    ),
  ),
);
