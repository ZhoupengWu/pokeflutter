import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/evolution.dart';
import 'disk_cache.dart';
import 'network_status.dart';
import 'pokeapi_client.dart';
import 'pokemon_api.dart';
import 'species_api.dart';

/// Fetches evolution chains from PokéAPI.
///
/// A chain takes two requests (`pokemon-species` → `evolution-chain`; the
/// species part is shared with [SpeciesApi]), so results are cached per species: in memory for the session and, with a
/// [DiskCache], across restarts (a stale copy is used when the network fails).
/// Concurrent requests share one fetch.
class EvolutionApi {
  EvolutionApi({
    http.Client? client,
    DiskCache? disk,
    NetworkStatus? status,
    SpeciesApi? species,
    this.maxAge = const Duration(days: 30),
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
           ),
       _disk = disk,
       _now = now ?? DateTime.now;

  final PokeApiClient _http;
  final SpeciesApi _species;
  final DiskCache? _disk;
  final DateTime Function() _now;

  /// How long a disk copy is used without asking the network again.
  final Duration maxAge;

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
      final stored = await _readDisk(key);
      if (stored != null && _now().difference(stored.savedAt) < maxAge) {
        return stored.chain;
      }

      try {
        final json = await _fetchJson(key);
        final chain = _parse(json);
        await _disk?.write('chain-$key', jsonEncode(json), now: _now());
        return chain;
      } on PokemonApiException catch (e) {
        final canFallBack =
            e.type == PokemonApiErrorType.network ||
            e.type == PokemonApiErrorType.server;
        if (stored != null && canFallBack) return stored.chain;
        rethrow;
      }
    } catch (_) {
      _chains.removeWhere((k, _) => k == key); // let the next call retry
      rethrow;
    }
  }

  Future<({EvolutionChain chain, DateTime savedAt})?> _readDisk(
    String key,
  ) async {
    final entry = await _disk?.read('chain-$key');
    if (entry == null) return null;
    try {
      return (
        chain: _parse(jsonDecode(entry.value) as Map<String, dynamic>),
        savedAt: entry.savedAt,
      );
    } catch (_) {
      return null;
    }
  }

  EvolutionChain _parse(Map<String, dynamic> json) {
    try {
      return EvolutionChain.fromJson(json);
    } catch (e) {
      throw PokemonApiException(PokemonApiErrorType.parse, '$e');
    }
  }

  /// species → evolution-chain; returns the chain's raw JSON.
  Future<Map<String, dynamic>> _fetchJson(String speciesName) async {
    final species = await _species.getSpecies(speciesName);
    return _http.getJson(species.evolutionChainUrl);
  }
}
