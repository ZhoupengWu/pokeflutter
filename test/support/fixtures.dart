import 'dart:convert';
import 'package:pokeflutter/model/pokemon_species.dart';

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
  String? shiny = 'https://img/shiny.png',
  Map<String, int>? stats,
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
      'official-artwork': {'front_default': artwork, 'front_shiny': shiny},
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
    for (final entry in (stats ?? const {'hp': 78, 'attack': 84}).entries)
      {
        'base_stat': entry.value,
        'stat': {'name': entry.key},
      },
  ],
  'abilities': [
    {
      'ability': {'name': 'blaze'},
    },
  ],
};

String pokemonBody(Map<String, dynamic> json) => jsonEncode(json);

/// A PokéAPI `/pokemon-species/{name}` body pointing at chain [chainId].
String speciesBody({int chainId = 1}) => jsonEncode({
  'evolution_chain': {
    'url': 'https://pokeapi.co/api/v2/evolution-chain/$chainId/',
  },
});

Map<String, dynamic> _stage(
  String name,
  int id, {
  Map<String, dynamic>? details,
  List<Map<String, dynamic>> next = const [],
}) => {
  'species': {
    'name': name,
    'url': 'https://pokeapi.co/api/v2/pokemon-species/$id/',
  },
  'evolution_details': [?details],
  'evolves_to': next,
};

Map<String, dynamic> _details({
  int? level,
  String trigger = 'level-up',
  String? item,
  int? happiness,
}) => {
  'min_level': level,
  'trigger': {'name': trigger},
  'item': item == null ? null : {'name': item},
  'held_item': null,
  'min_happiness': happiness,
  'time_of_day': '',
  'known_move': null,
};

/// Bulbasaur → Ivysaur (level 16) → Venusaur (level 32).
String bulbasaurChainBody() => jsonEncode({
  'id': 1,
  'chain': _stage(
    'bulbasaur',
    1,
    next: [
      _stage(
        'ivysaur',
        2,
        details: _details(level: 16),
        next: [_stage('venusaur', 3, details: _details(level: 32))],
      ),
    ],
  ),
});

/// Eevee with three branches: a stone, friendship and a level.
String eeveeChainBody() => jsonEncode({
  'id': 67,
  'chain': _stage(
    'eevee',
    133,
    next: [
      _stage(
        'vaporeon',
        134,
        details: _details(trigger: 'use-item', item: 'water-stone'),
      ),
      _stage('espeon', 196, details: _details(happiness: 160)),
      _stage('leafeon', 470, details: _details(level: 20)),
    ],
  ),
});

/// A Pokémon that does not evolve.
String singleStageChainBody() =>
    jsonEncode({'id': 99, 'chain': _stage('tauros', 128)});

/// A full `/pokemon-species/{name}` body: old and new entries in several
/// languages, as the real API returns them (oldest game first).
/// [varieties] are the forms of the species, default form first.
String richSpeciesBody({int chainId = 1, List<String> varieties = const []}) =>
    jsonEncode({
      'evolution_chain': {
        'url': 'https://pokeapi.co/api/v2/evolution-chain/$chainId/',
      },
      'is_legendary': false,
      'is_mythical': true,
      'varieties': [
        for (final (i, name) in varieties.indexed)
          {
            'is_default': i == 0,
            'pokemon': {'name': name},
          },
      ],
      'habitat': {'name': 'waters-edge'},
      'flavor_text_entries': [
        {
          'flavor_text': 'Old English entry.',
          'language': {'name': 'en'},
        },
        {
          'flavor_text': 'Ein deutscher Eintrag.',
          'language': {'name': 'de'},
        },
        {
          'flavor_text': 'Vecchia scheda.',
          'language': {'name': 'it'},
        },
        {
          'flavor_text':
              'It stores\nelectricity in\fits ch\u00adeeks.  Really.',
          'language': {'name': 'en'},
        },
        {
          'flavor_text': 'Accumula elettricità\nnelle guance.',
          'language': {'name': 'it'},
        },
      ],
      'genera': [
        {
          'genus': 'Mouse Pokémon',
          'language': {'name': 'en'},
        },
        {
          'genus': 'Pokémon Topo',
          'language': {'name': 'it'},
        },
        {
          'genus': 'Mauspokémon',
          'language': {'name': 'de'},
        },
      ],
    });

/// A species with an entry in English and Italian.
PokemonSpecies sampleSpecies() => PokemonSpecies.fromApiJson(
  jsonDecode(richSpeciesBody()) as Map<String, dynamic>,
);
