import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/theme/contrast.dart';
import 'package:pokeflutter/core/pokemon_constants.dart';

double _ratio(Color a, Color b) {
  final l1 = a.computeLuminance(), l2 = b.computeLuminance();
  return ((l1 > l2 ? l1 : l2) + 0.05) / ((l1 > l2 ? l2 : l1) + 0.05);
}

void main() {
  const darkSurface = Color(0xFF12161D);
  const lightSurface = Color(0xFFFFFFFF);

  test('colours that already contrast are left alone', () {
    const green = Color(0xFF38BF4B);
    expect(ensureContrast(green, darkSurface), green);
    expect(
      ensureContrast(const Color(0xFF283141), lightSurface),
      const Color(0xFF283141),
    );
  });

  test('every type colour becomes readable on both surfaces', () {
    for (final color in listPokemonTypeColor.values) {
      expect(
        _ratio(ensureContrast(color, darkSurface), darkSurface),
        greaterThanOrEqualTo(3),
      );
      expect(
        _ratio(ensureContrast(color, lightSurface), lightSurface),
        greaterThanOrEqualTo(3),
      );
    }
  });

  test('only the lightness changes', () {
    const dark = Color(0xFF5B5466); // dark type, too dim on a dark surface
    final adjusted = ensureContrast(dark, darkSurface);

    expect(adjusted, isNot(dark));
    expect(
      HSLColor.fromColor(adjusted).hue,
      closeTo(HSLColor.fromColor(dark).hue, 6),
    );
    expect(
      HSLColor.fromColor(adjusted).lightness,
      greaterThan(HSLColor.fromColor(dark).lightness),
    );
  });
}
