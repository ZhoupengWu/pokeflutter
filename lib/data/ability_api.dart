import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/pokemon_species.dart';
import 'cached_resource.dart';
import 'disk_cache.dart';
import 'network_status.dart';
import 'pokeapi_client.dart';
import 'pokemon_api.dart';

/// Fetches the translated names of abilities from PokéAPI (`/ability/{id}`).
///
/// Only English and Italian are kept, and results are cached per ability in
/// memory and, with a [DiskCache], across restarts (a stale copy is used when
/// the network fails). Names never change in practice, so they are kept for a
/// long time.
class AbilityApi {
  AbilityApi({
    http.Client? client,
    DiskCache? disk,
    NetworkStatus? status,
    Duration maxAge = const Duration(days: 180),
    DateTime Function()? now,
    Duration timeout = const Duration(seconds: 15),
    Duration retryDelay = const Duration(milliseconds: 500),
    int maxAttempts = 2,
  }) : _http = PokeApiClient(
         client: client,
         timeout: timeout,
         retryDelay: retryDelay,
         maxAttempts: maxAttempts,
         status: status,
       ) {
    _resource = CachedResource<Map<String, String>>(
      prefix: 'ability',
      disk: disk,
      maxAge: maxAge,
      now: now,
      fetch: _fetch,
      decode: (stored) => Map<String, String>.from(jsonDecode(stored) as Map),
    );
  }

  final PokeApiClient _http;
  late final CachedResource<Map<String, String>> _resource;

  /// The name of the ability [id] (`lightning-rod`) by language code
  /// (`en`, `it`). Throws [PokemonApiException] on failure.
  Future<Map<String, String>> getNames(String id) => _resource.get(id);

  Future<Fetched<Map<String, String>>> _fetch(String key) async {
    final json = await _http.getJson(
      '${PokeApiClient.baseUrl}/ability/$key',
      notFoundMessage: 'Unknown ability "$key"',
    );
    try {
      final names = <String, String>{};
      for (final raw in json['names'] as List<dynamic>) {
        final entry = raw as Map<String, dynamic>;
        final language =
            (entry['language'] as Map<String, dynamic>)['name'] as String;
        final name = entry['name'] as String?;
        if (PokemonSpecies.languages.contains(language) &&
            name != null &&
            name.isNotEmpty) {
          names[language] = name;
        }
      }
      return (value: names, stored: jsonEncode(names));
    } catch (e) {
      throw PokemonApiException(PokemonApiErrorType.parse, '$e');
    }
  }
}
