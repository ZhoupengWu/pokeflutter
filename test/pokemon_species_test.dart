import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokeflutter/data/disk_cache.dart';
import 'package:pokeflutter/data/pokemon_api.dart';
import 'package:pokeflutter/data/species_api.dart';
import 'package:pokeflutter/model/pokemon_species.dart';

import 'support/fixtures.dart';

void main() {
  group('PokemonSpecies', () {
    final species = sampleSpecies();

    test('keeps the newest entry of English and Italian only', () {
      expect(species.descriptions.keys, unorderedEquals(['en', 'it']));
      expect(species.categories.keys, unorderedEquals(['en', 'it']));
      expect(species.categories['it'], 'Pokémon Topo');
    });

    test('flows the line breaks and soft hyphens of the games', () {
      expect(
        species.descriptions['en'],
        'It stores electricity in its cheeks. Really.',
      );
      expect(species.descriptions['it'], 'Accumula elettricità nelle guance.');
    });

    test('falls back to English for other languages', () {
      expect(species.descriptionFor('fr'), species.descriptions['en']);
      expect(species.categoryFor('de'), 'Mouse Pokémon');
    });

    test('reads the habitat and the legendary / mythical flags', () {
      expect(species.habitat, 'waters-edge');
      expect(species.isMythical, isTrue);
      expect(species.isLegendary, isFalse);
      expect(species.hasInfo, isTrue);
    });

    test('a bare response is valid and has nothing to show', () {
      final bare = PokemonSpecies.fromApiJson(
        jsonDecode(speciesBody(chainId: 7)) as Map<String, dynamic>,
      );
      expect(
        bare.evolutionChainUrl,
        'https://pokeapi.co/api/v2/evolution-chain/7/',
      );
      expect(bare.hasInfo, isFalse);
      expect(bare.descriptionFor('en'), isNull);
    });

    test('lists the forms, default first', () {
      final withForms = PokemonSpecies.fromApiJson(
        jsonDecode(
              richSpeciesBody(
                varieties: ['charizard', 'charizard-mega-x', 'charizard-gmax'],
              ),
            )
            as Map<String, dynamic>,
      );
      expect(withForms.varieties, [
        'charizard',
        'charizard-mega-x',
        'charizard-gmax',
      ]);

      // The API does not promise the default is listed first.
      final json =
          jsonDecode(richSpeciesBody(varieties: ['a', 'b', 'c']))
              as Map<String, dynamic>;
      final list = json['varieties'] as List<dynamic>;
      list.insert(0, list.removeAt(2)); // c, a, b — with a still the default
      expect(PokemonSpecies.fromApiJson(json).varieties.first, 'a');
    });

    test('a copy saved before forms existed is rejected, to be refetched', () {
      final old = sampleSpecies().toCacheJson()..remove('varieties');
      expect(() => PokemonSpecies.fromCacheJson(old), throwsA(anything));
    });

    test('survives the disk cache round trip', () {
      final copy = PokemonSpecies.fromCacheJson(
        jsonDecode(jsonEncode(species.toCacheJson())) as Map<String, dynamic>,
      );
      expect(copy.descriptions, species.descriptions);
      expect(copy.categories, species.categories);
      expect(copy.habitat, species.habitat);
      expect(copy.isMythical, species.isMythical);
      expect(copy.varieties, species.varieties);
      expect(copy.evolutionChainUrl, species.evolutionChainUrl);
    });
  });

  group('SpeciesApi', () {
    late Directory dir;
    late DiskCache disk;
    var now = DateTime(2026, 1, 1);

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('species');
      disk = DiskCache(directory: () async => dir);
      now = DateTime(2026, 1, 1);
    });
    tearDown(() async {
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    SpeciesApi api(Future<http.Response> Function(http.Request) handler) =>
        SpeciesApi(
          client: MockClient(handler),
          disk: disk,
          now: () => now,
          retryDelay: Duration.zero,
        );

    Future<http.Response> ok(http.Request r) async =>
        http.Response(richSpeciesBody(), 200);

    test('fetches a species once per session', () async {
      var requests = 0;
      final species = api((r) async {
        requests++;
        return ok(r);
      });

      final first = await species.getSpecies('Pikachu');
      await species.getSpecies('pikachu');

      expect(first.categories['en'], 'Mouse Pokémon');
      expect(requests, 1);
    });

    test('a species seen before is served from disk', () async {
      await api(ok).getSpecies('pikachu');

      var requests = 0;
      final again = await api((r) async {
        requests++;
        return ok(r);
      }).getSpecies('pikachu');

      expect(again.habitat, 'waters-edge');
      expect(requests, 0);
    });

    test('an old copy is used when the network is down', () async {
      await api(ok).getSpecies('pikachu');
      now = now.add(const Duration(days: 60));

      final stale = await api(
        (_) async => throw const SocketException('offline'),
      ).getSpecies('pikachu');

      expect(stale.isMythical, isTrue);
    });

    test('an unknown species fails and a later call retries', () async {
      var found = false;
      final species = api(
        (r) async => found ? ok(r) : http.Response('Not Found', 404),
      );

      await expectLater(
        species.getSpecies('missingno'),
        throwsA(
          isA<PokemonApiException>().having(
            (e) => e.type,
            'type',
            PokemonApiErrorType.notFound,
          ),
        ),
      );
      found = true;
      expect((await species.getSpecies('missingno')).hasInfo, isTrue);
    });
  });
}
