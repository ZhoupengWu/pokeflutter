/// Damage multipliers between the 18 Pokémon types (generation 6 onwards).
///
/// The chart is static data, so type matchups work offline and cost no
/// API calls.
class TypeChart {
  const TypeChart._();

  /// Every type id, in the order PokéAPI lists them.
  static const types = [
    'normal',
    'fire',
    'water',
    'electric',
    'grass',
    'ice',
    'fighting',
    'poison',
    'ground',
    'flying',
    'psychic',
    'bug',
    'rock',
    'ghost',
    'dragon',
    'dark',
    'steel',
    'fairy',
  ];

  // attacker → (defenders hit for double, defenders that resist, immune ones)
  static const _attack = <String, (List<String>, List<String>, List<String>)>{
    'normal': ([], ['rock', 'steel'], ['ghost']),
    'fire': (
      ['grass', 'ice', 'bug', 'steel'],
      ['fire', 'water', 'rock', 'dragon'],
      [],
    ),
    'water': (['fire', 'ground', 'rock'], ['water', 'grass', 'dragon'], []),
    'electric': (
      ['water', 'flying'],
      ['electric', 'grass', 'dragon'],
      ['ground'],
    ),
    'grass': (
      ['water', 'ground', 'rock'],
      ['fire', 'grass', 'poison', 'flying', 'bug', 'dragon', 'steel'],
      [],
    ),
    'ice': (
      ['grass', 'ground', 'flying', 'dragon'],
      ['fire', 'water', 'ice', 'steel'],
      [],
    ),
    'fighting': (
      ['normal', 'ice', 'rock', 'dark', 'steel'],
      ['poison', 'flying', 'psychic', 'bug', 'fairy'],
      ['ghost'],
    ),
    'poison': (
      ['grass', 'fairy'],
      ['poison', 'ground', 'rock', 'ghost'],
      ['steel'],
    ),
    'ground': (
      ['fire', 'electric', 'poison', 'rock', 'steel'],
      ['grass', 'bug'],
      ['flying'],
    ),
    'flying': (['grass', 'fighting', 'bug'], ['electric', 'rock', 'steel'], []),
    'psychic': (['fighting', 'poison'], ['psychic', 'steel'], ['dark']),
    'bug': (
      ['grass', 'psychic', 'dark'],
      ['fire', 'fighting', 'poison', 'flying', 'ghost', 'steel', 'fairy'],
      [],
    ),
    'rock': (
      ['fire', 'ice', 'flying', 'bug'],
      ['fighting', 'ground', 'steel'],
      [],
    ),
    'ghost': (['psychic', 'ghost'], ['dark'], ['normal']),
    'dragon': (['dragon'], ['steel'], ['fairy']),
    'dark': (['psychic', 'ghost'], ['fighting', 'dark', 'fairy'], []),
    'steel': (
      ['ice', 'rock', 'fairy'],
      ['fire', 'water', 'electric', 'steel'],
      [],
    ),
    'fairy': (['fighting', 'dragon', 'dark'], ['fire', 'poison', 'steel'], []),
  };

  /// Multiplier of an [attacker]-type move against one [defender] type:
  /// 0, 0.5, 1 or 2. Unknown types count as neutral.
  static double multiplier(String attacker, String defender) {
    final entry = _attack[attacker.toLowerCase()];
    if (entry == null) return 1;
    final target = defender.toLowerCase();
    if (entry.$3.contains(target)) return 0;
    if (entry.$1.contains(target)) return 2;
    if (entry.$2.contains(target)) return 0.5;
    return 1;
  }

  /// Damage each attacking type deals to a Pokémon with the given
  /// [defenderTypes] (one or two): 0, 0.25, 0.5, 1, 2 or 4.
  static Map<String, double> defensiveProfile(List<String> defenderTypes) => {
    for (final attacker in types)
      attacker: defenderTypes.fold<double>(
        1,
        (product, defender) => product * multiplier(attacker, defender),
      ),
  };

  /// The attacking types in [profile] that deal exactly [value] damage.
  static List<String> typesWithMultiplier(
    Map<String, double> profile,
    double value,
  ) => [
    for (final entry in profile.entries)
      if (entry.value == value) entry.key,
  ];
}
