import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/l10n/l10n_extensions.dart';
import 'package:pokeflutter/utils/pokemon_constants.dart';

void main() {
  test('both languages translate the same keys', () {
    // gen-l10n would already fail on a missing key; this guards the types
    // used for the Pokémon names, which are looked up by id at runtime.
    final en = lookupAppLocalizations(const Locale('en'));
    final it = lookupAppLocalizations(const Locale('it'));
    for (final type in listPokemonTypeColor.keys) {
      expect(en.typeName(type), isNotEmpty);
      expect(it.typeName(type), isNotEmpty);
    }
    expect(en.typeName('fire'), 'Fire');
    expect(it.typeName('fire'), 'Fuoco');
  });

  test('unknown types fall back to a capitalised id', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(en.typeName('shadow'), 'Shadow');
    expect(en.typeName(''), '');
  });

  test('type lists read naturally', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final it = lookupAppLocalizations(const Locale('it'));
    expect(en.typeList(['fire', 'flying']), 'Fire and Flying');
    expect(it.typeList(['fire', 'flying']), 'Fuoco e Volante');
    expect(en.typeList(['fire']), 'Fire');
  });

  test('plurals and placeholders are filled in', () {
    final it = lookupAppLocalizations(const Locale('it'));
    expect(it.applyCount(3), 'Applica (3)');
    expect(it.pokemonSemantics('Pikachu', 25), 'Pikachu, numero 25');
  });
}
