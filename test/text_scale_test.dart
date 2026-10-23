import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/app_services.dart';
import 'package:pokeflutter/controllers/pokemon_detail_controller.dart';
import 'package:pokeflutter/controllers/quiz_controller.dart';
import 'package:pokeflutter/core/pokedex.dart';
import 'package:pokeflutter/data/quiz_stats_store.dart';
import 'package:pokeflutter/data/pokemon_type_index.dart';
import 'package:pokeflutter/model/pokemon_list_item.dart';
import 'package:pokeflutter/model/quiz_model.dart';
import 'package:pokeflutter/views/compare/compare_page.dart';
import 'package:pokeflutter/views/detail/pokemon_detail_page.dart';
import 'package:pokeflutter/views/favourites/favourite_page.dart';
import 'package:pokeflutter/views/home/filter_sheet.dart';
import 'package:pokeflutter/views/home/home_page.dart';
import 'package:pokeflutter/views/home/settings_sheet.dart';
import 'package:pokeflutter/views/quiz/quiz_page.dart';
import 'package:pokeflutter/views/team/team_page.dart';
import 'package:pokeflutter/views/quiz/quiz_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/detail_fakes.dart';
import 'support/fonts.dart';
import 'support/quiz_fakes.dart';
import 'support/test_app.dart';

/// Accessibility: with the system font size at 200 % (the largest Android
/// offers) on a small phone, no screen may overflow or throw.
AppServices _services() => AppServices(
  repository: fakeRepository(),
  pokemonApi: FakePokemonApi(types: ['fire', 'flying']),
  evolutionApi: FakeEvolutionApi(),
  speciesApi: FakeSpeciesApi(),
  abilityApi: FakeAbilityApi(),
  typeIndex: PokemonTypeIndex(),
);

Widget _scaled(Widget child) => Builder(
  builder: (context) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: const TextScaler.linear(2)),
    child: child,
  ),
);

Future<void> _pump(
  WidgetTester tester,
  Widget page, {
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(1080, 1920); // 360 × 640 dp
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    testApp(_scaled(page), services: _services(), locale: locale),
  );
  for (var i = 0; i < 3; i++) {
    await tester.pump();
  }
}

void main() {
  setUpAll(loadRoboto);

  setUp(
    () => SharedPreferences.setMockInitialValues({
      'pokemon_type_index_v2': '{"mon1": ["fire"]}',
    }),
  );

  for (final locale in const [Locale('en'), Locale('it')]) {
    final name = locale.languageCode;

    testWidgets('Home at 200 % ($name)', (tester) async {
      await _pump(tester, const HomePage(), locale: locale);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Compare at 200 % ($name)', (tester) async {
      await _pump(tester, const ComparePage(), locale: locale);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Quiz start at 200 % ($name)', (tester) async {
      await _pump(tester, const QuizPage(), locale: locale);
      expect(tester.takeException(), isNull);
    });

    for (final mode in QuizMode.values) {
      testWidgets('Quiz ${mode.name} question and results at 200 % ($name)', (
        tester,
      ) async {
        final controller = QuizController(
          api: FakePokemonApi(types: ['fire', 'flying'], varyingStats: true),
          repository: fakeRepository(),
          stats: QuizStatsStore(),
          questionCount: 1,
          modes: [mode],
        );
        addTearDown(controller.dispose);
        await _pump(tester, QuizPage(controller: controller), locale: locale);

        controller.setDifficulty(QuizDifficulty.easy);
        await tester.runAsync(controller.start);
        for (var i = 0; i < 3; i++) {
          await tester.pump();
        }
        expect(controller.screen.name, 'quiz');
        expect(tester.takeException(), isNull);

        // Answer, to see the feedback area, then the results.
        await tester.tap(
          find.byType(QuizOptionButton).at(controller.question.correctIndex),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        await tester.runAsync(controller.next);
        await tester.pump();
        expect(controller.screen.name, 'results');
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Quiz start with the daily challenge at 200 % ($name)', (
      tester,
    ) async {
      final controller = QuizController(
        api: FakePokemonApi(varyingStats: true),
        repository: fakeRepository(),
        stats: QuizStatsStore(),
        questionCount: 1,
      );
      addTearDown(controller.dispose);
      await _pump(tester, QuizPage(controller: controller), locale: locale);
      expect(tester.takeException(), isNull);

      // After today's game the card shows the result and the streak.
      controller.setDifficulty(QuizDifficulty.easy);
      await tester.runAsync(controller.startDaily);
      await tester.pump();
      await tester.tap(
        find.byType(QuizOptionButton).at(controller.question.correctIndex),
      );
      await tester.pump();
      await tester.runAsync(controller.next);
      await tester.pump();
      expect(tester.takeException(), isNull);
      controller.backToStart();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Team at 200 % ($name)', (tester) async {
      await _pump(tester, const TeamPage(), locale: locale);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Favourites at 200 % ($name)', (tester) async {
      await _pump(tester, const FavouritePage(), locale: locale);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Settings at 200 % ($name)', (tester) async {
      await _pump(tester, const SettingsSheet(), locale: locale);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Filter sheet at 200 % ($name)', (tester) async {
      await _pump(
        tester,
        FilterSheet(
          initial: const FilterSelection(
            types: {'fire'},
            generations: {1},
            sort: PokemonSort.nameDesc,
          ),
          onApply: (_) {},
        ),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Detail at 200 % ($name)', (tester) async {
      final item = PokemonListItem(
        name: 'mon6',
        url: 'https://pokeapi.co/api/v2/pokemon/6/',
      );
      await _pump(
        tester,
        PokemonDetailPage(
          pokemon: item,
          controller: PokemonDetailController(
            item: item,
            api: FakePokemonApi(types: ['fire', 'flying']),
            evolutionApi: FakeEvolutionApi(),
            speciesApi: FakeSpeciesApi(),
            abilityApi: FakeAbilityApi(),
            repository: fakeRepository(count: 500),
          ),
        ),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
