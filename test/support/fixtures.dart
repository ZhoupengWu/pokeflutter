import 'dart:convert';

/// Builds a minimal PokéAPI `/pokemon/{name}` response body.
///
/// [sprite] and [artwork] can be set to `null` to mimic alternate forms that
/// have no images.
Map<String, dynamic> pokemonJson({
  int id = 6,
  String name = 'charizard',
  String speciesName = 'charizard',
  List<String> types = const ['fire', 'flying'],
  String? sprite = 'https://img/sprite.png',
  String? artwork = 'https://img/artwork.png',
  Map<String, dynamic>? extraOther,
}) => {
  'id': id,
  'name': name,
  'species': {'name': speciesName},
  'weight': 905,
  'height': 17,
  'sprites': {
    'front_default': sprite,
    'other': {
      'official-artwork': {'front_default': artwork},
      ...?extraOther,
    },
  },
  'types': [
    for (var i = 0; i < types.length; i++)
      {
        'slot': i + 1,
        'type': {'name': types[i]},
      },
  ],
  'stats': [
    {
      'base_stat': 78,
      'stat': {'name': 'hp'},
    },
    {
      'base_stat': 84,
      'stat': {'name': 'attack'},
    },
  ],
  'abilities': [
    {
      'ability': {'name': 'blaze'},
    },
  ],
};

String pokemonBody(Map<String, dynamic> json) => jsonEncode(json);
