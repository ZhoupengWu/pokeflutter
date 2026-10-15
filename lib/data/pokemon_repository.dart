import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/pokemon_list_item.dart';

/// Single source of the Pokémon list bundled with the app
/// (`assets/pokemonList.json`).
///
/// The asset is read and parsed once; every screen shares the same list.
class PokemonRepository {
  PokemonRepository({Future<String> Function()? loadAsset})
    : _loadAsset = loadAsset ?? (() => rootBundle.loadString(assetPath));

  static const assetPath = 'assets/pokemonList.json';

  final Future<String> Function() _loadAsset;
  Future<List<PokemonListItem>>? _all;

  /// All Pokémon, in Pokédex order. The returned list is unmodifiable.
  Future<List<PokemonListItem>> getAll() => _all ??= _load();

  Future<List<PokemonListItem>> _load() async {
    try {
      final decoded = jsonDecode(await _loadAsset()) as Map<String, dynamic>;
      return List.unmodifiable(
        (decoded['pokemonList'] as List).map(
          (item) => PokemonListItem(
            name: item['name'] as String,
            url: item['url'] as String,
          ),
        ),
      );
    } catch (_) {
      _all = null; // allow a later call to retry
      rethrow;
    }
  }
}
