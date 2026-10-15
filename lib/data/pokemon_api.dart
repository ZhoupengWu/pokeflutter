import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/pokemon.dart';
import 'disk_cache.dart';
import 'network_status.dart';
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
/// Lookup order: memory ([PokemonCache]) → disk ([DiskCache], while younger
/// than [maxAge]) → network. When the network fails, an older disk copy is
/// still returned, so Pokémon seen before keep working offline.
///
/// - Concurrent requests for the same Pokémon share one network call.
/// - Transient failures (network, 5xx) are retried by [PokeApiClient].
/// - Failures are reported as [PokemonApiException], never as `null`.
class PokemonApi {
  PokemonApi({
    http.Client? client,
    PokemonCache? cache,
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
       _cache = cache ?? PokemonCache(),
       _disk = disk,
       _now = now ?? DateTime.now;

  final PokeApiClient _http;
  final PokemonCache _cache;
  final DiskCache? _disk;
  final DateTime Function() _now;

  /// How long a disk copy is used without asking the network again.
  final Duration maxAge;

  final Map<String, Future<Pokemon>> _inFlight = {};

  /// Returns the details of the Pokémon called [name].
  /// Throws [PokemonApiException] on failure.
  Future<Pokemon> getPokemonDetails(String name) {
    final key = name.toLowerCase();
    final cached = _cache.get(key);
    if (cached != null) return Future.value(cached);

    return _inFlight[key] ??= _load(key).whenComplete(() {
      // Block body on purpose: returning the removed future from the callback
      // would make whenComplete wait for itself.
      _inFlight.remove(key);
    });
  }

  Future<Pokemon> _load(String name) async {
    final stored = await _readDisk(name);
    if (stored != null && _now().difference(stored.savedAt) < maxAge) {
      _cache.set(stored.pokemon);
      return stored.pokemon;
    }

    try {
      final fresh = await _fetch(name);
      _cache.set(fresh);
      await _disk?.write(
        'pokemon-$name',
        jsonEncode(fresh.toCacheJson()),
        now: _now(),
      );
      return fresh;
    } on PokemonApiException catch (e) {
      // An old copy beats an error when the server cannot be reached.
      final canFallBack =
          e.type == PokemonApiErrorType.network ||
          e.type == PokemonApiErrorType.server;
      if (stored != null && canFallBack) {
        _cache.set(stored.pokemon);
        return stored.pokemon;
      }
      rethrow;
    }
  }

  Future<({Pokemon pokemon, DateTime savedAt})?> _readDisk(String name) async {
    final entry = await _disk?.read('pokemon-$name');
    if (entry == null) return null;
    try {
      final pokemon = Pokemon.fromCacheJson(
        jsonDecode(entry.value) as Map<String, dynamic>,
      );
      return (pokemon: pokemon, savedAt: entry.savedAt);
    } catch (_) {
      return null; // unreadable (e.g. written by another version)
    }
  }

  Future<Pokemon> _fetch(String name) async {
    final json = await _http.getJson(
      '${PokeApiClient.baseUrl}/pokemon/$name',
      notFoundMessage: 'Unknown Pokémon "$name"',
    );
    try {
      return Pokemon.fromJson(json);
    } catch (e) {
      throw PokemonApiException(PokemonApiErrorType.parse, '$e');
    }
  }
}
