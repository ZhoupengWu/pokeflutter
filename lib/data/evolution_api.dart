import 'package:http/http.dart' as http;
import '../model/evolution.dart';
import 'pokeapi_client.dart';
import 'pokemon_api.dart';

/// Fetches evolution chains from PokéAPI.
///
/// A chain takes two requests (`pokemon-species` → `evolution-chain`), so
/// results are cached per species for the rest of the session and concurrent
/// requests share one fetch.
class EvolutionApi {
  EvolutionApi({
    http.Client? client,
    Duration timeout = const Duration(seconds: 15),
    Duration retryDelay = const Duration(milliseconds: 500),
    int maxAttempts = 2,
  }) : _http = PokeApiClient(
         client: client,
         timeout: timeout,
         retryDelay: retryDelay,
         maxAttempts: maxAttempts,
       );

  final PokeApiClient _http;
  final Map<String, Future<EvolutionChain>> _chains = {};

  /// The evolution chain of the species called [speciesName]
  /// (`charizard`, not `charizard-mega-x`).
  /// Throws [PokemonApiException] on failure; failures are not cached.
  Future<EvolutionChain> getChain(String speciesName) {
    final key = speciesName.toLowerCase();
    return _chains[key] ??= _load(key);
  }

  Future<EvolutionChain> _load(String key) async {
    try {
      return await _fetch(key);
    } catch (_) {
      _chains.removeWhere((k, _) => k == key); // let the next call retry
      rethrow;
    }
  }

  Future<EvolutionChain> _fetch(String speciesName) async {
    final species = await _http.getJson(
      '${PokeApiClient.baseUrl}/pokemon-species/$speciesName',
      notFoundMessage: 'Unknown species "$speciesName"',
    );
    final String chainUrl;
    try {
      chainUrl =
          (species['evolution_chain'] as Map<String, dynamic>)['url'] as String;
    } catch (e) {
      throw PokemonApiException(PokemonApiErrorType.parse, '$e');
    }

    final json = await _http.getJson(chainUrl);
    try {
      return EvolutionChain.fromJson(json);
    } catch (e) {
      throw PokemonApiException(PokemonApiErrorType.parse, '$e');
    }
  }
}
