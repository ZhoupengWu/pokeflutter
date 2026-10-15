import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/evolution.dart';
import 'cached_resource.dart';
import 'disk_cache.dart';
import 'network_status.dart';
import 'pokeapi_client.dart';
import 'pokemon_api.dart';
import 'species_api.dart';

/// Fetches evolution chains from PokéAPI.
///
/// A chain takes two requests (`pokemon-species` → `evolution-chain`; the
/// species part is shared with [SpeciesApi]), so results are cached per
/// species: in memory for the session and, with a [DiskCache], across restarts
/// (a stale copy is used when the network fails).
class EvolutionApi {
  EvolutionApi({
    http.Client? client,
    DiskCache? disk,
    NetworkStatus? status,
    SpeciesApi? species,
    Duration maxAge = const Duration(days: 30),
    DateTime Function()? now,
    Duration timeout = const Duration(seconds: 15),
    Duration retryDelay = const Duration(milliseconds: 500),
    int maxAttempts = 2,
  }) : _http = PokeApiClient(
         client: client,
         timeout: timeout,
         retryDelay: retryDelay,
         maxAttempts: maxAttempts,
         status: status,
       ),
       _species =
           species ??
           SpeciesApi(
             client: client,
             disk: disk,
             status: status,
             maxAge: maxAge,
             now: now,
             timeout: timeout,
             retryDelay: retryDelay,
             maxAttempts: maxAttempts,
           ) {
    _resource = CachedResource<EvolutionChain>(
      prefix: 'chain',
      disk: disk,
      maxAge: maxAge,
      now: now,
      fetch: _fetch,
      decode: (stored) =>
          EvolutionChain.fromJson(jsonDecode(stored) as Map<String, dynamic>),
    );
  }

  final PokeApiClient _http;
  final SpeciesApi _species;
  late final CachedResource<EvolutionChain> _resource;

  /// The evolution chain of the species called [speciesName]
  /// (`charizard`, not `charizard-mega-x`).
  /// Throws [PokemonApiException] on failure; failures are not cached.
  Future<EvolutionChain> getChain(String speciesName) =>
      _resource.get(speciesName);

  /// species → evolution-chain; keeps the chain's raw JSON on disk.
  Future<Fetched<EvolutionChain>> _fetch(String key) async {
    final species = await _species.getSpecies(key);
    final json = await _http.getJson(species.evolutionChainUrl);
    try {
      return (value: EvolutionChain.fromJson(json), stored: jsonEncode(json));
    } catch (e) {
      throw PokemonApiException(PokemonApiErrorType.parse, '$e');
    }
  }
}
