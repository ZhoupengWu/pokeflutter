import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokeflutter/utils/pokemon_costants.dart';
import 'package:pokeflutter/utils/pokemon_type_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake PokéAPI: fire = charmander + charizard, flying = charizard,
/// every other type is empty.
http.Response _typeResponse(http.Request request) {
  final type = request.url.pathSegments.last;
  final names = switch (type) {
    'fire' => ['charmander', 'charizard'],
    'flying' => ['charizard', 'pidgey'],
    _ => <String>[],
  };
  return http.Response(
    jsonEncode({
      'pokemon': [
        for (final n in names)
          {
            'pokemon': {'name': n},
            'slot': 1,
          },
      ],
    }),
    200,
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'downloads the 18 types once and filters by any selected type',
    () async {
      var requests = 0;
      final index = PokemonTypeIndex(
        client: MockClient((request) async {
          requests++;
          return _typeResponse(request);
        }),
      );

      expect(index.isLoaded, isFalse);
      // Concurrent callers share a single download.
      final results = await Future.wait([
        index.ensureLoaded(),
        index.ensureLoaded(),
      ]);

      expect(results, [true, true]);
      expect(requests, listPokemonTypeColor.length);
      expect(index.matchesAny('charmander', {'fire'}), isTrue);
      expect(index.matchesAny('charmander', {'flying'}), isFalse);
      expect(index.matchesAny('charmander', {'flying', 'fire'}), isTrue);
      expect(index.matchesAny('pidgey', {'flying'}), isTrue);
      expect(index.matchesAny('unknown-mon', {'fire', 'flying'}), isFalse);
    },
  );

  test('is persisted: a new instance loads without network', () async {
    await PokemonTypeIndex(
      client: MockClient((r) async => _typeResponse(r)),
    ).ensureLoaded();

    final offline = PokemonTypeIndex(
      client: MockClient((_) async => throw Exception('offline')),
    );

    expect(await offline.ensureLoaded(), isTrue);
    expect(offline.matchesAny('charizard', {'fire'}), isTrue);
  });

  test(
    'a failed download reports false, keeps nothing and can be retried',
    () async {
      var failing = true;
      final index = PokemonTypeIndex(
        client: MockClient((request) async {
          if (failing && request.url.pathSegments.last == 'water') {
            return http.Response('error', 500);
          }
          return _typeResponse(request);
        }),
      );

      expect(await index.ensureLoaded(), isFalse);
      expect(index.isLoaded, isFalse);

      failing = false;
      expect(await index.ensureLoaded(), isTrue);
      expect(index.matchesAny('charizard', {'flying'}), isTrue);
    },
  );
}
