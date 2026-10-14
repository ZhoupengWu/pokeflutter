import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokeflutter/model/evolution.dart';
import 'package:pokeflutter/utils/evolution_api.dart';
import 'package:pokeflutter/utils/pokemon_api.dart';

import 'support/fixtures.dart';

EvolutionApi _api(
  Future<http.Response> Function(http.Request) handler, {
  int maxAttempts = 2,
}) => EvolutionApi(
  client: MockClient(handler),
  retryDelay: Duration.zero,
  maxAttempts: maxAttempts,
);

EvolutionChain _parse(String body) =>
    EvolutionChain.fromJson(jsonDecode(body) as Map<String, dynamic>);

void main() {
  group('EvolutionChain', () {
    test('parses a linear chain with level requirements', () {
      final chain = _parse(bulbasaurChainBody());

      expect(chain.isSingleStage, isFalse);
      expect(chain.levels.map((l) => l.map((s) => s.name).toList()), [
        ['bulbasaur'],
        ['ivysaur'],
        ['venusaur'],
      ]);
      final ivysaur = chain.levels[1].single;
      expect(ivysaur.id, 2);
      expect(ivysaur.requirement?.minLevel, 16);
      expect(ivysaur.requirement?.trigger, 'level-up');
      expect(chain.root.requirement, isNull);
    });

    test('keeps branches together on the same level', () {
      final chain = _parse(eeveeChainBody());

      expect(chain.levels, hasLength(2));
      final branches = chain.levels[1];
      expect(branches.map((s) => s.name), ['vaporeon', 'espeon', 'leafeon']);
      expect(branches[0].requirement?.item, 'water-stone');
      expect(branches[0].requirement?.trigger, 'use-item');
      expect(branches[1].requirement?.minHappiness, 160);
      expect(branches[1].requirement?.timeOfDay, isNull); // '' → none
      expect(branches[2].id, 470);
    });

    test('a Pokémon without evolutions is a single stage', () {
      final chain = _parse(singleStageChainBody());

      expect(chain.isSingleStage, isTrue);
      expect(chain.levels, hasLength(1));
    });
  });

  group('EvolutionApi', () {
    http.Response handle(http.Request request) => switch (request.url.path) {
      '/api/v2/pokemon-species/ivysaur' => http.Response(speciesBody(), 200),
      '/api/v2/evolution-chain/1/' => http.Response(bulbasaurChainBody(), 200),
      _ => http.Response('', 404),
    };

    test('follows the species to its chain', () async {
      final chain = await _api((r) async => handle(r)).getChain('ivysaur');

      expect(chain.root.name, 'bulbasaur');
    });

    test('caches per species and shares concurrent requests', () async {
      var requests = 0;
      final api = _api((r) async {
        requests++;
        return handle(r);
      });

      await Future.wait([api.getChain('ivysaur'), api.getChain('Ivysaur')]);
      await api.getChain('ivysaur');

      expect(requests, 2); // one species + one chain request
    });

    test('an unknown species is a notFound error', () async {
      final api = _api((r) async => handle(r));

      await expectLater(
        api.getChain('missingno'),
        throwsA(
          isA<PokemonApiException>().having(
            (e) => e.type,
            'type',
            PokemonApiErrorType.notFound,
          ),
        ),
      );
    });

    test('failures are retried and then not cached', () async {
      var failing = true;
      var calls = 0;
      final api = _api((r) async {
        calls++;
        return failing ? http.Response('', 503) : handle(r);
      });

      await expectLater(
        api.getChain('ivysaur'),
        throwsA(isA<PokemonApiException>()),
      );
      expect(calls, 2); // original attempt + one retry

      failing = false;
      expect((await api.getChain('ivysaur')).root.name, 'bulbasaur');
    });

    test('a malformed chain is a parse error', () async {
      final api = _api((r) async {
        if (r.url.path.contains('pokemon-species')) {
          return http.Response(speciesBody(), 200);
        }
        return http.Response('{"chain": {}}', 200);
      });

      await expectLater(
        api.getChain('ivysaur'),
        throwsA(
          isA<PokemonApiException>().having(
            (e) => e.type,
            'type',
            PokemonApiErrorType.parse,
          ),
        ),
      );
    });
  });
}
