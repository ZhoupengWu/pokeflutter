import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/model/pokemon.dart';
import 'package:pokeflutter/model/pokemon_move.dart';

import 'support/fixtures.dart';

void main() {
  group('PokemonMove.parseAll', () {
    test('keeps the moves of the newest version group', () {
      final moves = PokemonMove.parseAll([
        moveJson('tackle', [
          ('red-blue', 'level-up', 1),
          ('sword-shield', 'level-up', 1),
          ('scarlet-violet', 'level-up', 1),
        ]),
        moveJson('wing-attack', [
          ('red-blue', 'level-up', 20),
          ('sword-shield', 'level-up', 22),
        ]), // gone in scarlet-violet
        moveJson('flamethrower', [
          ('sword-shield', 'machine', 0),
          ('scarlet-violet', 'machine', 0),
        ]),
      ]);

      expect(moves.map((m) => (m.name, m.method)), [
        ('tackle', MoveMethod.levelUp),
        ('flamethrower', MoveMethod.machine),
      ]);
    });

    test('a Pokémon absent from the newest games shows its last ones', () {
      final moves = PokemonMove.parseAll([
        moveJson('wing-attack', [
          ('red-blue', 'level-up', 20),
          ('sword-shield', 'level-up', 22),
        ]),
      ]);

      expect(moves.single.level, 22);
    });

    test('only level-up moves carry a level', () {
      final moves = PokemonMove.parseAll([
        moveJson('ember', [('scarlet-violet', 'level-up', 9)]),
        moveJson('dragon-dance', [('scarlet-violet', 'egg', 7)]),
      ]);

      expect(moves.map((m) => m.level), [9, 0]);
    });

    test('a move learned in two ways is listed for both', () {
      final moves = PokemonMove.parseAll([
        moveJson('ember', [
          ('scarlet-violet', 'level-up', 9),
          ('scarlet-violet', 'tutor', 0),
        ]),
      ]);

      expect(moves.map((m) => m.method), [
        MoveMethod.levelUp,
        MoveMethod.tutor,
      ]);
    });

    test('ignores learn methods the app does not show', () {
      final moves = PokemonMove.parseAll([
        moveJson('thunderbolt', [
          ('scarlet-violet', 'stadium-surfing-pikachu', 0),
        ]),
      ]);

      expect(moves, isEmpty);
    });

    test('version groups it does not know give no moves', () {
      expect(
        PokemonMove.parseAll([
          moveJson('tackle', [('brand-new-games', 'level-up', 1)]),
        ]),
        isEmpty,
      );
      expect(PokemonMove.parseAll(const []), isEmpty);
    });
  });

  group('Pokemon moves', () {
    test('are read from the API response', () {
      final p = Pokemon.fromJson(
        pokemonJson(
          moves: [
            moveJson('ember', [('scarlet-violet', 'level-up', 9)]),
          ],
        ),
      );

      expect(p.moves!.single.name, 'ember');
    });

    test('a response without moves has an empty list', () {
      expect(Pokemon.fromJson(pokemonJson()).moves, isEmpty);
    });

    test('survive the cache round trip', () {
      final original = Pokemon.fromJson(
        pokemonJson(
          moves: [
            moveJson('ember', [('scarlet-violet', 'level-up', 9)]),
            moveJson('fly', [('scarlet-violet', 'machine', 0)]),
          ],
        ),
      );

      final copy = Pokemon.fromCacheJson(original.toCacheJson());

      expect(copy.moves!.map((m) => (m.name, m.method, m.level)), [
        ('ember', MoveMethod.levelUp, 9),
        ('fly', MoveMethod.machine, 0),
      ]);
    });

    test('a copy saved before moves were kept has none (null)', () {
      final json = Pokemon.fromJson(pokemonJson()).toCacheJson()
        ..remove('moves');

      expect(Pokemon.fromCacheJson(json).moves, isNull);
    });
  });
}
