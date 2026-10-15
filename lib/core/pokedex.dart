/// How the Pokédex list is ordered.
enum PokemonSort { numberAsc, numberDesc, nameAsc, nameDesc }

/// A game generation, identified by the Pokédex numbers it introduced.
class Generation {
  const Generation(this.number, this.firstId, this.lastId);

  /// 1 … 9.
  final int number;
  final int firstId;
  final int lastId;

  /// "I", "II", … "IX".
  String get roman => const [
    '',
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
    'VII',
    'VIII',
    'IX',
  ][number];

  bool contains(int pokedexNumber) =>
      pokedexNumber >= firstId && pokedexNumber <= lastId;
}

/// The nine generations of the National Pokédex.
const generations = [
  Generation(1, 1, 151),
  Generation(2, 152, 251),
  Generation(3, 252, 386),
  Generation(4, 387, 493),
  Generation(5, 494, 649),
  Generation(6, 650, 721),
  Generation(7, 722, 809),
  Generation(8, 810, 905),
  Generation(9, 906, 1025),
];

/// The generation that introduced the Pokémon numbered [pokedexNumber], or
/// null for alternate forms (numbered from 10001), whose species is not known
/// from the list alone.
int? generationOf(int pokedexNumber) {
  for (final generation in generations) {
    if (generation.contains(pokedexNumber)) return generation.number;
  }
  return null;
}
