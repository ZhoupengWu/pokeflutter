import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'pokemon_costants.dart';

/// Lookup of which Pokémon belong to which type.
///
/// Lets the home page filter the whole list by type *before* building the
/// grid, instead of waiting for every grid cell to download its own details.
/// Built from the 18 `/type/{name}` endpoints of PokéAPI (18 requests instead
/// of one per Pokémon) and persisted with [SharedPreferences], so it is
/// downloaded only once.
class PokemonTypeIndex {
  PokemonTypeIndex({http.Client? client}) : _client = client ?? http.Client();

  static final PokemonTypeIndex instance = PokemonTypeIndex();

  static const _kPrefsKey = 'pokemon_type_index_v1';
  static const _timeout = Duration(seconds: 15);

  final http.Client _client;

  /// Type name -> names of the Pokémon having that type.
  Map<String, Set<String>>? _namesByType;
  Future<bool>? _loading;

  bool get isLoaded => _namesByType != null;

  /// True if [pokemonName] has at least one of [types].
  /// Only meaningful once [ensureLoaded] has completed with `true`.
  bool matchesAny(String pokemonName, Set<String> types) {
    final index = _namesByType;
    if (index == null) return false;
    return types.any((t) => index[t]?.contains(pokemonName) ?? false);
  }

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
      _namesByType = stored;
      return true;
    }

    try {
      final types = listPokemonTypeColor.keys.toList();
      final lists = await Future.wait(types.map(_fetchType));
      final index = <String, Set<String>>{
        for (var i = 0; i < types.length; i++) types[i]: lists[i],
      };
      _namesByType = index;
      await _store(index);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Set<String>> _fetchType(String type) async {
    final response = await _client
        .get(Uri.parse('https://pokeapi.co/api/v2/type/$type'))
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Type $type: HTTP ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['pokemon'] as List)
        .map((e) => e['pokemon']['name'] as String)
        .toSet();
  }

  Future<Map<String, Set<String>>?> _readStored() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPrefsKey);
      if (raw == null) return null;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final index = decoded.map(
        (type, names) => MapEntry(type, (names as List).cast<String>().toSet()),
      );
      // Ignore an incomplete index: it would silently hide Pokémon.
      if (!listPokemonTypeColor.keys.every(index.containsKey)) return null;
      return index;
    } catch (_) {
      return null;
    }
  }

  Future<void> _store(Map<String, Set<String>> index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kPrefsKey,
        jsonEncode(index.map((type, names) => MapEntry(type, names.toList()))),
      );
    } catch (_) {
      // Persistence is an optimisation: the in-memory index is still valid.
    }
  }
}
