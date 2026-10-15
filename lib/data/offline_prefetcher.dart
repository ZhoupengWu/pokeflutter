import 'dart:async';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../model/pokemon_list_item.dart';
import 'ability_api.dart';
import 'evolution_api.dart';
import 'pokemon_api.dart';
import 'species_api.dart';

/// How a [OfflinePrefetcher.prefetch] run went.
class PrefetchResult {
  const PrefetchResult({required this.total, required this.failed});

  /// Pokémon asked for.
  final int total;

  /// Pokémon for which something could not be downloaded.
  final int failed;

  bool get isComplete => failed == 0;
}

/// Downloads everything the detail page needs for some Pokémon — the details,
/// species entry, evolution chain, ability names and both images — so they work
/// without a connection. Everything lands in the same caches the app already
/// uses while browsing.
class OfflinePrefetcher {
  OfflinePrefetcher({
    required PokemonApi pokemon,
    required SpeciesApi species,
    required EvolutionApi evolution,
    required AbilityApi abilities,
    Future<void> Function(String url)? downloadImage,
    this.concurrency = 3,
  }) : _pokemon = pokemon,
       _species = species,
       _evolution = evolution,
       _abilities = abilities,
       _downloadImage = downloadImage ?? _noImages;

  /// The production prefetcher: images go to `cached_network_image`'s cache.
  factory OfflinePrefetcher.production({
    required PokemonApi pokemon,
    required SpeciesApi species,
    required EvolutionApi evolution,
    required AbilityApi abilities,
  }) => OfflinePrefetcher(
    pokemon: pokemon,
    species: species,
    evolution: evolution,
    abilities: abilities,
    downloadImage: (url) async {
      await DefaultCacheManager().getSingleFile(url);
    },
  );

  final PokemonApi _pokemon;
  final SpeciesApi _species;
  final EvolutionApi _evolution;
  final AbilityApi _abilities;
  final Future<void> Function(String url) _downloadImage;

  /// Pokémon downloaded at the same time.
  final int concurrency;

  static Future<void> _noImages(String url) async {}

  /// Downloads [items], calling [onProgress] with how many are done so far.
  /// Never throws: a Pokémon that cannot be fully downloaded is counted in
  /// [PrefetchResult.failed] and the rest carry on.
  Future<PrefetchResult> prefetch(
    List<PokemonListItem> items, {
    void Function(int done, int total)? onProgress,
  }) async {
    var next = 0;
    var done = 0;
    var failed = 0;

    Future<void> worker() async {
      while (next < items.length) {
        final item = items[next++];
        if (!await _one(item)) failed++;
        onProgress?.call(++done, items.length);
      }
    }

    onProgress?.call(0, items.length);
    await Future.wait([
      for (var i = 0; i < concurrency && i < items.length; i++) worker(),
    ]);
    return PrefetchResult(total: items.length, failed: failed);
  }

  /// Whether everything for [item] was downloaded.
  Future<bool> _one(PokemonListItem item) async {
    try {
      final pokemon = await _pokemon.getPokemonDetails(item.name);
      await Future.wait([
        _species.getSpecies(pokemon.speciesName),
        _evolution.getChain(pokemon.speciesName),
        for (final ability in pokemon.abilities) _abilities.getNames(ability),
        for (final url in {pokemon.urlSprite, pokemon.urlImage})
          if (url.isNotEmpty) _downloadImage(url),
      ]);
      return true;
    } catch (_) {
      return false;
    }
  }
}
