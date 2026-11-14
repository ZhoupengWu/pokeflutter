import 'package:flutter/foundation.dart';
import '../core/team_analysis.dart';
import '../core/team_suggestions.dart';
import '../data/pokemon_api.dart';
import '../data/pokemon_repository.dart';
import '../data/pokemon_type_index.dart';
import '../data/team_manager.dart';
import '../model/pokemon.dart';
import '../model/pokemon_list_item.dart';

/// State of the Team tab: the members (from the [TeamManager]), their details
/// (types and sprites, loaded as needed) and the [analysis] built from them.
class TeamController extends ChangeNotifier {
  TeamController({
    required TeamManager team,
    required PokemonApi api,
    required PokemonRepository repository,
    required PokemonTypeIndex typeIndex,
  }) : _team = team,
       _api = api,
       _repository = repository,
       _typeIndex = typeIndex {
    _team.notifier.addListener(_onTeamChanged);
  }

  final TeamManager _team;
  final PokemonApi _api;
  final PokemonRepository _repository;
  final PokemonTypeIndex _typeIndex;

  /// The whole list, for the picker; empty until [init] has run.
  List<PokemonListItem> allPokemon = const [];

  /// Details of the members that have loaded, by API name.
  final Map<String, Pokemon> details = {};

  /// Members whose details could not be loaded.
  final Set<String> failed = {};

  bool _disposed = false;

  List<PokemonListItem> get members => _team.members;
  bool get isFull => _team.isFull;
  bool get isEmpty => _team.members.isEmpty;

  /// The list without the Pokémon already in the team, to pick the next one.
  List<PokemonListItem> get available => [
    for (final p in allPokemon)
      if (!_team.contains(p.name)) p,
  ];

  /// What the members that have loaded are weak to and hit hard.
  TeamAnalysis get analysis => TeamAnalysis.of([
    for (final m in members)
      if (details[m.name] != null) details[m.name]!.typesList,
  ]);

  /// Highest Pokédex number suggested (alternate forms are left out).
  static const _maxSuggestedId = 1025;

  String? _suggestionsKey;
  List<TeamSuggestion> _suggestions = const [];

  /// Pokémon that would patch the team's weaknesses, best first. Empty while
  /// the team is empty or full, or the type index is not available.
  List<TeamSuggestion> get suggestions {
    final loaded = [
      for (final m in members)
        if (details[m.name] != null) details[m.name]!.typesList,
    ];
    if (isFull || loaded.isEmpty || !_typeIndex.isLoaded) return const [];
    final key = [for (final types in loaded) types.join('/')].join(',');
    if (key != _suggestionsKey) {
      _suggestionsKey = key;
      _suggestions = TeamSuggestions.suggest(
        memberTypes: loaded,
        candidates: available.where((p) => p.id <= _maxSuggestedId),
        typesOf: _typeIndex.typesOf,
      );
    }
    return _suggestions;
  }

  /// Members counted in the [analysis].
  int get analysedCount => members.where((m) => details[m.name] != null).length;

  /// Loads the list and the details of the saved team.
  Future<void> init() async {
    allPokemon = await _repository.getAll().catchError(
      (Object _) => const <PokemonListItem>[],
    );
    if (_disposed) return;
    notifyListeners();
    await Future.wait([
      loadDetails(),
      // Suggestions need the types of the whole list; without them the tab
      // simply has none.
      _typeIndex.ensureLoaded().then((_) {
        if (!_disposed) notifyListeners();
      }),
    ]);
  }

  /// Loads the details of the members that have none yet (also the Retry
  /// action after a failure).
  Future<void> loadDetails() async {
    final missing = [
      for (final m in members)
        if (details[m.name] == null) m,
    ];
    failed.removeAll(missing.map((m) => m.name));
    notifyListeners();
    await Future.wait([for (final m in missing) _loadOne(m)]);
    if (_disposed) return;
    notifyListeners();
  }

  Future<void> _loadOne(PokemonListItem member) async {
    try {
      details[member.name] = await _api.getPokemonDetails(member.name);
    } on PokemonApiException {
      failed.add(member.name);
    }
  }

  /// Adds a Pokémon to the team; false when it is full or already in.
  Future<bool> add(PokemonListItem pokemon) => _team.add(pokemon);

  Future<void> remove(PokemonListItem pokemon) => _team.remove(pokemon.name);

  Future<void> clear() => _team.clear();

  void _onTeamChanged() {
    details.removeWhere((name, _) => !_team.contains(name));
    failed.removeWhere((name) => !_team.contains(name));
    notifyListeners();
    loadDetails();
  }

  @override
  void dispose() {
    _disposed = true;
    _team.notifier.removeListener(_onTeamChanged);
    super.dispose();
  }
}
