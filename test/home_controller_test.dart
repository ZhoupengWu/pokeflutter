import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokeflutter/controllers/home_controller.dart';
import 'package:pokeflutter/core/pokedex.dart';
import 'package:pokeflutter/data/pokemon_names.dart';
import 'package:pokeflutter/data/pokemon_repository.dart';
import 'package:pokeflutter/data/pokemon_type_index.dart';
import 'package:pokeflutter/views/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/quiz_fakes.dart';
import 'support/test_app.dart';

/// fire = mon1 + mon2, flying = mon2 (second type) + mon3; the rest is empty.
http.Response _types(http.Request request) {
  final entries = switch (request.url.pathSegments.last) {
    'fire' => [('mon1', 1), ('mon2', 1)],
    'flying' => [('mon2', 2), ('mon3', 1)],
    _ => <(String, int)>[],
  };
  return http.Response(
    jsonEncode({
      'pokemon': [
        for (final (name, slot) in entries)
          {
            'pokemon': {'name': name},
            'slot': slot,
          },
      ],
    }),
    200,
  );
}

/// A switch for the fake network behind the type index.
class _Network {
  _Network({this.offline = false});

  bool offline;
}

HomeController _controller([_Network? network]) {
  final net = network ?? _Network();
  return HomeController(
    repository: fakeRepository(),
    typeIndex: PokemonTypeIndex(
      client: MockClient(
        (request) async =>
            net.offline ? http.Response('', 503) : _types(request),
      ),
    ),
    names: PokemonNames(),
    random: Random(1),
  );
}

List<String> _names(HomeController c) => c.filtered.map((p) => p.name).toList();

/// A list spanning generations and including an alternate form.
PokemonRepository _mixedRepository() => PokemonRepository(
  loadAsset: () async => jsonEncode({
    'pokemonList': [
      for (final (name, id) in [
        ('bulbasaur', 1),
        ('pikachu', 25),
        ('chikorita', 152),
        ('treecko', 252),
        ('charizard-mega-x', 10034),
      ])
        {'name': name, 'url': 'https://pokeapi.co/api/v2/pokemon/$id/'},
    ],
  }),
);

