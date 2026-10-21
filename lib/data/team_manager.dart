import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/pokemon_list_item.dart';

/// The team of up to [maxSize] Pokémon, kept in [shared_preferences].
///
/// One instance is created at startup (see `AppServices`); call [init] once.
/// Widgets listen to [notifier].
class TeamManager {
  TeamManager();

  /// Slots in a team.
  static const maxSize = 6;

  static const _kPrefsKey = 'team_pokemon_names';

  final ValueNotifier<List<PokemonListItem>> notifier =
      ValueNotifier<List<PokemonListItem>>([]);

  /// Restores the saved team, looking the names up in [allPokemon].
  Future<void> init(List<PokemonListItem> allPokemon) async {
    final prefs = await SharedPreferences.getInstance();
    final byName = {for (final p in allPokemon) p.name: p};
    notifier.value = [
      for (final name in prefs.getStringList(_kPrefsKey) ?? const <String>[])
        if (byName[name] != null) byName[name]!,
    ].take(maxSize).toList();
  }

  List<PokemonListItem> get members => List.unmodifiable(notifier.value);

  bool get isFull => notifier.value.length >= maxSize;

  bool contains(String name) => notifier.value.any((p) => p.name == name);

  /// Adds [pokemon] unless the team is full or already has it. Returns whether
  /// it was added.
  Future<bool> add(PokemonListItem pokemon) async {
    if (isFull || contains(pokemon.name)) return false;
    await _set([...notifier.value, pokemon]);
    return true;
  }

  Future<void> remove(String name) =>
      _set([...notifier.value.where((p) => p.name != name)]);

  Future<void> clear() => _set(const []);

  Future<void> _set(List<PokemonListItem> team) async {
    notifier.value = team;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kPrefsKey, [for (final p in team) p.name]);
  }
}
