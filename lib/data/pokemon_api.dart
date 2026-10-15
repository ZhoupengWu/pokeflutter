import 'dart:async';
import 'package:http/http.dart' as http;
import '../model/pokemon.dart';
import 'pokeapi_client.dart';
import 'pokemon_cache.dart';

/// Why a PokéAPI request failed, so the UI can react accordingly.
enum PokemonApiErrorType {
  /// No connection, timeout or any other transport failure.
  network,

  /// The Pokémon does not exist (HTTP 404).
  notFound,

  /// PokéAPI answered with an unexpected status (5xx, 429, …).
  server,

  /// The response arrived but could not be understood.
  parse,
}

class PokemonApiException implements Exception {
  final PokemonApiErrorType type;
  final String message;

  const PokemonApiException(this.type, this.message);

  @override
  String toString() => 'PokemonApiException(${type.name}): $message';
}

/// Fetches Pokémon details from PokéAPI.
///
/// - Cache-first: only hits the network on a [PokemonCache] miss.
/// - Concurrent requests for the same Pokémon share one network call.
/// - Transient failures (network, 5xx) are retried by [PokeApiClient].
/// - Failures are reported as [PokemonApiException], never as `null`.
class PokemonApi {
  PokemonApi({
    http.Client? client,
    PokemonCache? cache,
    Duration timeout = const Duration(seconds: 15),
    Duration retryDelay = const Duration(milliseconds: 500),
    int maxAttempts = 2,
  }) : _http = PokeApiClient(
         client: client,
         timeout: timeout,
         retryDelay: retryDelay,
         maxAttempts: maxAttempts,
       ),
       _cache = cache ?? PokemonCache();

  final PokeApiClient _http;
  final PokemonCache _cache;

  final Map<String, Future<Pokemon>> _inFlight = {};

  /// Returns the details of the Pokémon called [name].
  /// Throws [PokemonApiException] on failure.
  Future<Pokemon> getPokemonDetails(String name) {
    final key = name.toLowerCase();
    final cached = _cache.get(key);
    if (cached != null) return Future.value(cached);

    return _inFlight[key] ??= _fetch(key).whenComplete(() {
      // Block body on purpose: returning the removed future from the callback
      // would make whenComplete wait for itself.
      _inFlight.remove(key);
    });
  }

  Future<Pokemon> _fetch(String name) async {
    final json = await _http.getJson(
      '${PokeApiClient.baseUrl}/pokemon/$name',
      notFoundMessage: 'Unknown Pokémon "$name"',
    );
    final Pokemon pokemon;
    try {
      pokemon = Pokemon.fromJson(json);
    } catch (e) {
      throw PokemonApiException(PokemonApiErrorType.parse, '$e');
    }
    _cache.set(pokemon);
    return pokemon;
  }
}
