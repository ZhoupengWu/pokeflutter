import 'package:flutter/material.dart';

/// Semantic colours that change between the light and dark theme.
///
/// Pages ask for a role ("muted text", "card fill") instead of a fixed grey,
/// so a new theme only has to provide another set of values here.
/// Type colours (grid cells, chips) are identical in both themes.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Page background.
  final Color surface;

  /// Fill of cards, inputs and inactive bars.
  final Color fill;

  /// Hairlines, borders and drag handles.
  final Color border;

  /// Placeholder text, hint icons, empty-state illustrations.
  final Color subtle;

  /// Secondary text (descriptions, captions).
  final Color muted;

  /// Primary text and the main accent of buttons.
  final Color strong;

  /// Text/icon colour on top of [strong].
  final Color onStrong;

  const AppColors({
    required this.surface,
    required this.fill,
    required this.border,
    required this.subtle,
    required this.muted,
    required this.strong,
    required this.onStrong,
  });

  static const light = AppColors(
    surface: Colors.white,
    fill: Color(0xFFF2F4F7),
    border: Color(0xFFDFE4EC),
    subtle: Color(0xFF8D9DB9),
    muted: Color(0xFF4E5F7E),
    strong: Color(0xFF283141),
    onStrong: Colors.white,
  );

  static const dark = AppColors(
    surface: Color(0xFF12161D),
    fill: Color(0xFF1D2430),
    border: Color(0xFF2D3748),
    subtle: Color(0xFF7886A0),
    muted: Color(0xFFA6B2C7),
    strong: Color(0xFFE8ECF3),
    onStrong: Color(0xFF12161D),
  );

  /// The colours matching [brightness].
  static AppColors of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  @override
  AppColors copyWith({
    Color? surface,
    Color? fill,
    Color? border,
    Color? subtle,
    Color? muted,
    Color? strong,
    Color? onStrong,
  }) => AppColors(
    surface: surface ?? this.surface,
    fill: fill ?? this.fill,
    border: border ?? this.border,
    subtle: subtle ?? this.subtle,
    muted: muted ?? this.muted,
    strong: strong ?? this.strong,
    onStrong: onStrong ?? this.onStrong,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      surface: Color.lerp(surface, other.surface, t)!,
      fill: Color.lerp(fill, other.fill, t)!,
      border: Color.lerp(border, other.border, t)!,
      subtle: Color.lerp(subtle, other.subtle, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      strong: Color.lerp(strong, other.strong, t)!,
      onStrong: Color.lerp(onStrong, other.onStrong, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  /// The [AppColors] of the current theme (light ones when none is installed,
  /// e.g. in a bare `MaterialApp` inside a widget test).
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ??
      AppColors.of(Theme.of(this).brightness);
}

/// Right answers, winning stats, good scores.
const successGreen = Color(0xFF38BF4B);

/// Wrong answers, losing stats, low scores.
const dangerRed = Color(0xFFE0306A);
