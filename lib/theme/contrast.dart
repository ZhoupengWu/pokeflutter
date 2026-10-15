import 'package:flutter/painting.dart';

double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

/// Returns [color] adjusted, if needed, so it stands out against
/// [background] with at least [minRatio] contrast (3 is the WCAG minimum for
/// large text and UI elements). The hue is kept; only the lightness moves, away
/// from the background.
Color ensureContrast(Color color, Color background, {double minRatio = 3}) {
  if (_contrastRatio(color, background) >= minRatio) return color;

  final hsl = HSLColor.fromColor(color);
  final towardsLight = background.computeLuminance() < 0.5;
  var lightness = hsl.lightness;
  var candidate = color;
  while (_contrastRatio(candidate, background) < minRatio) {
    lightness += towardsLight ? 0.03 : -0.03;
    if (lightness <= 0 || lightness >= 1) break;
    candidate = hsl.withLightness(lightness).toColor();
  }
  return candidate;
}
