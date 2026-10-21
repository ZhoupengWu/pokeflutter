import 'type_chart.dart';

/// What a team of Pokémon is weak to and what it hits hard, from their types
/// alone (the static [TypeChart]), so it works offline.
///
/// Defence counts, for each attacking type, how many members are weak to it
/// (it deals more than normal damage) and how many resist it (less, or none).
/// Offence looks at the members' own types as attacking types: a defending
/// type is *covered* when at least one of them hits it for double.
class TeamAnalysis {
  TeamAnalysis._({
    required this.size,
    required this.weakCount,
    required this.resistCount,
    required this.covered,
  });

  /// Builds the analysis of a team whose members have these types
  /// (one list of one or two types per member).
  factory TeamAnalysis.of(List<List<String>> memberTypes) {
    final weak = {for (final t in TypeChart.types) t: 0};
    final resist = {for (final t in TypeChart.types) t: 0};
    for (final types in memberTypes) {
      final profile = TypeChart.defensiveProfile(types);
      for (final entry in profile.entries) {
        if (entry.value > 1) weak[entry.key] = weak[entry.key]! + 1;
        if (entry.value < 1) resist[entry.key] = resist[entry.key]! + 1;
      }
    }
    final covered = {
      for (final defender in TypeChart.types)
        if (memberTypes.any(
          (types) => types.any(
            (attacker) => TypeChart.multiplier(attacker, defender) > 1,
          ),
        ))
          defender,
    };
    return TeamAnalysis._(
      size: memberTypes.length,
      weakCount: weak,
      resistCount: resist,
      covered: covered,
    );
  }

  /// Members analysed.
  final int size;

  /// Attacking type → members weak to it.
  final Map<String, int> weakCount;

  /// Attacking type → members that resist it (or are immune).
  final Map<String, int> resistCount;

  /// Defending types hit for double by at least one member's own types.
  final Set<String> covered;

  /// The types that give the team trouble: more members weak than resisting,
  /// the worst first.
  List<String> get weaknesses => _sorted(
    (t) => weakCount[t]! > resistCount[t]!,
    (t) => weakCount[t]! - resistCount[t]!,
  );

  /// The types the team handles well: more members resisting than weak, the
  /// best first.
  List<String> get resistances => _sorted(
    (t) => resistCount[t]! > weakCount[t]!,
    (t) => resistCount[t]! - weakCount[t]!,
  );

  /// Defending types no member hits for double.
  List<String> get uncovered => [
    for (final t in TypeChart.types)
      if (!covered.contains(t)) t,
  ];

  List<String> _sorted(bool Function(String) keep, int Function(String) score) {
    final kept = TypeChart.types.where(keep).toList();
    // Stable: ties keep the PokéAPI order of the types.
    final indexed = [for (final (i, t) in kept.indexed) (i, t)]
      ..sort((a, b) {
        final byScore = score(b.$2).compareTo(score(a.$2));
        return byScore != 0 ? byScore : a.$1.compareTo(b.$1);
      });
    return [for (final (_, t) in indexed) t];
  }
}
