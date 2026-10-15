import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokeflutter/data/disk_cache.dart';
import 'package:pokeflutter/data/evolution_api.dart';
import 'package:pokeflutter/data/network_status.dart';
import 'package:pokeflutter/data/pokemon_api.dart';
import 'package:pokeflutter/data/pokemon_cache.dart';
import 'package:pokeflutter/data/pokemon_type_index.dart';
import 'package:pokeflutter/model/pokemon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fixtures.dart';

void main() {
  late Directory dir;
  late DiskCache disk;
  var now = DateTime(2026, 6, 1);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('offline_cache');
    disk = DiskCache(directory: () async => dir);
    now = DateTime(2026, 6, 1);
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  group('Pokemon cache JSON', () {
    test('survives a round trip', () {
      final original = Pokemon.fromJson(
        pokemonJson(name: 'charizard-mega-x', speciesName: 'charizard'),
      );

      final copy = Pokemon.fromCacheJson(original.toCacheJson());

      expect(copy.id, original.id);
      expect(copy.name, 'charizard-mega-x');
      expect(copy.speciesName, 'charizard');
      expect(copy.typesList, ['fire', 'flying']);
      expect(copy.weight, original.weight);
      expect(copy.height, original.height);
      expect(copy.urlImage, original.urlImage);
      expect(copy.urlSprite, original.urlSprite);
      expect(copy.abilities, ['blaze']);
      expect(copy.stats.map((s) => (s.name, s.value)), [
        ('hp', 78),
        ('attack', 84),
      ]);
    });
  });

  group('PokemonApi with a disk cache', () {
    PokemonApi api(
      Future<http.Response> Function(http.Request) handler, {
      NetworkStatus? status,
    }) => PokemonApi(
      client: MockClient(handler),
      cache: PokemonCache(),
      disk: disk,
      status: status,
      now: () => now,
      retryDelay: Duration.zero,
    );

    http.Response ok() => http.Response(pokemonBody(pokemonJson()), 200);

    test(
      'a Pokémon seen before is served from disk without the network',
      () async {
        await api((_) async => ok()).getPokemonDetails('charizard');

        var requests = 0;
        final later = api((_) async {
          requests++;
          return ok();
        }); // a new app run: empty memory cache, same disk
        final pokemon = await later.getPokemonDetails('charizard');

        expect(pokemon.name, 'charizard');
        expect(pokemon.typesList, ['fire', 'flying']);
        expect(requests, 0);
      },
    );

    test('an old copy is refreshed from the network', () async {
      await api((_) async => ok()).getPokemonDetails('charizard');
      now = now.add(const Duration(days: 31));

      var requests = 0;
      await api((_) async {
        requests++;
        return ok();
      }).getPokemonDetails('charizard');

      expect(requests, 1);
    });

    test('an old copy is still used when the network is down', () async {
      await api((_) async => ok()).getPokemonDetails('charizard');
      now = now.add(const Duration(days: 90));

      final offline = api((_) async => throw const SocketException('offline'));
      final pokemon = await offline.getPokemonDetails('charizard');

      expect(pokemon.name, 'charizard');
    });

    test('a Pokémon never seen fails while offline', () async {
      final offline = api((_) async => throw const SocketException('offline'));

      await expectLater(
        offline.getPokemonDetails('mew'),
        throwsA(
          isA<PokemonApiException>().having(
            (e) => e.type,
            'type',
            PokemonApiErrorType.network,
          ),
        ),
      );
    });

    test('a 404 is not hidden by an old copy', () async {
      await api((_) async => ok()).getPokemonDetails('charizard');
      now = now.add(const Duration(days: 90));

      await expectLater(
        api((_) async => http.Response('', 404)).getPokemonDetails('charizard'),
        throwsA(
          isA<PokemonApiException>().having(
            (e) => e.type,
            'type',
            PokemonApiErrorType.notFound,
          ),
        ),
      );
    });

    test('an unreadable disk entry is ignored', () async {
      await disk.write('pokemon-charizard', '{"unexpected": true}', now: now);

      final pokemon = await api(
        (_) async => ok(),
      ).getPokemonDetails('charizard');

      expect(pokemon.name, 'charizard');
    });

    test('reports whether PokéAPI could be reached', () async {
      final status = NetworkStatus();
      var online = true;
      final client = api(
        (_) async => online ? ok() : throw const SocketException('offline'),
        status: status,
      );

      await expectLater(() async {
        online = false;
        await client.getPokemonDetails('pikachu');
      }(), throwsA(isA<PokemonApiException>()));
      expect(status.isOffline, isTrue);

      online = true;
      await client.getPokemonDetails('pikachu');
      expect(status.isOffline, isFalse);
    });
  });

  group('EvolutionApi with a disk cache', () {
    http.Response handle(http.Request r) => switch (r.url.path) {
      '/api/v2/pokemon-species/ivysaur' => http.Response(speciesBody(), 200),
      '/api/v2/evolution-chain/1/' => http.Response(bulbasaurChainBody(), 200),
      _ => http.Response('', 404),
    };

    EvolutionApi api(Future<http.Response> Function(http.Request) h) =>
        EvolutionApi(
          client: MockClient(h),
          disk: disk,
          now: () => now,
          retryDelay: Duration.zero,
        );

    test('a chain seen before is served from disk', () async {
      await api((r) async => handle(r)).getChain('ivysaur');

      var requests = 0;
      final chain = await api((r) async {
        requests++;
        return handle(r);
      }).getChain('ivysaur');

      expect(chain.root.name, 'bulbasaur');
      expect(requests, 0);
    });

    test('an old chain is used when the network is down', () async {
      await api((r) async => handle(r)).getChain('ivysaur');
      now = now.add(const Duration(days: 60));

      final chain = await api(
        (_) async => throw const SocketException('offline'),
      ).getChain('ivysaur');

      expect(chain.levels, hasLength(3));
    });

    test('a chain never seen fails while offline', () async {
      await expectLater(
        api(
          (_) async => throw const SocketException('offline'),
        ).getChain('ivysaur'),
        throwsA(isA<PokemonApiException>()),
      );
    });
  });

  group('PokemonTypeIndex status', () {
    test('reports a failing request as offline', () async {
      final status = NetworkStatus();
      final index = PokemonTypeIndex(
        client: MockClient((_) async => throw const SocketException('offline')),
        status: status,
      );

      expect(await index.ensureLoaded(), isFalse);
      expect(status.isOffline, isTrue);
    });
  });
}
