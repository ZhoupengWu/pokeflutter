import 'dart:math';
import 'package:flutter/foundation.dart';
import '../model/pokemon_list_item.dart';
import '../data/pokemon_repository.dart';
import '../data/pokemon_type_index.dart';

/// State of the Home tab: the full list, the search text, the active type
/// filters and the resulting [filtered] list.
///
/// Type filtering needs the [PokemonTypeIndex]; it is downloaded on first use,
/// so [isFilterLoading] / [filterFailed] describe that wait.
class HomeController extends ChangeNotifier {
  HomeController({
    PokemonRepository? repository,
    PokemonTypeIndex? typeIndex,
    Random? random,
  }) : _repository = repository ?? PokemonRepository.instance,
       _typeIndex = typeIndex ?? PokemonTypeIndex.instance,
       _random = random ?? Random();

  final PokemonRepository _repository;
  final PokemonTypeIndex _typeIndex;
  final Random _random;

  List<PokemonListItem> allPokemon = const [];
  List<PokemonListItem> filtered = const [];
  String searchQuery = '';
  Set<String> activeTypes = const {};

  /// A type filter is waiting for the type index to download.
  bool isFilterLoading = false;

  /// The type index could not be downloaded, so the filter cannot apply.
  bool filterFailed = false;

  /// The type index could not be loaded (cells stay grey, filters unavailable).
  bool typesUnavailable = false;

  int _request = 0; // discards results of superseded filter runs
  bool _disposed = false;

  /// Loads the list, then (in the background of the UI) the type index.
  Future<void> init() async {
    final items = await _repository.getAll();
    if (_disposed) return;
    allPokemon = items;
    filtered = List.of(items);
    notifyListeners();
    await loadTypes();
  }

  /// Types colour the cards; without them the grid still works, in grey.
  Future<void> loadTypes() async {
    final loaded = await _typeIndex.ensureLoaded();
    if (_disposed) return;
    typesUnavailable = !loaded;
    notifyListeners();
  }

  Future<void> setSearch(String query) {
    searchQuery = query.trim().toLowerCase();
    return applyFilters();
  }

  Future<void> setTypeFilters(Set<String> types) {
    activeTypes = Set.of(types);
    notifyListeners();
    return applyFilters();
  }

  /// Applies search text and type filters to the full list (also the Retry
  /// action after [filterFailed]).
  Future<void> applyFilters() async {
    final request = ++_request;
    final types = activeTypes;

    if (types.isNotEmpty && !_typeIndex.isLoaded) {
      isFilterLoading = true;
      filterFailed = false;
      notifyListeners();
      final loaded = await _typeIndex.ensureLoaded();
      if (_disposed || request != _request) return;
      if (!loaded) {
        isFilterLoading = false;
        filterFailed = true;
        notifyListeners();
        return;
      }
    }

    isFilterLoading = false;
    filterFailed = false;
    filtered = [
      for (final p in allPokemon)
        if ((searchQuery.isEmpty ||
                p.name.toLowerCase().contains(searchQuery)) &&
            (types.isEmpty || _typeIndex.matchesAny(p.name, types)))
          p,
    ];
    notifyListeners();
  }

  /// A random Pokémon from the whole list, or null before it is loaded.
  PokemonListItem? randomPokemon() => allPokemon.isEmpty
      ? null
      : allPokemon[_random.nextInt(allPokemon.length)];

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
