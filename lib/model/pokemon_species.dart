/// What PokéAPI's `/pokemon-species/{name}` says about a species, reduced to
/// what the app shows (the raw response is large: every flavour text of every
/// game in every language).
class PokemonSpecies {
  const PokemonSpecies({
    required this.evolutionChainUrl,
    this.descriptions = const {},
    this.categories = const {},
    this.varieties = const [],
    this.habitat,
    this.isLegendary = false,
    this.isMythical = false,
  });

  /// Languages kept; the rest is dropped to keep the disk cache small.
  static const languages = ['en', 'it'];

  /// Where the evolution chain of this species lives.
  final String evolutionChainUrl;

  /// Pokédex entry by language code (`en`, `it`).
  final Map<String, String> descriptions;

  /// The "genus" by language code ("Mouse Pokémon").
  final Map<String, String> categories;

  /// API names of every form of the species (`charizard`, `charizard-mega-x`…),
  /// the default form first.
  final List<String> varieties;

  /// PokéAPI habitat id (`grassland`, `waters-edge`…), if the species has one.
  final String? habitat;
  final bool isLegendary;
  final bool isMythical;

  /// The Pokédex entry in [languageCode], or English, or null.
  String? descriptionFor(String languageCode) =>
      descriptions[languageCode] ?? descriptions['en'];

  /// The category in [languageCode], or English, or null.
  String? categoryFor(String languageCode) =>
      categories[languageCode] ?? categories['en'];

  /// Whether there is anything worth showing on the detail page.
  bool get hasInfo =>
      descriptions.isNotEmpty ||
      categories.isNotEmpty ||
      habitat != null ||
      isLegendary ||
      isMythical;

  /// Parses a PokéAPI response. The evolution chain is required; everything
  /// else is optional so a partial response still gives a usable species.
  factory PokemonSpecies.fromApiJson(Map<String, dynamic> json) {
    final chainUrl =
        (json['evolution_chain'] as Map<String, dynamic>)['url'] as String;

    // Entries are ordered oldest game first: the last one per language wins.
    String languageOf(Map<String, dynamic> entry) =>
        (entry['language'] as Map<String, dynamic>)['name'] as String;
    Map<String, String> collect(String listKey, String textKey, bool clean) {
      final result = <String, String>{};
      for (final raw in (json[listKey] as List<dynamic>? ?? const [])) {
        final entry = raw as Map<String, dynamic>;
        final language = languageOf(entry);
        final text = entry[textKey] as String?;
        if (!languages.contains(language) || text == null) continue;
        final value = clean ? _cleanFlavourText(text) : text.trim();
        if (value.isNotEmpty) result[language] = value;
      }
      return result;
    }

    return PokemonSpecies(
      evolutionChainUrl: chainUrl,
      descriptions: collect('flavor_text_entries', 'flavor_text', true),
      categories: collect('genera', 'genus', false),
      varieties: _parseVarieties(json['varieties'] as List<dynamic>?),
      habitat: (json['habitat'] as Map<String, dynamic>?)?['name'] as String?,
      isLegendary: json['is_legendary'] as bool? ?? false,
      isMythical: json['is_mythical'] as bool? ?? false,
    );
  }

  /// Rebuilds a species stored by [toCacheJson].
  factory PokemonSpecies.fromCacheJson(Map<String, dynamic> json) =>
      PokemonSpecies(
        evolutionChainUrl: json['chain'] as String,
        descriptions: Map<String, String>.from(json['descriptions'] as Map),
        categories: Map<String, String>.from(json['categories'] as Map),
        // Copies saved before forms existed lack it: reading them throws, and
        // the species is fetched again.
        varieties: (json['varieties'] as List<dynamic>).cast<String>(),
        habitat: json['habitat'] as String?,
        isLegendary: json['legendary'] as bool? ?? false,
        isMythical: json['mythical'] as bool? ?? false,
      );

  Map<String, dynamic> toCacheJson() => {
    'chain': evolutionChainUrl,
    'descriptions': descriptions,
    'categories': categories,
    'varieties': varieties,
    'habitat': habitat,
    'legendary': isLegendary,
    'mythical': isMythical,
  };

  static List<String> _parseVarieties(List<dynamic>? raw) {
    final entries = [
      for (final v in raw ?? const <dynamic>[])
        (
          isDefault:
              (v as Map<String, dynamic>)['is_default'] as bool? ?? false,
          name: (v['pokemon'] as Map<String, dynamic>)['name'] as String,
        ),
    ]..sort((a, b) => a.isDefault == b.isDefault ? 0 : (a.isDefault ? -1 : 1));
    return [for (final e in entries) e.name];
  }

  /// Entries come with hard line breaks, form feeds and soft hyphens from the
  /// original games; make them flow as normal text.
  static String _cleanFlavourText(String text) => text
      .replaceAll('­', '')
      .replaceAll(RegExp(r'[\n\f\r]+'), ' ')
      .replaceAll(RegExp(r' {2,}'), ' ')
      .trim();
}
