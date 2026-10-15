import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/pokemon_species.dart';
import 'cached_resource.dart';
import 'disk_cache.dart';
import 'network_status.dart';
import 'pokeapi_client.dart';
import 'pokemon_api.dart';

/// Fetches species information (Pokédex entry, category, habitat and the
/// location of the evolution chain) from PokéAPI.
///
/// Cached per species in memory for the session and, with a [DiskCache],
/// across restarts; a stale copy is used when the network fails.
class SpeciesApi {
  SpeciesApi({
    http.Client? client,
    DiskCache? disk,
    NetworkStatus? status,
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
       ) {
    _resource = CachedResource<PokemonSpecies>(
      prefix: 'species',
      disk: disk,
      maxAge: maxAge,
      now: now,
      fetch: _fetch,
      decode: (stored) => PokemonSpecies.fromCacheJson(
        jsonDecode(stored) as Map<String, dynamic>,
      ),
    );
  }

  final PokeApiClient _http;
  late final CachedResource<PokemonSpecies> _resource;

  /// The species called [speciesName] (`charizard`, not `charizard-mega-x`).
  /// Throws [PokemonApiException] on failure; failures are not cached.
  Future<PokemonSpecies> getSpecies(String speciesName) =>
      _resource.get(speciesName);

  Future<Fetched<PokemonSpecies>> _fetch(String key) async {
    final json = await _http.getJson(
      '${PokeApiClient.baseUrl}/pokemon-species/$key',
      notFoundMessage: 'Unknown species "$key"',
    );
    try {
      final species = PokemonSpecies.fromApiJson(json);
      return (value: species, stored: jsonEncode(species.toCacheJson()));
    } catch (e) {
      throw PokemonApiException(PokemonApiErrorType.parse, '$e');
    }
  }
}
