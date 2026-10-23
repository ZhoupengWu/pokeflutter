import 'dart:math';
import 'package:flutter/foundation.dart';
import '../core/pokedex.dart';
import '../core/type_chart.dart';
import '../model/pokemon_list_item.dart';
import '../data/pokemon_names.dart';
import '../data/pokemon_repository.dart';
import '../data/pokemon_type_index.dart';

/// State of the Home tab: the full list, the search text, the active type
/// filters and the resulting [filtered] list.
///
/// Type filtering needs the [PokemonTypeIndex]; it is downloaded on first use,
/// so [isFilterLoading] / [filterFailed] describe that wait.
class HomeController extends ChangeNotifier {
  HomeController({
    required PokemonRepository repository,
    required PokemonTypeIndex typeIndex,
    required PokemonNames names,
    Random? random,
  }) : _repository = repository,
       _typeIndex = typeIndex,
       _names = names,
       _random = random ?? Random();

  final PokemonRepository _repository;
  final PokemonTypeIndex _typeIndex;
  final PokemonNames _names;
  final Random _random;

  List<PokemonListItem> allPokemon = const [];
  List<PokemonListItem> filtered = const [];
  String searchQuery = '';
  Set<String> activeTypes = const {};

  /// Attacking types: only Pokémon weak to at least one of them are kept.
  Set<String> activeWeakTo = const {};

  /// Selected generations (1…9); empty means all.
  Set<int> activeGenerations = const {};
  PokemonSort sort = PokemonSort.numberAsc;

  /// Language of the names shown, which decides the order of the name sorts.
  String languageCode = 'en';

  /// Number of filters and sort orders that differ from the defaults.
  int get activeFilterCount =>
      activeTypes.length +
      activeWeakTo.length +
      activeGenerations.length +
      (sort == PokemonSort.numberAsc ? 0 : 1);

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

  /// Replaces the type, weakness and generation filters and the sort order at
  /// once (the filter sheet's Apply). [weakTo] left out keeps the current
  /// weakness filter.
  Future<void> setSelection({
    required Set<String> types,
    required Set<int> generations,
    required PokemonSort sort,
    Set<String>? weakTo,
  }) {
    activeTypes = Set.of(types);
    activeWeakTo = Set.of(weakTo ?? activeWeakTo);
    activeGenerations = Set.of(generations);
    this.sort = sort;
    notifyListeners();
    return applyFilters();
  }

  Future<void> setGenerationFilters(Set<int> generations) =>
      setSelection(types: activeTypes, generations: generations, sort: sort);

  Future<void> setWeakToFilters(Set<String> weakTo) => setSelection(
    types: activeTypes,
    generations: activeGenerations,
    sort: sort,
    weakTo: weakTo,
  );

  Future<void> setSort(PokemonSort value) => setSelection(
    types: activeTypes,
    generations: activeGenerations,
    sort: value,
  );

  /// Applies search text and type filters to the full list (also the Retry
  /// action after [filterFailed]).
  Future<void> applyFilters() async {
    final request = ++_request;
    final types = activeTypes;
    final weakTo = activeWeakTo;

    if ((types.isNotEmpty || weakTo.isNotEmpty) && !_typeIndex.isLoaded) {
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
    final number = int.tryParse(searchQuery.replaceFirst('#', ''));
    final generationsSelected = activeGenerations;
    filtered = _sorted([
      for (final p in allPokemon)
        if ((searchQuery.isEmpty ||
                _names.matches(p.name, searchQuery) ||
                (number != null && p.id == number)) &&
            (types.isEmpty || _typeIndex.matchesAny(p.name, types)) &&
            (weakTo.isEmpty || _isWeakToAny(p.name, weakTo)) &&
            (generationsSelected.isEmpty ||
                generationsSelected.contains(generationOf(p.id))))
          p,
    ]);
    notifyListeners();
  }

  /// Whether the Pokémon takes more than normal damage from any of [attackers]
  /// (Pokémon whose types are unknown never match).
  bool _isWeakToAny(String name, Set<String> attackers) {
    final types = _typeIndex.typesOf(name);
    if (types == null) return false;
    final profile = TypeChart.defensiveProfile(types);
    return attackers.any((attacker) => (profile[attacker] ?? 1) > 1);
  }

  List<PokemonListItem> _sorted(List<PokemonListItem> items) {
    switch (sort) {
      case PokemonSort.numberAsc:
        return items; // the list is already in Pokédex order
      case PokemonSort.numberDesc:
        return items.reversed.toList();
      case PokemonSort.nameAsc:
        return items..sort(_byName);
      case PokemonSort.nameDesc:
        return items..sort((a, b) => _byName(b, a));
    }
  }

  /// Alphabetical by the name as shown in [languageCode].
  int _byName(PokemonListItem a, PokemonListItem b) => _names
      .display(a.name, languageCode)
      .toLowerCase()
      .compareTo(_names.display(b.name, languageCode).toLowerCase());

  /// Tells the controller which language the names are shown in; sorting by
  /// name follows it.
  void setLanguage(String code) {
    if (code == languageCode) return;
    languageCode = code;
    if (sort == PokemonSort.nameAsc || sort == PokemonSort.nameDesc) {
      applyFilters();
    }
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
