import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'palette.dart';

/// Roboto is bundled with the app (assets/fonts), so text renders correctly
/// offline and without a first-run download.
const _fontFamily = 'Roboto';

TextStyle _roboto({
  required double fontSize,
  required FontWeight fontWeight,
  required Color color,
  double? letterSpacing,
}) => TextStyle(
  fontFamily: _fontFamily,
  fontSize: fontSize,
  fontWeight: fontWeight,
  color: color,
  letterSpacing: letterSpacing,
);

TextTheme _textTheme(Color c) => TextTheme(
  displaySmall: _roboto(fontSize: 36, fontWeight: FontWeight.w400, color: c),
  headlineLarge: _roboto(fontSize: 32, fontWeight: FontWeight.w400, color: c),
  headlineMedium: _roboto(fontSize: 28, fontWeight: FontWeight.w400, color: c),
  headlineSmall: _roboto(fontSize: 24, fontWeight: FontWeight.w400, color: c),
  titleLarge: _roboto(fontSize: 22, fontWeight: FontWeight.w400, color: c),
  titleMedium: _roboto(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: c,
    letterSpacing: 0.15,
  ),
  titleSmall: _roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: c,
    letterSpacing: 0.1,
  ),
  labelLarge: _roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: c,
    letterSpacing: 0.1,
  ),
  labelMedium: _roboto(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: c,
    letterSpacing: 0.5,
  ),
  labelSmall: _roboto(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: c,
    letterSpacing: 0.5,
  ),
  bodyLarge: _roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: c,
    letterSpacing: 0.15,
  ),
  bodyMedium: _roboto(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: c,
    letterSpacing: 0.25,
  ),
  bodySmall: _roboto(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: c,
    letterSpacing: 0.4,
  ),
);

ThemeData _buildTheme(Brightness brightness) {
  final colors = AppColors.of(brightness);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: _fontFamily,
    colorScheme: ColorScheme.fromSeed(seedColor: gray, brightness: brightness),
    scaffoldBackgroundColor: colors.surface,
    canvasColor: colors.surface,
    extensions: [colors],
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: colors.strong,
      unselectedItemColor: colors.subtle,
      backgroundColor: colors.surface,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: _textTheme(colors.strong),
  );
}

final lightTheme = _buildTheme(Brightness.light);
final darkTheme = _buildTheme(Brightness.dark);

/// System bars for a page on the theme's surface colour: transparent bars (so
/// the page colour shows through the status bar) with icons that contrast
/// with it, and a navigation bar that matches the bottom navigation bar.
SystemUiOverlayStyle pageOverlayStyle(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
    statusBarBrightness: dark ? Brightness.dark : Brightness.light, // iOS
    systemNavigationBarColor: AppColors.of(brightness).surface,
    systemNavigationBarIconBrightness: dark
        ? Brightness.light
        : Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
    systemStatusBarContrastEnforced: false,
  );
}

/// System bars for pages with a type-coloured background and white content
/// (the Pokémon detail page): the status bar always gets light icons.
SystemUiOverlayStyle coloredPageOverlayStyle(Brightness brightness) =>
    pageOverlayStyle(brightness).copyWith(
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    );
