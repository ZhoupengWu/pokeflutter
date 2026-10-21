class Pokemon {
  final int id;

  /// Name of this exact variety (e.g. `charizard-mega-x`), not of its species.
  /// It is also the key used by the cache and by the Pokémon list.
  final String name;

  /// Name of the species this variety belongs to (`charizard` for
  /// `charizard-mega-x`). Evolution data is keyed by species.
  final String speciesName;

  /// Small sprite; empty when PokéAPI has none for this Pokémon.
  final String urlSprite;

  /// Large artwork; falls back to the sprite when there is no artwork.
  final String urlImage;

  /// Large artwork of the shiny variant; null when PokéAPI has none.
  final String? urlShinyImage;
  final double weight; // kg
  final double height; // cm
  final List<String> typesList;
  final List<PokemonStat> stats;
  final List<String> abilities;

  Pokemon({
    required this.id,
    required this.name,
    String? speciesName,
    required this.urlSprite,
    required this.urlImage,
    this.urlShinyImage,
    required this.weight,
    required this.height,
    required this.typesList,
    required this.stats,
    required this.abilities,
  }) : speciesName = speciesName ?? name;

  /// Parses a PokéAPI `/pokemon/{name}` response.
  ///
  /// Image fields are optional in the API (alternate forms often have no
  /// artwork or even no sprite), so they fall back to each other instead of
  /// failing the whole parse.
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as Map<String, dynamic>? ?? const {};
    final other = sprites['other'] as Map<String, dynamic>? ?? const {};
    final sprite = sprites['front_default'] as String?;
    final artwork = _firstNonEmpty([
      _nested(other, 'official-artwork'),
      _nested(other, 'home'),
      sprite,
    ]);

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      speciesName:
          (json['species'] as Map<String, dynamic>?)?['name'] as String?,
      urlSprite: sprite ?? artwork,
      urlImage: artwork,
      urlShinyImage: _firstNonEmptyOrNull([
        _nested(other, 'official-artwork', 'front_shiny'),
        _nested(other, 'home', 'front_shiny'),
        sprites['front_shiny'] as String?,
      ]),
      // PokéAPI uses hectograms and decimetres.
      weight: (json['weight'] as num).toDouble() / 10.0,
      height: (json['height'] as num).toDouble() * 10.0,
      typesList: _parseTypes(json['types'] as List<dynamic>),
      stats: _parseStats(json['stats'] as List<dynamic>),
      abilities: _parseAbilities(json['abilities'] as List<dynamic>),
    );
  }

  /// Compact form kept in the on-disk cache (the API response is far larger
  /// than what the app uses). Read back with [Pokemon.fromCacheJson].
  Map<String, dynamic> toCacheJson() => {
    'id': id,
    'name': name,
    'species': speciesName,
    'sprite': urlSprite,
    'image': urlImage,
    'shinyImage': urlShinyImage,
    'weight': weight,
    'height': height,
    'types': typesList,
    'stats': [
      for (final s in stats) {'name': s.name, 'value': s.value},
    ],
    'abilities': abilities,
  };

  factory Pokemon.fromCacheJson(Map<String, dynamic> json) => Pokemon(
    id: json['id'] as int,
    name: json['name'] as String,
    speciesName: json['species'] as String?,
    urlSprite: json['sprite'] as String,
    urlImage: json['image'] as String,
    // Absent from copies saved by older versions of the app.
    urlShinyImage: json['shinyImage'] as String?,
    weight: (json['weight'] as num).toDouble(),
    height: (json['height'] as num).toDouble(),
    typesList: (json['types'] as List<dynamic>).cast<String>(),
    stats: [
      for (final s in json['stats'] as List<dynamic>)
        PokemonStat(
          name: (s as Map<String, dynamic>)['name'] as String,
          value: s['value'] as int,
        ),
    ],
    abilities: (json['abilities'] as List<dynamic>).cast<String>(),
  );

  static String? _nested(
    Map<String, dynamic> map,
    String key, [
    String image = 'front_default',
  ]) {
    final entry = map[key] as Map<String, dynamic>?;
    return entry?[image] as String?;
  }

  static String? _firstNonEmptyOrNull(List<String?> candidates) {
    final found = _firstNonEmpty(candidates);
    return found.isEmpty ? null : found;
  }

  static String _firstNonEmpty(List<String?> candidates) => candidates
      .firstWhere((c) => c != null && c.isNotEmpty, orElse: () => '')!;

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
