import 'dart:convert';
import 'package:pokeflutter/model/pokemon.dart';
import 'package:pokeflutter/utils/pokemon_api.dart';
import 'package:pokeflutter/utils/pokemon_repository.dart';

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
  FakePokemonApi({this.types = const ['fire'], Set<String>? failing})
    : failing = failing ?? <String>{};

  final List<String> types;
  final Set<String> failing;
  final List<String> requested = [];

  @override
  Future<Pokemon> getPokemonDetails(String name) async {
    requested.add(name);
    if (failing.contains(name)) {
      throw const PokemonApiException(PokemonApiErrorType.network, 'offline');
    }
    return Pokemon.fromJson(pokemonJson(name: name, types: types));
  }
}
