/// What it takes for a Pokémon to evolve into a given stage.
class EvolutionRequirement {
  /// PokéAPI trigger id: `level-up`, `trade`, `use-item`, `shed`, …
  final String trigger;
  final int? minLevel;

  /// Evolution item (`fire-stone`) for `use-item` evolutions.
  final String? item;
  final String? heldItem;
  final int? minHappiness;

  /// `day` or `night`, when evolution is time-dependent.
  final String? timeOfDay;
  final String? knownMove;

  const EvolutionRequirement({
    required this.trigger,
    this.minLevel,
    this.item,
    this.heldItem,
    this.minHappiness,
    this.timeOfDay,
    this.knownMove,
  });

  /// Parses one PokéAPI `evolution_details` entry.
  factory EvolutionRequirement.fromJson(Map<String, dynamic> json) {
    String? name(String key) =>
        (json[key] as Map<String, dynamic>?)?['name'] as String?;
    String? nonEmpty(String? value) =>
        value == null || value.isEmpty ? null : value;

    return EvolutionRequirement(
      trigger: name('trigger') ?? 'level-up',
      minLevel: json['min_level'] as int?,
      item: name('item'),
      heldItem: name('held_item'),
      minHappiness: json['min_happiness'] as int?,
      timeOfDay: nonEmpty(json['time_of_day'] as String?),
      knownMove: name('known_move'),
    );
  }
}

/// One Pokémon (species) in an evolution chain.
class EvolutionStage {
  /// Species id, which is also the Pokédex number of its default form.
  final int id;

  /// Species name (`charmeleon`).
  final String name;

  /// How the previous stage becomes this one; null for the first stage.
  final EvolutionRequirement? requirement;

  final List<EvolutionStage> evolvesTo;

  const EvolutionStage({
    required this.id,
    required this.name,
    this.requirement,
    this.evolvesTo = const [],
  });

  factory EvolutionStage.fromJson(Map<String, dynamic> json) {
    final species = json['species'] as Map<String, dynamic>;
    final details = (json['evolution_details'] as List<dynamic>? ?? const []);
    return EvolutionStage(
      id: _speciesId(species['url'] as String),
      name: species['name'] as String,
      requirement: details.isEmpty
          ? null
          : EvolutionRequirement.fromJson(
              details.first as Map<String, dynamic>,
            ),
      evolvesTo: [
        for (final next in json['evolves_to'] as List<dynamic>? ?? const [])
          EvolutionStage.fromJson(next as Map<String, dynamic>),
      ],
    );
  }

  static int _speciesId(String url) =>
      int.parse(Uri.parse(url).pathSegments.lastWhere((s) => s.isNotEmpty));
}

/// The whole family tree a Pokémon belongs to.
class EvolutionChain {
  final EvolutionStage root;

  const EvolutionChain(this.root);

  /// Parses a PokéAPI `/evolution-chain/{id}` response.
  factory EvolutionChain.fromJson(Map<String, dynamic> json) => EvolutionChain(
    EvolutionStage.fromJson(json['chain'] as Map<String, dynamic>),
  );

  /// True when the Pokémon neither evolves nor comes from an evolution.
  bool get isSingleStage => root.evolvesTo.isEmpty;

  /// The stages grouped by distance from the first one:
  /// `[[eevee], [vaporeon, jolteon, …]]`.
  List<List<EvolutionStage>> get levels {
    final result = <List<EvolutionStage>>[];
    var current = [root];
    while (current.isNotEmpty) {
      result.add(current);
      current = [for (final stage in current) ...stage.evolvesTo];
    }
    return result;
  }
}
