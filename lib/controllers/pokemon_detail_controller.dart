import 'package:flutter/foundation.dart';
import '../model/evolution.dart';
import '../model/pokemon.dart';
import '../model/pokemon_list_item.dart';
import '../model/pokemon_species.dart';
import '../data/evolution_api.dart';
import '../data/pokemon_api.dart';
import '../data/pokemon_repository.dart';
import '../data/species_api.dart';

enum LoadStatus { loading, loaded, failed }

/// Loads everything the detail page shows for one Pokémon: its stats first,
/// then the species information and the evolution chain (which can fail on
/// their own without hiding the stats).
class PokemonDetailController extends ChangeNotifier {
  PokemonDetailController({
    required this.item,
    required PokemonApi api,
    required EvolutionApi evolutionApi,
    required SpeciesApi speciesApi,
    required PokemonRepository repository,
  }) : _api = api,
       _evolutionApi = evolutionApi,
       _speciesApi = speciesApi,
       _repository = repository;

  /// The entry that was opened (from the list, favourites, an evolution…).
  final PokemonListItem item;

  final PokemonApi _api;
  final EvolutionApi _evolutionApi;
  final SpeciesApi _speciesApi;
  final PokemonRepository _repository;

  LoadStatus status = LoadStatus.loading;
  Pokemon? pokemon;

  /// Pokédex entry, category and habitat. Null until loaded, and when they
  /// could not be (the page then simply leaves the section out).
  PokemonSpecies? species;

  LoadStatus evolutionStatus = LoadStatus.loading;
  EvolutionChain? evolution;

  /// The bundled list, used to open the Pokémon of an evolution chain.
  List<PokemonListItem> _all = const [];

  bool _disposed = false;

  /// Loads (or reloads) the details and then the evolution chain.
  Future<void> load() async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      final result = await _api.getPokemonDetails(item.name);
      if (_disposed) return;
      pokemon = result;
      status = LoadStatus.loaded;
    } on PokemonApiException {
      if (_disposed) return;
      status = LoadStatus.failed;
    }
    notifyListeners();
    if (status == LoadStatus.loaded) {
      await Future.wait([loadSpecies(), loadEvolution()]);
    }
  }

  /// Loads the species information; a failure just leaves [species] null.
  Future<void> loadSpecies() async {
    final current = pokemon;
    if (current == null) return;
    try {
      final result = await _speciesApi.getSpecies(current.speciesName);
      if (_disposed) return;
      species = result;
      notifyListeners();
    } on PokemonApiException {
      // Optional information: nothing to show.
    }
  }

  /// Loads (or retries) the evolution chain of the current Pokémon.
  Future<void> loadEvolution() async {
    final current = pokemon;
    if (current == null) return;
    evolutionStatus = LoadStatus.loading;
    notifyListeners();
    try {
      final chain = await _evolutionApi.getChain(current.speciesName);
      // Without the list the chain is still shown, just not tappable.
      final all = await _repository.getAll().catchError(
        (Object _) => const <PokemonListItem>[],
      );
      if (_disposed) return;
      evolution = chain;
      _all = all;
      evolutionStatus = LoadStatus.loaded;
    } on PokemonApiException {
      if (_disposed) return;
      evolutionStatus = LoadStatus.failed;
    }
    notifyListeners();
  }

  /// The list entry of the default form of the species numbered [speciesId],
  /// or null when the bundled list does not have it.
  PokemonListItem? itemForSpecies(int speciesId) {
    for (final candidate in _all) {
      if (candidate.id == speciesId) return candidate;
    }
    return null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
