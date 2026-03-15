import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/pokemon_list_item.dart';

/// Manages favourite Pokémon with persistence via [shared_preferences].
///
/// Usage:
///   await FavouritesManager.instance.init(); // call once in main()
///   FavouritesManager.instance.toggle(pokemon);
///   FavouritesManager.instance.isFavourite('pikachu');
///
/// Widgets can listen for changes via [notifier].
class FavouritesManager {
  FavouritesManager._();
  static final FavouritesManager instance = FavouritesManager._();

  static const _kPrefsKey = 'favourite_pokemon_names';

  final ValueNotifier<List<PokemonListItem>> notifier =
      ValueNotifier<List<PokemonListItem>>([]);

  /// Must be called once at app startup (before [runApp]).
  Future<void> init(List<PokemonListItem> allPokemon) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_kPrefsKey) ?? [];

    // Re-hydrate PokemonListItem objects from stored names
    final favourites = saved
        .map((name) {
          try {
            return allPokemon.firstWhere((p) => p.name == name);
          } catch (_) {
            return null;
          }
        })
        .whereType<PokemonListItem>()
        .toList();

    notifier.value = favourites;
  }

  List<PokemonListItem> get favourites => List.unmodifiable(notifier.value);

  bool isFavourite(String name) => notifier.value.any((p) => p.name == name);

  Future<void> toggle(PokemonListItem pokemon) async {
    final current = List<PokemonListItem>.from(notifier.value);

    if (isFavourite(pokemon.name)) {
      current.removeWhere((p) => p.name == pokemon.name);
    } else {
      current.add(pokemon);
    }

    notifier.value = current;
    await _persist(current);
  }

  Future<void> _persist(List<PokemonListItem> favourites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kPrefsKey,
      favourites.map((p) => p.name).toList(),
    );
  }
}