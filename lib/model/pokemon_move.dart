/// How a Pokémon learns a move (the methods the app shows).
enum MoveMethod {
  levelUp('level-up', 'l'),
  machine('machine', 'm'),
  egg('egg', 'e'),
  tutor('tutor', 't');

  const MoveMethod(this.apiName, this.code);

  /// PokéAPI's `move_learn_method` name.
  final String apiName;

  /// One letter, to keep the on-disk copy small.
  final String code;

  static MoveMethod? fromApiName(String name) {
    for (final method in values) {
      if (method.apiName == name) return method;
    }
    return null;
  }

  static MoveMethod? fromCode(String code) {
    for (final method in values) {
      if (method.code == code) return method;
    }
    return null;
  }
}

/// One move a Pokémon can learn, in the most recent games it appears in.
class PokemonMove {
  const PokemonMove({required this.name, required this.method, this.level = 0});

  /// PokéAPI move id (`vine-whip`); move names are not translated.
  final String name;
  final MoveMethod method;

  /// Level it is learned at; 0 unless [method] is [MoveMethod.levelUp].
  final int level;

  /// Game versions, oldest first. PokéAPI does not rank them, and a move list
  /// is only meaningful within one, so the app shows the newest one a Pokémon
  /// has moves in. Unknown (newer) groups are ignored until added here.
  static const versionGroupOrder = [
    'red-blue',
    'yellow',
    'gold-silver',
    'crystal',
    'ruby-sapphire',
    'emerald',
    'firered-leafgreen',
    'diamond-pearl',
    'platinum',
    'heartgold-soulsilver',
    'black-white',
    'black-2-white-2',
    'x-y',
    'omega-ruby-alpha-sapphire',
    'sun-moon',
    'ultra-sun-ultra-moon',
    'lets-go-pikachu-lets-go-eevee',
    'sword-shield',
    'brilliant-diamond-and-shining-pearl',
    'legends-arceus',
    'scarlet-violet',
  ];

  /// Reads the `moves` array of a PokéAPI `/pokemon/{name}` response: the
  /// moves of the newest version group the Pokémon has any moves in.
  static List<PokemonMove> parseAll(List<dynamic> json) {
    var newest = -1;
    for (final entry in json) {
      for (final detail in (entry as Map)['version_group_details'] as List) {
        final rank = versionGroupOrder.indexOf(
          (detail as Map)['version_group']['name'] as String,
        );
        if (rank > newest) newest = rank;
      }
    }
    if (newest < 0) return const [];
    final group = versionGroupOrder[newest];

    final moves = <PokemonMove>[];
    for (final entry in json) {
      final name = (entry as Map)['move']['name'] as String;
      for (final detail in entry['version_group_details'] as List) {
        if (detail['version_group']['name'] != group) continue;
        final method = MoveMethod.fromApiName(
          detail['move_learn_method']['name'] as String,
        );
        if (method == null) continue;
        moves.add(
          PokemonMove(
            name: name,
            method: method,
            level: method == MoveMethod.levelUp
                ? (detail['level_learned_at'] as num?)?.toInt() ?? 0
                : 0,
          ),
        );
      }
    }
    return moves;
  }

  /// `[name, method code, level]`.
  List<Object> toCacheJson() => [name, method.code, level];

  static PokemonMove? fromCacheJson(Object? json) {
    if (json is! List || json.length < 3) return null;
    final method = MoveMethod.fromCode(json[1] as String);
    if (method == null) return null;
    return PokemonMove(
      name: json[0] as String,
      method: method,
      level: (json[2] as num).toInt(),
    );
  }
}
