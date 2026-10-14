import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokeflutter/utils/pokemon_api.dart';
import 'package:pokeflutter/utils/pokemon_cache.dart';

import 'support/fixtures.dart';

PokemonApi _api(
  Future<http.Response> Function(http.Request) handler, {
  PokemonCache? cache,
  int maxAttempts = 2,
}) => PokemonApi(
  client: MockClient(handler),
  cache: cache ?? PokemonCache(),
  retryDelay: Duration.zero,
  maxAttempts: maxAttempts,
);

http.Response _ok([String name = 'charizard']) =>
    http.Response(pokemonBody(pokemonJson(name: name)), 200);

Future<void> _expectError(
  Future<Object?> future,
  PokemonApiErrorType type,
) async {
  await expectLater(
    future,
    throwsA(isA<PokemonApiException>().having((e) => e.type, 'type', type)),
  );
}

void main() {
  test('fetches, parses and caches a Pokémon', () async {
    var requests = 0;
    final api = _api((request) async {
      requests++;
      expect(request.url.path, '/api/v2/pokemon/charizard');
      return _ok();
    });

    final first = await api.getPokemonDetails('Charizard');
    final second = await api.getPokemonDetails('charizard');

    expect(first.name, 'charizard');
    expect(identical(first, second), isTrue);
    expect(requests, 1);
  });

  test('concurrent requests for the same Pokémon share one call', () async {
    var requests = 0;
    final api = _api((_) async {
      requests++;
      return _ok();
    });

    final results = await Future.wait([
      api.getPokemonDetails('charizard'),
      api.getPokemonDetails('charizard'),
      api.getPokemonDetails('charizard'),
    ]);

    expect(results.map((p) => p.name).toSet(), {'charizard'});
    expect(requests, 1);
  });

  test('a 404 is reported as notFound and is not retried', () async {
    var requests = 0;
    final api = _api((_) async {
      requests++;
      return http.Response('Not Found', 404);
    });

    await _expectError(
      api.getPokemonDetails('nope'),
      PokemonApiErrorType.notFound,
    );
    expect(requests, 1);
  });

  test('a transient server error is retried once', () async {
    var requests = 0;
    final api = _api((_) async {
      requests++;
      return requests == 1 ? http.Response('boom', 503) : _ok();
    });

    final pokemon = await api.getPokemonDetails('charizard');

    expect(pokemon.name, 'charizard');
    expect(requests, 2);
  });

  test('persistent network failures surface as network errors', () async {
    var requests = 0;
    final api = _api((_) async {
      requests++;
      throw http.ClientException('offline');
    });

    await _expectError(
      api.getPokemonDetails('charizard'),
      PokemonApiErrorType.network,
    );
    expect(requests, 2);
  });

  test('a timeout is a network error', () async {
    final api = PokemonApi(
      client: MockClient((_) => Completer<http.Response>().future),
      cache: PokemonCache(),
      timeout: const Duration(milliseconds: 10),
      retryDelay: Duration.zero,
      maxAttempts: 1,
    );

    await _expectError(
      api.getPokemonDetails('charizard'),
      PokemonApiErrorType.network,
    );
  });

  test('an unreadable body is a parse error and is not retried', () async {
    var requests = 0;
    final api = _api((_) async {
      requests++;
      return http.Response('{"unexpected": true}', 200);
    });

    await _expectError(
      api.getPokemonDetails('charizard'),
      PokemonApiErrorType.parse,
    );
    expect(requests, 1);
  });

  test('a failure is not cached: the next call tries again', () async {
    var fail = true;
    final api = _api(
      (_) async => fail ? http.Response('x', 500) : _ok(),
      maxAttempts: 1,
    );

    await _expectError(
      api.getPokemonDetails('charizard'),
      PokemonApiErrorType.server,
    );
    fail = false;

    expect((await api.getPokemonDetails('charizard')).name, 'charizard');
  });

  test('a variety is cached under its own name', () async {
    final cache = PokemonCache();
    final api = _api(
      (request) async => _ok(request.url.pathSegments.last),
      cache: cache,
    );

    await api.getPokemonDetails('charizard-mega-x');

    expect(cache.has('charizard-mega-x'), isTrue);
    expect(cache.has('charizard'), isFalse);
  });
}
