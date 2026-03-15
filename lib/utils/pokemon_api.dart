import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/pokemon.dart';
import 'pokemon_cache.dart';

class PokemonApi {
  /// Returns Pokémon details for [name].
  /// Checks [PokemonCache] first — only hits the network on a cache miss.
  /// Returns null on any network or parse error.
  static Future<Pokemon?> getPokemonDetails(String name) async {
    final cached = PokemonCache.instance.get(name);
    if (cached != null) return cached;

    try {
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$name');
      final response = await http.get(url);

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final pokemon = Pokemon.fromJson(decoded);

      PokemonCache.instance.set(pokemon);
      return pokemon;
    } catch (_) {
      return null;
    }
  }
}