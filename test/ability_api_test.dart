import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokeflutter/data/ability_api.dart';
import 'package:pokeflutter/data/disk_cache.dart';
import 'package:pokeflutter/data/pokemon_api.dart';

String _body() => jsonEncode({
  'names': [
    {
      'name': 'Fuocardore',
      'language': {'name': 'it'},
    },
    {
      'name': 'Großbrand',
      'language': {'name': 'de'},
    },
    {
      'name': 'Blaze',
      'language': {'name': 'en'},
    },
  ],
});

void main() {
  late Directory dir;
  setUp(() async => dir = await Directory.systemTemp.createTemp('ability'));
  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  AbilityApi api(Future<http.Response> Function(http.Request) handler) =>
      AbilityApi(
        client: MockClient(handler),
        disk: DiskCache(directory: () async => dir),
        retryDelay: Duration.zero,
      );

  test('keeps the English and Italian names only', () async {
    final names = await api(
      (_) async => http.Response(_body(), 200),
    ).getNames('blaze');

    expect(names, {'it': 'Fuocardore', 'en': 'Blaze'});
  });

  test('asks once, then serves memory and disk', () async {
    var requests = 0;
    Future<http.Response> handler(http.Request r) async {
      requests++;
      expect(r.url.path, '/api/v2/ability/lightning-rod');
      return http.Response(_body(), 200);
    }

    final first = api(handler);
    await first.getNames('lightning-rod');
    await first.getNames('lightning-rod');
    await api(handler).getNames('lightning-rod'); // new instance: from disk

    expect(requests, 1);
  });

  test('an unknown ability is a not-found error', () async {
    await expectLater(
      api((_) async => http.Response('Not Found', 404)).getNames('nope'),
      throwsA(
        isA<PokemonApiException>().having(
          (e) => e.type,
          'type',
          PokemonApiErrorType.notFound,
        ),
      ),
    );
  });
}
