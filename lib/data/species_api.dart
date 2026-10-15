import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/pokemon_species.dart';
import 'disk_cache.dart';
import 'network_status.dart';
import 'pokeapi_client.dart';
import 'pokemon_api.dart';

/// Fetches species information (Pokédex entry, category, habitat and the
/// location of the evolution chain) from PokéAPI.
///
/// Cached per species in memory for the session and, with a [DiskCache],
/// across restarts; a stale copy is used when the network fails. Concurrent
/// requests share one fetch.
class SpeciesApi {
  SpeciesApi({
    http.Client? client,
    DiskCache? disk,
    NetworkStatus? status,
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
       _disk = disk,
       _now = now ?? DateTime.now;

  final PokeApiClient _http;
  final DiskCache? _disk;
  final DateTime Function() _now;

  /// How long a disk copy is used without asking the network again.
  final Duration maxAge;

  final Map<String, Future<PokemonSpecies>> _species = {};

  /// The species called [speciesName] (`charizard`, not `charizard-mega-x`).
  /// Throws [PokemonApiException] on failure; failures are not cached.
  Future<PokemonSpecies> getSpecies(String speciesName) {
    final key = speciesName.toLowerCase();
    return _species[key] ??= _load(key);
  }

  Future<PokemonSpecies> _load(String key) async {
    try {
      final stored = await _readDisk(key);
      if (stored != null && _now().difference(stored.savedAt) < maxAge) {
        return stored.species;
      }

      try {
        final json = await _http.getJson(
          '${PokeApiClient.baseUrl}/pokemon-species/$key',
          notFoundMessage: 'Unknown species "$key"',
        );
        final PokemonSpecies species;
        try {
          species = PokemonSpecies.fromApiJson(json);
        } catch (e) {
          throw PokemonApiException(PokemonApiErrorType.parse, '$e');
        }
        await _disk?.write(
          'species-$key',
          jsonEncode(species.toCacheJson()),
          now: _now(),
        );
        return species;
      } on PokemonApiException catch (e) {
        final canFallBack =
            e.type == PokemonApiErrorType.network ||
            e.type == PokemonApiErrorType.server;
        if (stored != null && canFallBack) return stored.species;
        rethrow;
      }
    } catch (_) {
      _species.removeWhere((k, _) => k == key); // let the next call retry
      rethrow;
    }
  }

  Future<({PokemonSpecies species, DateTime savedAt})?> _readDisk(
    String key,
  ) async {
    final entry = await _disk?.read('species-$key');
    if (entry == null) return null;
    try {
      return (
        species: PokemonSpecies.fromCacheJson(
          jsonDecode(entry.value) as Map<String, dynamic>,
        ),
        savedAt: entry.savedAt,
      );
    } catch (_) {
      return null;
    }
  }
}
