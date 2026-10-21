import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'palette.dart';
import 'shapes.dart';

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
  // Large titles in the iOS manner: big, bold, a little tight.
  displaySmall: _roboto(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: c,
    letterSpacing: -0.6,
  ),
  headlineLarge: _roboto(fontSize: 32, fontWeight: FontWeight.w700, color: c),
  headlineMedium: _roboto(fontSize: 28, fontWeight: FontWeight.w600, color: c),
  headlineSmall: _roboto(fontSize: 24, fontWeight: FontWeight.w600, color: c),
  titleLarge: _roboto(fontSize: 22, fontWeight: FontWeight.w600, color: c),
  titleMedium: _roboto(
    fontSize: 16,
    fontWeight: FontWeight.w600,
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
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusSheet)),
      ),
    ),
    // Buttons are pills, flat, like the prominent buttons of iOS.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: const StadiumBorder(),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: const StadiumBorder()),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        side: BorderSide(color: colors.border),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        side: const WidgetStatePropertyAll(BorderSide.none),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.strong
              : colors.fill,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.onStrong
              : colors.muted,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colors.strong,
      contentTextStyle: TextStyle(
        fontFamily: _fontFamily,
        color: colors.onStrong,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusControl),
      ),
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
