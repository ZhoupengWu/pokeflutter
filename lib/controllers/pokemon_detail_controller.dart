import 'package:flutter/foundation.dart';
import '../model/evolution.dart';
import '../model/pokemon.dart';
import '../model/pokemon_list_item.dart';
import '../data/evolution_api.dart';
import '../data/pokemon_api.dart';
import '../data/pokemon_repository.dart';

enum LoadStatus { loading, loaded, failed }

/// Loads everything the detail page shows for one Pokémon: its stats first,
/// then the evolution chain (which can fail on its own without hiding the
/// stats).
class PokemonDetailController extends ChangeNotifier {
  PokemonDetailController({
    required this.item,
    PokemonApi? api,
    EvolutionApi? evolutionApi,
    PokemonRepository? repository,
  }) : _api = api ?? PokemonApi.instance,
       _evolutionApi = evolutionApi ?? EvolutionApi.instance,
       _repository = repository ?? PokemonRepository.instance;

  /// The entry that was opened (from the list, favourites, an evolution…).
  final PokemonListItem item;

  final PokemonApi _api;
  final EvolutionApi _evolutionApi;
  final PokemonRepository _repository;

  LoadStatus status = LoadStatus.loading;
  Pokemon? pokemon;

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
    if (status == LoadStatus.loaded) await loadEvolution();
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
