import 'dart:convert';
import 'package:pokeflutter/model/pokemon.dart';
import 'package:pokeflutter/data/pokemon_api.dart';
import 'package:pokeflutter/data/pokemon_repository.dart';
import 'package:pokeflutter/data/share_service.dart';

import 'fixtures.dart';

/// A bundled-list stand-in: [count] Pokémon named `mon1`… with Pokédex ids
/// 1…count.
PokemonRepository fakeRepository({int count = 30}) => PokemonRepository(
  loadAsset: () async => jsonEncode({
    'pokemonList': [
      for (var i = 1; i <= count; i++)
        {'name': 'mon$i', 'url': 'https://pokeapi.co/api/v2/pokemon/$i/'},
    ],
  }),
);

/// Answers every Pokémon with [types] and no network access. Names listed in
/// [failing] throw a network error until removed from the set.
class FakePokemonApi extends PokemonApi {
  FakePokemonApi({
    this.types = const ['fire'],
    Set<String>? failing,
    this.shiny = true,
    this.varyingStats = false,
  }) : failing = failing ?? <String>{};

  final List<String> types;

  /// Whether the Pokémon have a shiny artwork.
  final bool shiny;

  /// Whether the base stats differ from one Pokémon to the next (see
  /// [statsOf]); otherwise they all have the fixtures' default stats.
  final bool varyingStats;
  final Set<String> failing;
  final List<String> requested = [];

  /// Base stats that grow with the number in the name (`mon7` beats `mon3`
  /// at every stat), so that two different Pokémon never tie.
  static Map<String, int> statsOf(String name) {
    final n = int.tryParse(name.replaceAll(RegExp(r'\D'), '')) ?? 0;
    const stats = [
      'hp',
      'attack',
      'defense',
      'special-attack',
      'special-defense',
      'speed',
    ];
    return {for (var i = 0; i < stats.length; i++) stats[i]: 20 + n * 3 + i};
  }

  @override
  Future<Pokemon> getPokemonDetails(String name) async {
    requested.add(name);
    if (failing.contains(name)) {
      throw const PokemonApiException(PokemonApiErrorType.network, 'offline');
    }
    return Pokemon.fromJson(
      pokemonJson(
        name: name,
        speciesName: name,
        types: types,
        stats: varyingStats ? statsOf(name) : null,
        shiny: shiny ? 'https://img/shiny.png' : null,
      ),
    );
  }
}

/// Remembers what was shared instead of opening the system sheet.
class FakeShareService implements ShareService {
  final List<String> shared = [];

  @override
  Future<void> shareText(String text) async => shared.add(text);
}
