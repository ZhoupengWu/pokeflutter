class Pokemon {
  final int id;
  final String name;
  final String urlSprite;
  final String urlImage;
  final double weight;
  final double height;
  final List<String> typesList;
  final List<PokemonStat> stats;
  final List<String> abilities;

  Pokemon({
    required this.id,
    required this.name,
    required this.urlSprite,
    required this.urlImage,
    required this.weight,
    required this.height,
    required this.typesList,
    required this.stats,
    required this.abilities,
  });

  Pokemon.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['species']['name'],
      urlSprite = json['sprites']['front_default'],
      urlImage = json['sprites']['other']['official-artwork']['front_default'],
      weight = json['weight'].toDouble() / 10.0,
      height = json['height'].toDouble() * 10.0,
      typesList = _parseTypes(json['types']),
      stats = _parseStats(json['stats']),
      abilities = _parseAbilities(json['abilities']);

  static List<String> _parseTypes(List<dynamic> json) =>
      json.map<String>((e) => e['type']['name'] as String).toList();

  static List<PokemonStat> _parseStats(List<dynamic> json) => json
      .map<PokemonStat>(
        (e) => PokemonStat(
          name: e['stat']['name'] as String,
          value: e['base_stat'] as int,
        ),
      )
      .toList();

  static List<String> _parseAbilities(List<dynamic> json) =>
      json.map<String>((e) => e['ability']['name'] as String).toList();
}

class PokemonStat {
  final String name;
  final int value;

  const PokemonStat({required this.name, required this.value});
}

List<String> getListTypesFromJson(List<dynamic> json) =>
    json.map<String>((e) => e['type']['name'] as String).toList();