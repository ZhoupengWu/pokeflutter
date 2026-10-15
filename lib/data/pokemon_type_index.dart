import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/pokemon_constants.dart';

/// Lookup of the types of every Pokémon.
///
/// The grid shows name, id, sprite *and types* of up to 1154 Pokémon. Fetching
/// each one's details would mean one request per cell, so the types come from
/// the 18 `/type/{name}` endpoints of PokéAPI instead (18 requests in total).
/// The result is persisted with [SharedPreferences], so it is downloaded only
/// once. Also lets the home page filter by type *before* building the grid.
///
/// Notifies its listeners when the index becomes available.
class PokemonTypeIndex extends ChangeNotifier {
  PokemonTypeIndex({http.Client? client}) : _client = client ?? http.Client();

  static const _kPrefsKey = 'pokemon_type_index_v2';
  static const _timeout = Duration(seconds: 15);

  final http.Client _client;

  /// Pokémon name -> its types, primary type first.
  Map<String, List<String>>? _typesByName;
  Future<bool>? _loading;

  bool get isLoaded => _typesByName != null;

  /// Types of [pokemonName], primary type first. Null while the index is not
  /// loaded or if the Pokémon is unknown.
  List<String>? typesOf(String pokemonName) => _typesByName?[pokemonName];

  /// True if [pokemonName] has at least one of [types].
  /// Only meaningful once [ensureLoaded] has completed with `true`.
  bool matchesAny(String pokemonName, Set<String> types) =>
      typesOf(pokemonName)?.any(types.contains) ?? false;

  /// Loads the index from disk, or downloads it on first use.
  /// Concurrent callers share the same load. Returns false on any failure
  /// (nothing partial is kept, so a later call retries from scratch).
  Future<bool> ensureLoaded() {
    if (isLoaded) return Future.value(true);
    return _loading ??= _load().whenComplete(() => _loading = null);
  }

  Future<bool> _load() async {
    final stored = await _readStored();
    if (stored != null) {
      _typesByName = stored;
      notifyListeners();
      return true;
    }

    try {
      final types = listPokemonTypeColor.keys.toList();
      final perType = await Future.wait(types.map(_fetchType));

      // A Pokémon appears in the list of each of its types, tagged with the
      // slot (1 = primary type, 2 = secondary) it occupies there.
      final slots = <String, List<(int, String)>>{};
      for (var i = 0; i < types.length; i++) {
        for (final (name, slot) in perType[i]) {
          slots.putIfAbsent(name, () => []).add((slot, types[i]));
        }
      }
      final index = {
        for (final entry in slots.entries)
          entry.key: (entry.value..sort((a, b) => a.$1.compareTo(b.$1)))
              .map((e) => e.$2)
              .toList(),
      };

      _typesByName = index;
      notifyListeners();
      await _store(index);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Returns (pokemon name, slot) for every Pokémon of [type].
  Future<List<(String, int)>> _fetchType(String type) async {
    final response = await _client
        .get(Uri.parse('https://pokeapi.co/api/v2/type/$type'))
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Type $type: HTTP ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['pokemon'] as List)
        .map((e) => (e['pokemon']['name'] as String, e['slot'] as int))
        .toList();
  }

  Future<Map<String, List<String>>?> _readStored() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPrefsKey);
      if (raw == null) return null;
      // Only written after all 18 type lists were downloaded, so never partial.
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final index = decoded.map(
        (name, types) => MapEntry(name, (types as List).cast<String>()),
      );
      return index.isEmpty ? null : index;
    } catch (_) {
      return null;
    }
  }

  Future<void> _store(Map<String, List<String>> index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPrefsKey, jsonEncode(index));
      await prefs.remove('pokemon_type_index_v1'); // superseded format
    } catch (_) {
      // Persistence is an optimisation: the in-memory index is still valid.
    }
  }
}
