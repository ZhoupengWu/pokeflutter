import 'package:flutter/foundation.dart';
import '../model/pokemon_list_item.dart';

/// Simple in-memory favourites manager.
/// Exposes a [ValueNotifier] so any widget can listen for changes.
/// Replace the in-memory list with shared_preferences or Hive for persistence.
class FavouritesManager {
  FavouritesManager._();
  static final FavouritesManager instance = FavouritesManager._();

  final ValueNotifier<List<PokemonListItem>> notifier =
      ValueNotifier<List<PokemonListItem>>([]);

  List<PokemonListItem> get favourites => List.unmodifiable(notifier.value);

  bool isFavourite(String name) => notifier.value.any((p) => p.name == name);

  void toggle(PokemonListItem pokemon) {
    final current = List<PokemonListItem>.from(notifier.value);
    if (isFavourite(pokemon.name)) {
      current.removeWhere((p) => p.name == pokemon.name);
    } else {
      current.add(pokemon);
    }
    notifier.value = current;
  }
}