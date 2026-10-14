import 'dart:convert';
import 'package:pokeflutter/model/evolution.dart';
import 'package:pokeflutter/utils/evolution_api.dart';
import 'package:pokeflutter/utils/pokemon_api.dart';

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
