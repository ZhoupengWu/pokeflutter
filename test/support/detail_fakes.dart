import 'dart:convert';
import 'package:pokeflutter/model/evolution.dart';
import 'package:pokeflutter/data/ability_api.dart';
import 'package:pokeflutter/data/evolution_api.dart';
import 'package:pokeflutter/data/pokemon_api.dart';
import 'package:pokeflutter/data/species_api.dart';
import 'package:pokeflutter/model/pokemon_species.dart';

import 'fixtures.dart';

/// Serves a fixed chain, or fails while [fail] is true.
class FakeEvolutionApi extends EvolutionApi {
  FakeEvolutionApi({String? chainBody, this.fail = false})
    : _chain = EvolutionChain.fromJson(
        jsonDecode(chainBody ?? bulbasaurChainBody()) as Map<String, dynamic>,
      );

  final EvolutionChain _chain;
  bool fail;
  final List<String> requested = [];

  @override
  Future<EvolutionChain> getChain(String speciesName) async {
    requested.add(speciesName);
    if (fail) {
      throw const PokemonApiException(PokemonApiErrorType.network, 'offline');
    }
    return _chain;
  }
}

/// Serves a fixed species, or fails while [fail] is true.
class FakeSpeciesApi extends SpeciesApi {
  FakeSpeciesApi({PokemonSpecies? species, this.fail = false})
    : _species = species ?? sampleSpecies();

  final PokemonSpecies _species;
  bool fail;
  final List<String> requested = [];

  @override
  Future<PokemonSpecies> getSpecies(String speciesName) async {
    requested.add(speciesName);
    if (fail) {
      throw const PokemonApiException(PokemonApiErrorType.network, 'offline');
    }
    return _species;
  }
}

/// Serves the names of a few abilities, or fails while [fail] is true.
class FakeAbilityApi extends AbilityApi {
  FakeAbilityApi({this.fail = false});

  bool fail;
  final List<String> requested = [];

  static const names = {
    'blaze': {'en': 'Blaze', 'it': 'Fuocardore'},
  };

  @override
  Future<Map<String, String>> getNames(String id) async {
    requested.add(id);
    final found = names[id];
    if (fail || found == null) {
      throw const PokemonApiException(PokemonApiErrorType.network, 'offline');
    }
    return found;
  }
}
