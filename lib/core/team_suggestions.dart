import '../model/pokemon_list_item.dart';
import 'team_analysis.dart';
import 'type_chart.dart';

/// A Pokémon that would improve a team, and how.
class TeamSuggestion {
  const TeamSuggestion({
    required this.pokemon,
    required this.types,
    required this.resists,
    required this.newCoverage,
    required this.gain,
  });

  final PokemonListItem pokemon;
  final List<String> types;

  /// Types the team is weak to that this Pokémon resists (or is immune to).
  final List<String> resists;

  /// Types no member hit for double before that its own types do.
  final List<String> newCoverage;

  /// How much the team improves (higher is better); see [TeamSuggestions].
  final double gain;
}

/// Picks Pokémon that patch a team's holes, from types alone (so it works
/// offline).
///
/// The score of adding a candidate is the drop in the team's *trouble* (the
/// sum, over attacking types, of how many more members are weak than resist)
/// plus half a point for each type the team newly hits for double. Only
/// candidates that improve the team count, one per combination of types
/// (the lowest Pokédex number), best first.
class TeamSuggestions {
  const TeamSuggestions._();

  static double _trouble(TeamAnalysis analysis) {
    var total = 0;
    for (final type in TypeChart.types) {
      final net = analysis.weakCount[type]! - analysis.resistCount[type]!;
      if (net > 0) total += net;
    }
    return total.toDouble();
  }

  /// The best [limit] additions to a team whose members have [memberTypes],
  /// among [candidates] (whose types [typesOf] gives; unknown ones are
  /// skipped).
  static List<TeamSuggestion> suggest({
    required List<List<String>> memberTypes,
    required Iterable<PokemonListItem> candidates,
    required List<String>? Function(String name) typesOf,
    int limit = 5,
  }) {
    if (memberTypes.isEmpty) return const [];
    final before = TeamAnalysis.of(memberTypes);
    final troubleBefore = _trouble(before);

    final scored = <TeamSuggestion>[];
    for (final candidate in candidates) {
      final types = typesOf(candidate.name);
      if (types == null || types.isEmpty) continue;
      final after = TeamAnalysis.of([...memberTypes, types]);
      final newCoverage = [
        for (final t in TypeChart.types)
          if (after.covered.contains(t) && !before.covered.contains(t)) t,
      ];
      final gain = troubleBefore - _trouble(after) + newCoverage.length * 0.5;
      if (gain <= 0) continue;
      final profile = TypeChart.defensiveProfile(types);
      scored.add(
        TeamSuggestion(
          pokemon: candidate,
          types: types,
          resists: [
            for (final t in before.weaknesses)
              if (profile[t]! < 1) t,
          ],
          newCoverage: newCoverage,
          gain: gain,
        ),
      );
    }

    scored.sort((a, b) {
      final byGain = b.gain.compareTo(a.gain);
      return byGain != 0 ? byGain : a.pokemon.id.compareTo(b.pokemon.id);
    });

    final seen = <String>{};
    final picked = <TeamSuggestion>[];
    for (final s in scored) {
      final key = ([...s.types]..sort()).join('/');
      if (!seen.add(key)) continue;
      picked.add(s);
      if (picked.length == limit) break;
    }
    return picked;
  }
}
