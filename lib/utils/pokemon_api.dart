import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/pokemon.dart';

class PokemonApi {
  static Future<Pokemon?> getPokemonDetails(String name) async {
    try {
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$name');
      final response = await http.get(url);

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      
      return Pokemon.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}