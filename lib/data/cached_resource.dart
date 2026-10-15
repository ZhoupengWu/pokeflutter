import 'dart:async';
import 'disk_cache.dart';
import 'pokemon_api.dart';

/// What a fetch produced: the parsed [value] and the text to keep on disk.
typedef Fetched<T> = ({T value, String stored});

/// Loads one value per name with the layering the PokéAPI services share:
/// memory (for the session) → disk (while younger than [maxAge]) → network,
/// and a stale disk copy when the network or the server fails.
///
/// Concurrent requests for a name share one fetch, and failures are not
/// remembered, so the next call tries again.
class CachedResource<T> {
  CachedResource({
    required this.prefix,
    required Future<Fetched<T>> Function(String key) fetch,
    required T Function(String stored) decode,
    DiskCache? disk,
    this.maxAge = const Duration(days: 30),
    DateTime Function()? now,
  }) : _fetch = fetch,
       _decode = decode,
       _disk = disk,
       _now = now ?? DateTime.now;

  /// Disk keys are `$prefix-$name`.
  final String prefix;

  /// How long a disk copy is used without asking the network again.
  final Duration maxAge;

  final Future<Fetched<T>> Function(String key) _fetch;
  final T Function(String stored) _decode;
  final DiskCache? _disk;
  final DateTime Function() _now;

  final Map<String, Future<T>> _loaded = {};

  /// The value for [name] (case-insensitive). Throws [PokemonApiException].
  Future<T> get(String name) {
    final key = name.toLowerCase();
    return _loaded[key] ??= _load(key);
  }

  Future<T> _load(String key) async {
    try {
      final stored = await _readDisk(key);
      if (stored != null && _now().difference(stored.savedAt) < maxAge) {
        return stored.value;
      }

      try {
        final fetched = await _fetch(key);
        await _disk?.write('$prefix-$key', fetched.stored, now: _now());
        return fetched.value;
      } on PokemonApiException catch (e) {
        final canFallBack =
            e.type == PokemonApiErrorType.network ||
            e.type == PokemonApiErrorType.server;
        if (stored != null && canFallBack) return stored.value;
        rethrow;
      }
    } catch (_) {
      _loaded.removeWhere((k, _) => k == key); // let the next call retry
      rethrow;
    }
  }

  Future<({T value, DateTime savedAt})?> _readDisk(String key) async {
    final entry = await _disk?.read('$prefix-$key');
    if (entry == null) return null;
    try {
      return (value: _decode(entry.value), savedAt: entry.savedAt);
    } catch (_) {
      return null; // unreadable copy: behave like a miss
    }
  }
}
