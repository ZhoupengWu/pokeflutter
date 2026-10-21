import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokeflutter/app_services.dart';
import 'package:pokeflutter/controllers/home_controller.dart';
import 'package:pokeflutter/core/pokedex.dart';
import 'package:pokeflutter/data/pokemon_names.dart';
import 'package:pokeflutter/data/pokemon_repository.dart';
import 'package:pokeflutter/data/pokemon_type_index.dart';
import 'package:pokeflutter/model/pokemon_list_item.dart';
import 'package:pokeflutter/views/shared/grid_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/test_app.dart';

PokemonNames _names() => PokemonNames(
  table: {
    'mr-mime': {'en': 'Mr. Mime'},
    'type-null': {'en': 'Type: Null', 'it': 'Tipo Zero'},
    'zubat': {'en': 'Zubat'},
    'charizard-mega-x': {'en': 'Charizard (Mega X)'},
  },
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('PokemonNames', () {
    test('uses the language asked for, then English, then the id', () {
      final names = _names();

      expect(names.display('type-null', 'it'), 'Tipo Zero');
      expect(names.display('type-null', 'en'), 'Type: Null');
      expect(names.display('type-null', 'fr'), 'Type: Null'); // no French
      expect(names.display('mr-mime', 'it'), 'Mr. Mime'); // same in Italian
      expect(names.display('mon1', 'en'), 'Mon1'); // not in the table
      expect(names.display('some-form', 'it'), 'Some-form');
    });

    test('a search matches the id and the name in any language', () {
      final names = _names();

      expect(names.matches('type-null', 'null'), isTrue);
      expect(names.matches('type-null', 'tipo'), isTrue); // Italian
      expect(names.matches('type-null', 'type:'), isTrue); // English, with ':'
      expect(names.matches('mr-mime', 'mr.'), isTrue);
      expect(names.matches('mr-mime', 'mime'), isTrue);
      expect(names.matches('mr-mime', 'zub'), isFalse);
      expect(names.matches('unlisted-mon', 'unlisted'), isTrue); // by id
    });

    test('parses the table of the asset format', () {
      final table = PokemonNames.parse('{"a":{"en":"A","it":"Ah"}}');
      expect(PokemonNames(table: table).display('a', 'it'), 'Ah');
    });

    test('load reads the bundled asset', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final names = PokemonNames();
      await names.load();

      expect(names.display('mr-mime', 'en'), 'Mr. Mime');
      expect(names.display('nidoran-f', 'it'), 'Nidoran♀');
      expect(names.display('type-null', 'it'), 'Tipo Zero');
      expect(names.display('charizard-mega-x', 'en'), 'Charizard (Mega X)');
    });
  });

  group('the bundled table', () {
    final list =
        (jsonDecode(File('assets/pokemonList.json').readAsStringSync())
                as Map<String, dynamic>)['pokemonList']
            as List<dynamic>;
    final table = PokemonNames.parse(
      File('assets/pokemonNames.json').readAsStringSync(),
    );

    test('has an English name for every Pokémon of the list', () {
      final missing = [
        for (final entry in list)
          if (table[(entry as Map)['name']]?['en'] == null) entry['name'],
      ];
      expect(missing, isEmpty);
    });

    test('has no names for Pokémon that are not in the list', () {
      final listed = {for (final e in list) (e as Map)['name']};
      expect(table.keys.where((k) => !listed.contains(k)), isEmpty);
    });
  });

  group('Home', () {
    HomeController controller() => HomeController(
      repository: PokemonRepository(
        loadAsset: () async => jsonEncode({
          'pokemonList': [
            for (final (name, id) in [
              ('zubat', 41),
              ('mr-mime', 122),
              ('type-null', 772),
            ])
              {'name': name, 'url': 'https://pokeapi.co/api/v2/pokemon/$id/'},
          ],
        }),
      ),
      typeIndex: PokemonTypeIndex(
        client: MockClient((_) async => http.Response('{"pokemon":[]}', 200)),
      ),
      names: _names(),
      random: Random(1),
    );

    test('search finds a Pokémon by its name in either language', () async {
      final c = controller();
      await c.init();

      await c.setSearch('tipo zero');
      expect(c.filtered.map((p) => p.name), ['type-null']);
      await c.setSearch('type: null');
      expect(c.filtered.map((p) => p.name), ['type-null']);
      await c.setSearch('mr.');
      expect(c.filtered.map((p) => p.name), ['mr-mime']);
      c.dispose();
    });

    test('sorting by name follows the language shown', () async {
      final c = controller();
      await c.init();
      await c.setSort(PokemonSort.nameAsc);

      // English: Mr. Mime, Type: Null, Zubat.
      expect(c.filtered.map((p) => p.name), ['mr-mime', 'type-null', 'zubat']);

      c.setLanguage('it'); // Mr. Mime, Tipo Zero, Zubat: same order here
      await Future<void>.delayed(Duration.zero);
      expect(c.filtered.map((p) => p.name), ['mr-mime', 'type-null', 'zubat']);

      await c.setSort(PokemonSort.nameDesc);
      expect(c.filtered.map((p) => p.name), ['zubat', 'type-null', 'mr-mime']);
      c.dispose();
    });
  });

  testWidgets('the grid shows the name in the app language', (tester) async {
    final item = PokemonListItem(
      name: 'type-null',
      url: 'https://pokeapi.co/api/v2/pokemon/772/',
    );
    for (final (locale, shown) in [
      (const Locale('en'), 'Type: Null'),
      (const Locale('it'), 'Tipo Zero'),
    ]) {
      await tester.pumpWidget(
        testApp(
          SizedBox(width: 160, height: 100, child: GridItem(pokemon: item)),
          services: AppServices(names: _names()),
          locale: locale,
        ),
      );
      await tester.pump();
      expect(find.text(shown), findsOneWidget);
    }
  });
}
