import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/app_services.dart';
import 'package:pokeflutter/controllers/pokemon_detail_controller.dart';
import 'package:pokeflutter/controllers/quiz_controller.dart';
import 'package:pokeflutter/data/quiz_stats_store.dart';
import 'package:pokeflutter/model/pokemon_list_item.dart';
import 'package:pokeflutter/model/quiz_model.dart';
import 'package:pokeflutter/views/detail/pokemon_detail_page.dart';
import 'package:pokeflutter/views/quiz/quiz_page.dart';
import 'package:pokeflutter/views/quiz/quiz_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/detail_fakes.dart';
import 'support/fonts.dart';
import 'support/quiz_fakes.dart';
import 'support/test_app.dart';

/// Pages held sideways (844 × 390 dp) put their parts side by side instead of
/// squeezing everything into a strip a few lines tall.
Future<void> _pump(
  WidgetTester tester,
  Widget page, {
  required bool landscape,
}) async {
  tester.view.physicalSize = landscape
      ? const Size(2532, 1170)
      : const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(testApp(page, services: AppServices()));
  for (var i = 0; i < 3; i++) {
    await tester.pump();
  }
}

Future<void> _pumpDetail(WidgetTester tester, {required bool landscape}) async {
  final item = PokemonListItem(
    name: 'mon6',
    url: 'https://pokeapi.co/api/v2/pokemon/6/',
  );
  final controller = PokemonDetailController(
    item: item,
    api: FakePokemonApi(types: ['fire']),
    evolutionApi: FakeEvolutionApi(),
    speciesApi: FakeSpeciesApi(),
    abilityApi: FakeAbilityApi(),
    repository: fakeRepository(count: 500),
  );
  addTearDown(controller.dispose);
  await _pump(
    tester,
    PokemonDetailPage(pokemon: item, controller: controller),
    landscape: landscape,
  );
}

QuizController _quiz({List<QuizMode>? modes}) => QuizController(
  api: FakePokemonApi(types: ['fire', 'flying'], varyingStats: true),
  repository: fakeRepository(),
  stats: QuizStatsStore(),
  questionCount: 1,
  modes: modes ?? [QuizMode.guessName],
);

void main() {
  setUpAll(loadRoboto);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('detail page', () {
    testWidgets('upright: the details are below the artwork', (tester) async {
      await _pumpDetail(tester, landscape: false);

      final name = tester.getTopLeft(find.text('Mon6'));
      final entry = tester.getTopLeft(find.text('Pokédex entry'));
      expect(entry.dy, greaterThan(name.dy + 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('sideways: the details are beside the artwork', (tester) async {
      await _pumpDetail(tester, landscape: true);

      final name = tester.getTopLeft(find.text('Mon6'));
      final entry = tester.getTopLeft(find.text('Pokédex entry'));
      expect(entry.dx, greaterThan(name.dx + 200)); // another column
      expect(entry.dy, lessThan(100)); // and visible right away
      expect(tester.takeException(), isNull);
    });
  });

  group('quiz', () {
    testWidgets('sideways, the start button is on screen', (tester) async {
      final controller = _quiz();
      addTearDown(controller.dispose);
      await _pump(tester, QuizPage(controller: controller), landscape: true);

      final button = tester.getRect(find.text('Start Quiz'));
      expect(button.bottom, lessThanOrEqualTo(390));
      expect(button.left, greaterThan(844 / 2 - 50)); // right half
      expect(tester.takeException(), isNull);
    });

    testWidgets('sideways, the options are beside the sprite', (tester) async {
      final controller = _quiz();
      addTearDown(controller.dispose);
      await _pump(tester, QuizPage(controller: controller), landscape: true);
      controller.setDifficulty(QuizDifficulty.easy);
      await tester.runAsync(controller.start);
      for (var i = 0; i < 3; i++) {
        await tester.pump();
      }

      final options = find.byType(QuizOptionButton);
      expect(options, findsNWidgets(4));
      for (var i = 0; i < 4; i++) {
        final rect = tester.getRect(options.at(i));
        expect(rect.left, greaterThan(844 / 2 - 10));
        expect(rect.bottom, lessThanOrEqualTo(390));
      }

      await tester.tap(options.at(controller.question.correctIndex));
      await tester.pump();
      // The Next button is reachable on the same screen.
      expect(
        tester.getRect(find.byType(QuizPrimaryButton)).bottom,
        lessThanOrEqualTo(390),
      );
      expect(tester.takeException(), isNull);
    });

    for (final mode in [QuizMode.guessType, QuizMode.higherStat]) {
      testWidgets('sideways, a ${mode.name} question fits', (tester) async {
        final controller = _quiz(modes: [mode]);
        addTearDown(controller.dispose);
        await _pump(tester, QuizPage(controller: controller), landscape: true);
        controller.setDifficulty(QuizDifficulty.easy);
        await tester.runAsync(controller.start);
        for (var i = 0; i < 3; i++) {
          await tester.pump();
        }

        final options = find.byType(QuizOptionButton);
        expect(options, findsNWidgets(mode == QuizMode.higherStat ? 2 : 4));
        for (var i = 0; i < options.evaluate().length; i++) {
          expect(tester.getRect(options.at(i)).bottom, lessThanOrEqualTo(390));
        }
        await tester.tap(options.at(controller.question.correctIndex));
        await tester.pump();
        expect(
          tester.getRect(find.byType(QuizPrimaryButton)).bottom,
          lessThanOrEqualTo(390),
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
