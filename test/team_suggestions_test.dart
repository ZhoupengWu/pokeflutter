import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/core/team_suggestions.dart';
import 'package:pokeflutter/model/pokemon_list_item.dart';

PokemonListItem _mon(String name, int id) =>
    PokemonListItem(name: name, url: 'https://pokeapi.co/api/v2/pokemon/$id/');

void main() {
  // name -> types
  final types = {
    'steelix': ['steel', 'ground'],
    'gyarados': ['water', 'flying'],
    'squirtle': ['water'],
    'blastoise': ['water'], // same types as squirtle
    'snorlax': ['normal'],
    'charmander': ['fire'],
    'ferrothorn': ['grass', 'steel'],
  };
  final candidates = [
    _mon('squirtle', 7),
    _mon('blastoise', 9),
    _mon('charmander', 4),
    _mon('snorlax', 143),
    _mon('gyarados', 130),
    _mon('steelix', 208),
    _mon('ferrothorn', 598),
  ];

  List<TeamSuggestion> suggest(
    List<List<String>> team, {
    int limit = 5,
    Iterable<PokemonListItem>? from,
  }) => TeamSuggestions.suggest(
    memberTypes: team,
    candidates: from ?? candidates,
    typesOf: (name) => types[name],
    limit: limit,
  );

  test('an empty team has nothing to suggest', () {
    expect(suggest([]), isEmpty);
  });

  test('suggests a Pokémon that resists what the team is weak to', () {
    // Two fire types: weak to water, ground and rock.
    final result = suggest([
      ['fire'],
      ['fire'],
    ]);

    expect(result, isNotEmpty);
    final top = result.first;
    // A water type resists fire, hits fire and is weak to nothing the team is
    // already weak to... steelix and gyarados help too, but not charmander.
    expect(result.map((s) => s.pokemon.name), isNot(contains('charmander')));
    expect(top.resists, isNotEmpty);
    expect(top.gain, greaterThan(0));
  });

  test('lists the weaknesses it covers and the types it newly hits', () {
    final result = suggest(
      [
        ['fire'],
      ],
      from: [_mon('squirtle', 7)],
    );

    final s = result.single;
    expect(s.resists, ['water']); // fire is weak to water, water resists water
    expect(
      s.newCoverage,
      contains('ground'),
    ); // water hits ground, fire doesn't
    expect(s.types, ['water']);
  });

  test('one suggestion per combination of types, the lowest number', () {
    final result = suggest([
      ['fire'],
      ['fire'],
    ]);

    final waterOnly = result.where(
      (s) => s.types.length == 1 && s.types.first == 'water',
    );
    expect(waterOnly.map((s) => s.pokemon.name), ['squirtle']);
  });

  test('a candidate that would not improve the team is left out', () {
    // The team already resists and covers everything a lone normal type adds.
    final result = suggest(
      [
        ['steel', 'ground'],
      ],
      from: [_mon('snorlax', 143)],
    );

    for (final s in result) {
      expect(s.gain, greaterThan(0));
    }
  });

  test('respects the limit and sorts best first', () {
    final result = suggest([
      ['fire'],
      ['fire'],
    ], limit: 2);

    expect(result, hasLength(lessThanOrEqualTo(2)));
    for (var i = 1; i < result.length; i++) {
      expect(result[i - 1].gain, greaterThanOrEqualTo(result[i].gain));
    }
  });

  test('skips Pokémon whose types are unknown', () {
    final result = suggest(
      [
        ['fire'],
      ],
      from: [_mon('mystery', 999), _mon('squirtle', 7)],
    );

    expect(result.map((s) => s.pokemon.name), ['squirtle']);
  });
}
