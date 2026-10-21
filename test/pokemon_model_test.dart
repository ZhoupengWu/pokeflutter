import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/model/pokemon.dart';

import 'support/fixtures.dart';

void main() {
  test('parses a complete response', () {
    final p = Pokemon.fromJson(pokemonJson());

    expect(p.id, 6);
    expect(p.name, 'charizard');
    expect(p.urlSprite, 'https://img/sprite.png');
    expect(p.urlImage, 'https://img/artwork.png');
    expect(p.weight, 90.5); // hectograms -> kg
    expect(p.height, 170); // decimetres -> cm
    expect(p.typesList, ['fire', 'flying']);
    expect(p.stats.map((s) => '${s.name}:${s.value}'), ['hp:78', 'attack:84']);
    expect(p.abilities, ['blaze']);
  });

  test('uses the name of the variety, not of its species', () {
    final p = Pokemon.fromJson(
      pokemonJson(name: 'charizard-mega-x', speciesName: 'charizard'),
    );

    expect(p.name, 'charizard-mega-x');
  });

  test('falls back to the sprite when there is no artwork', () {
    final p = Pokemon.fromJson(pokemonJson(artwork: null));

    expect(p.urlImage, 'https://img/sprite.png');
  });

  test('falls back to the home render when there is no official artwork', () {
    final p = Pokemon.fromJson(
      pokemonJson(
        artwork: null,
        sprite: null,
        extraOther: {
          'home': {'front_default': 'https://img/home.png'},
        },
      ),
    );

    expect(p.urlImage, 'https://img/home.png');
    expect(p.urlSprite, 'https://img/home.png');
  });

  test('does not crash when the Pokémon has no images at all', () {
    final p = Pokemon.fromJson(pokemonJson(artwork: null, sprite: null));

    expect(p.urlSprite, isEmpty);
    expect(p.urlImage, isEmpty);
  });

  group('shiny artwork', () {
    test('is read from the official artwork', () {
      final p = Pokemon.fromJson(pokemonJson());

      expect(p.urlShinyImage, 'https://img/shiny.png');
    });

    test('falls back to the home render, then to the shiny sprite', () {
      final home = Pokemon.fromJson(
        pokemonJson(
          shiny: null,
          extraOther: {
            'home': {'front_shiny': 'https://img/home-shiny.png'},
          },
        ),
      );
      expect(home.urlShinyImage, 'https://img/home-shiny.png');

      final json = pokemonJson(shiny: null);
      (json['sprites'] as Map)['front_shiny'] = 'https://img/sprite-shiny.png';
      expect(
        Pokemon.fromJson(json).urlShinyImage,
        'https://img/sprite-shiny.png',
      );
    });

    test('is null when there is none', () {
      expect(Pokemon.fromJson(pokemonJson(shiny: null)).urlShinyImage, isNull);
    });

    test('survives the cache, and old cache entries do not have it', () {
      final p = Pokemon.fromJson(pokemonJson());
      final copy = Pokemon.fromCacheJson(p.toCacheJson());
      expect(copy.urlShinyImage, 'https://img/shiny.png');

      final old = p.toCacheJson()..remove('shinyImage');
      expect(Pokemon.fromCacheJson(old).urlShinyImage, isNull);
    });
  });
}
