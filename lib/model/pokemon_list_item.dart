class PokemonListItem {
  final String name;
  final String url;

  PokemonListItem({required this.name, required this.url});

  /// Pokédex id, taken from the item URL (`.../pokemon/{id}/`).
  /// Alternate forms have ids above 10000.
  late final int id = int.parse(
    Uri.parse(url).pathSegments.lastWhere((s) => s.isNotEmpty),
  );

  /// Small sprite served by the PokéAPI sprites repository. Known from the
  /// list alone, so the grid needs no per-Pokémon API call.
  String get spriteUrl => spriteUrlFor(id);

  /// Sprite of the Pokémon with Pokédex number [id].
  static String spriteUrlFor(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
}