HomeController _mixed() => HomeController(
  repository: _mixedRepository(),
  typeIndex: PokemonTypeIndex(client: MockClient((r) async => _types(r))),
  names: PokemonNames(),
  random: Random(1),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('search by number, generation and sort', () {
    test('a number finds that Pokémon, with or without #', () async {
      final c = _mixed();
      await c.init();

      await c.setSearch('25');
      expect(_names(c), ['pikachu']);

      await c.setSearch('#152');
      expect(_names(c), ['chikorita']);

      await c.setSearch('999');
      expect(c.filtered, isEmpty);
      c.dispose();
    });

    test('filters by generation and hides alternate forms', () async {
      final c = _mixed();
      await c.init();

      await c.setGenerationFilters({1});
      expect(_names(c), ['bulbasaur', 'pikachu']);

      await c.setGenerationFilters({1, 3});
      expect(_names(c), ['bulbasaur', 'pikachu', 'treecko']);

      await c.setGenerationFilters({});
      expect(c.filtered, hasLength(5)); // the Mega form is back
      c.dispose();
    });

    test('sorts by number and by name', () async {
      final c = _mixed();
      await c.init();

      await c.setSort(PokemonSort.numberDesc);
      expect(_names(c), [
        'charizard-mega-x',
        'treecko',
        'chikorita',
        'pikachu',
        'bulbasaur',
      ]);

      await c.setSort(PokemonSort.nameAsc);
      expect(_names(c).first, 'bulbasaur');
      expect(_names(c).last, 'treecko');

      await c.setSort(PokemonSort.nameDesc);
      expect(_names(c).first, 'treecko');

      await c.setSort(PokemonSort.numberAsc);
      expect(_names(c).first, 'bulbasaur');
      c.dispose();
    });

    test('filters, search and sort combine and are counted', () async {
      final c = _mixed();
      await c.init();
      expect(c.activeFilterCount, 0);

      await c.setSelection(
        types: {'fire'},
        generations: {1, 2},
        sort: PokemonSort.nameDesc,
      );

      expect(c.activeFilterCount, 4); // 1 type + 2 generations + the sort
      // mon1/mon2 are the "fire" Pokémon of the fake type API, not in this list.
      expect(c.filtered, isEmpty);

      await c.setSelection(
        types: const {},
        generations: {1, 2},
        sort: PokemonSort.nameDesc,
      );
      expect(_names(c), ['pikachu', 'chikorita', 'bulbasaur']);

      await c.setSearch('chi');
      expect(_names(c), ['chikorita']);
      c.dispose();
    });
  });

  group('weak-to filter', () {
    // mon1 = fire, mon2 = fire/flying, mon3 = flying (see _types).
    test('keeps the Pokémon that take super-effective damage', () async {
      final c = _controller();
      await c.init();

      await c.setWeakToFilters({'water'});
      expect(_names(c), ['mon1', 'mon2']);

      await c.setWeakToFilters({'electric'});
      expect(_names(c), ['mon2', 'mon3']);
      c.dispose();
    });

    test('immunities and cancelled weaknesses do not count', () async {
      final c = _controller();
      await c.init();

      // Fire/flying is immune to ground (flying) while pure fire is weak.
      await c.setWeakToFilters({'ground'});
      expect(_names(c), ['mon1']);

      // Rock is a double weakness for fire/flying, a normal one for the others.
      await c.setWeakToFilters({'rock'});
      expect(_names(c), ['mon1', 'mon2', 'mon3']);
      c.dispose();
    });

    test('several attackers match any of them, like the type filter', () async {
      final c = _controller();
      await c.init();

      await c.setWeakToFilters({'water', 'electric'});
      expect(_names(c), ['mon1', 'mon2', 'mon3']);
      c.dispose();
    });

    test('combines with the type filter and is counted', () async {
      final c = _controller();
      await c.init();

      await c.setSelection(
        types: {'flying'},
        generations: const {},
        sort: PokemonSort.numberAsc,
        weakTo: {'water', 'rock'},
      );
      expect(_names(c), ['mon2', 'mon3']);
      expect(c.activeFilterCount, 3); // 1 type + 2 attackers

      await c.setSelection(
        types: {'flying'},
        generations: const {},
        sort: PokemonSort.numberAsc,
      ); // no weakTo argument keeps the current one
      expect(c.activeWeakTo, {'water', 'rock'});

      await c.setWeakToFilters({});
      expect(_names(c), ['mon2', 'mon3']);
      expect(c.activeFilterCount, 1);
      c.dispose();
    });

    test('reports a failure when the types cannot be loaded', () async {
      final net = _Network(offline: true);
      final c = _controller(net);
      await c.init();

      await c.setWeakToFilters({'water'});
      expect(c.filterFailed, isTrue);
      expect(c.isFilterLoading, isFalse);

      net.offline = false;
      await c.applyFilters();
      expect(c.filterFailed, isFalse);
      expect(_names(c), ['mon1', 'mon2']);
      c.dispose();
    });
  });

  group('HomeController', () {
    test('shows the whole list once loaded', () async {
      final c = _controller();
      await c.init();

      expect(c.allPokemon, hasLength(30));
      expect(c.filtered, hasLength(30));
      expect(c.typesUnavailable, isFalse);
      c.dispose();
    });

    test('searches by name, ignoring case and spaces around', () async {
      final c = _controller();
      await c.init();

      await c.setSearch('  MON2 ');
      expect(_names(c), [
        'mon2',
        'mon20',
        'mon21',
        'mon22',
        'mon23',
        'mon24',
        'mon25',
        'mon26',
        'mon27',
        'mon28',
        'mon29',
      ]);

      await c.setSearch('');
      expect(c.filtered, hasLength(30));
      c.dispose();
    });

    test('filters by any of the selected types', () async {
      final c = _controller();
      await c.init();

      await c.setTypeFilters({'fire'});
      expect(_names(c), ['mon1', 'mon2']);

      await c.setTypeFilters({'fire', 'flying'});
      expect(_names(c), ['mon1', 'mon2', 'mon3']);

      await c.setTypeFilters({});
      expect(c.filtered, hasLength(30));
      c.dispose();
    });

    test('search and type filters combine', () async {
      final c = _controller();
      await c.init();
      await c.setTypeFilters({'fire', 'flying'});

      await c.setSearch('mon3');

      expect(_names(c), ['mon3']);
      c.dispose();
    });

    test('without the type index, a type filter reports the failure', () async {
      final network = _Network(offline: true);
      final c = _controller(network);
      await c.init();
      expect(c.typesUnavailable, isTrue);

      await c.setTypeFilters({'fire'});
      expect(c.filterFailed, isTrue);
      expect(c.isFilterLoading, isFalse);

      network.offline = false;
      await c.applyFilters();
      expect(c.filterFailed, isFalse);
      expect(_names(c), ['mon1', 'mon2']);

      await c.loadTypes();
      expect(c.typesUnavailable, isFalse);
      c.dispose();
    });

    test('the list works without types when only searching', () async {
      final c = _controller(_Network(offline: true));
      await c.init();

      await c.setSearch('mon7');

      expect(_names(c), ['mon7']);
      expect(c.filterFailed, isFalse);
      c.dispose();
    });

    test('picks a random Pokémon from the list', () async {
      final c = _controller();
      expect(c.randomPokemon(), isNull);

      await c.init();
      final seen = {for (var i = 0; i < 50; i++) c.randomPokemon()!.name};

      expect(seen.length, greaterThan(5));
      expect(c.allPokemon.map((p) => p.name), containsAll(seen));
      c.dispose();
    });
  });

  group('HomePage', () {
    testWidgets('searches, filters and clears the filter chips', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final controller = _controller();
      addTearDown(controller.dispose);

      await tester.pumpWidget(testApp(HomePage(controller: controller)));
      await tester.pump();
      await tester.pump();
      expect(find.text('Pokédex'), findsOneWidget);
      expect(find.text('Mon1'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();
      await tester.pump();
      expect(find.text('No Pokémon found.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      await controller.setTypeFilters({'fire'});
      await tester.pump();
      expect(find.text('Fire'), findsWidgets); // chip (+ badges)
      expect(find.text('Mon3'), findsNothing);

      await tester.tap(find.text('Clear all'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Mon3'), findsOneWidget);
    });

    testWidgets('shows a removable "Weak to" chip', (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final controller = _controller();
      addTearDown(controller.dispose);

      await tester.pumpWidget(testApp(HomePage(controller: controller)));
      await tester.pump();
      await tester.pump();

      await controller.setWeakToFilters({'water'});
      await tester.pump();
      expect(find.text('Weak to Water'), findsOneWidget);
      expect(find.text('Mon3'), findsNothing); // flying is not weak to water

      await tester.tap(find.text('Clear all'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Weak to Water'), findsNothing);
      expect(controller.activeWeakTo, isEmpty);
      expect(find.text('Mon3'), findsOneWidget);
    });

    testWidgets('offers a retry when the types are unavailable', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final network = _Network(offline: true);
      final controller = _controller(network);
      addTearDown(controller.dispose);

      await tester.pumpWidget(testApp(HomePage(controller: controller)));
      await tester.pump();
      await tester.pump();
      expect(find.text('Types unavailable offline.'), findsOneWidget);

      network.offline = false;
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Types unavailable offline.'), findsNothing);
    });
  });
}
