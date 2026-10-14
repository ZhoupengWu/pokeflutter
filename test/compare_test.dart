import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/controllers/compare_controller.dart';
import 'package:pokeflutter/model/pokemon.dart';
import 'package:pokeflutter/model/pokemon_list_item.dart';
import 'package:pokeflutter/views/compare/compare_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fixtures.dart';
import 'support/quiz_fakes.dart';
import 'support/test_app.dart';

PokemonListItem _item(int id) => PokemonListItem(
  name: 'mon$id',
  url: 'https://pokeapi.co/api/v2/pokemon/$id/',
);

CompareController _controller(FakePokemonApi api) =>
    CompareController(api: api, repository: fakeRepository());

/// Returns each Pokémon's stats from a table, controllable per name.
class _StatsApi extends FakePokemonApi {
  _StatsApi(this.hp);

  final Map<String, int> hp;

  @override
  Future<Pokemon> getPokemonDetails(String name) async {
    final json = pokemonJson(name: name, speciesName: name, types: ['fire']);
    (json['stats'] as List<dynamic>)[0]['base_stat'] = hp[name] ?? 50;
    return Pokemon.fromJson(json);
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('CompareController', () {
    test('starts empty and loads the list', () async {
      final c = _controller(FakePokemonApi());
      expect(c.nothingSelected, isTrue);
      expect(c.canCompare, isFalse);

      await c.init();
      expect(c.allPokemon, hasLength(30));
      c.dispose();
    });

    test('can compare once both slots are loaded', () async {
      final c = _controller(FakePokemonApi());

      await c.select(CompareSlot.a, _item(1));
      expect(c.canCompare, isFalse);
      expect(c.nothingSelected, isFalse);
      expect(c.slot(CompareSlot.a).pokemon?.name, 'mon1');

      await c.select(CompareSlot.b, _item(2));
      expect(c.canCompare, isTrue);
      c.dispose();
    });

    test('a failed slot keeps its choice so it can be retried', () async {
      final api = FakePokemonApi(failing: {'mon1'});
      final c = _controller(api);

      await c.select(CompareSlot.a, _item(1));
      expect(c.slot(CompareSlot.a).failed, isTrue);
      expect(c.slot(CompareSlot.a).selected?.name, 'mon1');
      expect(c.anyFailed, isTrue);

      api.failing.clear();
      await c.retry(CompareSlot.a);
      expect(c.slot(CompareSlot.a).failed, isFalse);
      expect(c.slot(CompareSlot.a).pokemon, isNotNull);
      expect(c.anyFailed, isFalse);
      c.dispose();
    });

    test('a slow older load never overwrites a newer choice', () async {
      final slow = Completer<Pokemon>();
      final api = _GatedApi({'mon1': slow.future});
      final c = _controller(api);

      final first = c.select(CompareSlot.a, _item(1)); // waits for `slow`
      await c.select(CompareSlot.a, _item(2)); // finishes immediately
      slow.complete(
        Pokemon.fromJson(pokemonJson(name: 'mon1', speciesName: 'mon1')),
      );
      await first;

      expect(c.slot(CompareSlot.a).pokemon?.name, 'mon2');
      expect(c.slot(CompareSlot.a).selected?.name, 'mon2');
      c.dispose();
    });

    test('retry without a choice does nothing', () async {
      final c = _controller(FakePokemonApi());

      await c.retry(CompareSlot.b);

      expect(c.slot(CompareSlot.b).isLoading, isFalse);
      c.dispose();
    });
  });

  group('ComparePage', () {
    Future<CompareController> pump(
      WidgetTester tester, {
      FakePokemonApi? api,
      Locale locale = const Locale('en'),
    }) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final controller = _controller(
        api ?? _StatsApi({'mon1': 100, 'mon2': 60}),
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        testApp(ComparePage(controller: controller), locale: locale),
      );
      await tester.pump();
      await tester.pump();
      return controller;
    }

    testWidgets('guides the user through picking two Pokémon', (tester) async {
      await pump(tester);
      expect(
        find.text('Select two Pokémon to start comparing'),
        findsOneWidget,
      );

      await tester.tap(find.text('Pokémon A'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'mon1');
      await tester.pump();
      await tester.tap(find.text('Mon1').last);
      await tester.pumpAndSettle();

      expect(find.text('Select the second Pokémon to compare'), findsOneWidget);
      expect(find.text('Mon1'), findsOneWidget);

      await tester.tap(find.text('Pokémon B'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'mon2');
      await tester.pump();
      await tester.tap(find.text('Mon2').last);
      await tester.pumpAndSettle();

      // Both loaded: the table appears with the winner highlighted.
      expect(find.text('HP'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('tapping a failed card retries it', (tester) async {
      final api = FakePokemonApi(failing: {'mon1'});
      final controller = await pump(tester, api: api);

      await controller.select(CompareSlot.a, _item(1));
      await tester.pump();
      expect(find.text('Tap to retry'), findsOneWidget);
      expect(
        find.text("Couldn't load a Pokémon. Tap its card to retry."),
        findsOneWidget,
      );

      api.failing.clear();
      await tester.tap(find.text('Tap to retry'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Tap to retry'), findsNothing);
      expect(find.text('Mon1'), findsOneWidget);
    });

    testWidgets('is available in Italian and announces the cards', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, locale: const Locale('it'));

      expect(find.text('Confronta'), findsOneWidget);
      expect(
        find.text('Scegli due Pokémon per iniziare il confronto'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Scegli Pokémon A'), findsOneWidget);
      handle.dispose();
    });
  });
}

/// Completes each named Pokémon with a future the test controls.
class _GatedApi extends FakePokemonApi {
  _GatedApi(this.gates);

  final Map<String, Future<Pokemon>> gates;

  @override
  Future<Pokemon> getPokemonDetails(String name) =>
      gates[name] ?? super.getPokemonDetails(name);
}
