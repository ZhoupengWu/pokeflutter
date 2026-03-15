import '../model/pokemon.dart';

/// In-memory LRU-style cache for Pokémon detail data.
/// Survives widget rebuilds and navigation within the same app session.
/// To persist across restarts, replace the map with a shared_preferences
/// or Hive implementation in [get] and [set].
class PokemonCache {
  PokemonCache._();
  static final PokemonCache instance = PokemonCache._();

  final Map<String, Pokemon> _cache = {};

  /// Returns the cached [Pokemon] for [name], or null if not cached.
  Pokemon? get(String name) => _cache[name.toLowerCase()];

  /// Stores [pokemon] under its normalised name.
  void set(Pokemon pokemon) => _cache[pokemon.name.toLowerCase()] = pokemon;

  /// Returns true if [name] is already cached.
  bool has(String name) => _cache.containsKey(name.toLowerCase());

  /// Removes a single entry (e.g. to force a refresh).
  void invalidate(String name) => _cache.remove(name.toLowerCase());

  /// Wipes the entire cache.
  void clear() => _cache.clear();

  /// Current number of cached entries — useful for debugging.
  int get size => _cache.length;
}