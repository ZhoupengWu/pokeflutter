import 'package:flutter/foundation.dart';
import '../model/pokemon.dart';
import '../model/pokemon_list_item.dart';
import '../data/pokemon_api.dart';
import '../data/pokemon_repository.dart';

enum CompareSlot { a, b }

/// One of the two Pokémon being compared.
class SlotState {
  /// The entry the user picked (kept after a failed load so it can be retried).
  PokemonListItem? selected;
  Pokemon? pokemon;
  bool isLoading = false;
  bool failed = false;
}

/// State of the Compare tab: the bundled list plus the two slots.
class CompareController extends ChangeNotifier {
  CompareController({PokemonApi? api, PokemonRepository? repository})
    : _api = api ?? PokemonApi.instance,
      _repository = repository ?? PokemonRepository.instance;

  final PokemonApi _api;
  final PokemonRepository _repository;

  List<PokemonListItem> allPokemon = const [];

  final Map<CompareSlot, SlotState> _slots = {
    for (final slot in CompareSlot.values) slot: SlotState(),
  };

  // Picking again while a load is in flight must not let the old one win.
  final Map<CompareSlot, int> _epochs = {
    for (final slot in CompareSlot.values) slot: 0,
  };

  bool _disposed = false;

  SlotState slot(CompareSlot slot) => _slots[slot]!;

  /// True when both Pokémon are loaded and can be compared.
  bool get canCompare =>
      slot(CompareSlot.a).pokemon != null &&
      slot(CompareSlot.b).pokemon != null;

  bool get anyFailed =>
      slot(CompareSlot.a).failed || slot(CompareSlot.b).failed;

  bool get nothingSelected =>
      slot(CompareSlot.a).selected == null &&
      slot(CompareSlot.b).selected == null;

  Future<void> init() async {
    final items = await _repository.getAll();
    if (_disposed) return;
    allPokemon = items;
    notifyListeners();
  }

  /// Puts [item] in [target] and loads its details.
  Future<void> select(CompareSlot target, PokemonListItem item) async {
    final state = slot(target);
    final epoch = _epochs[target] = _epochs[target]! + 1;
    state
      ..selected = item
      ..pokemon = null
      ..isLoading = true
      ..failed = false;
    notifyListeners();

    Pokemon? loaded;
    try {
      loaded = await _api.getPokemonDetails(item.name);
    } on PokemonApiException {
      loaded = null; // the slot offers a retry
    }
    if (_disposed || epoch != _epochs[target]) return;

    state
      ..pokemon = loaded
      ..isLoading = false
      ..failed = loaded == null;
    notifyListeners();
  }

  /// Tries again to load the Pokémon of a slot that failed.
  Future<void> retry(CompareSlot target) {
    final item = slot(target).selected;
    return item == null ? Future.value() : select(target, item);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
