import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/pokemon.dart';
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
/// - Transient failures (network, 5xx) are retried once.
/// - Failures are reported as [PokemonApiException], never as `null`.
class PokemonApi {
  PokemonApi({
    http.Client? client,
    PokemonCache? cache,
    this.timeout = const Duration(seconds: 15),
    this.retryDelay = const Duration(milliseconds: 500),
    this.maxAttempts = 2,
  }) : _client = client ?? http.Client(),
       _cache = cache ?? PokemonCache.instance;

  static final PokemonApi instance = PokemonApi();

  static const _baseUrl = 'https://pokeapi.co/api/v2';

  final http.Client _client;
  final PokemonCache _cache;
  final Duration timeout;
  final Duration retryDelay;
  final int maxAttempts;

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
    PokemonApiException? last;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      if (attempt > 1) await Future<void>.delayed(retryDelay);
      try {
        final pokemon = await _request(name);
        _cache.set(pokemon);
        return pokemon;
      } on PokemonApiException catch (e) {
        last = e;
        final retryable =
            e.type == PokemonApiErrorType.network ||
            e.type == PokemonApiErrorType.server;
        if (!retryable) break;
      }
    }
    throw last!;
  }

  Future<Pokemon> _request(String name) async {
    final http.Response response;
    try {
      response = await _client
          .get(Uri.parse('$_baseUrl/pokemon/$name'))
          .timeout(timeout);
    } catch (e) {
      throw PokemonApiException(PokemonApiErrorType.network, '$e');
    }

    if (response.statusCode == 404) {
      throw PokemonApiException(
        PokemonApiErrorType.notFound,
        'Unknown Pokémon "$name"',
      );
    }
    if (response.statusCode != 200) {
      throw PokemonApiException(
        PokemonApiErrorType.server,
        'HTTP ${response.statusCode}',
      );
    }

    try {
      return Pokemon.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (e) {
      throw PokemonApiException(PokemonApiErrorType.parse, '$e');
    }
  }
}
