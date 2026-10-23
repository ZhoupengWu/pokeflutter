import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/app_services.dart';
import 'package:pokeflutter/controllers/quiz_controller.dart';
import 'package:pokeflutter/model/quiz_model.dart';
import 'package:pokeflutter/data/quiz_stats_store.dart';
import 'package:pokeflutter/views/quiz/quiz_page.dart';
import 'package:pokeflutter/views/shared/pokemon_image.dart';
import 'package:pokeflutter/views/quiz/quiz_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fonts.dart';
import 'support/quiz_fakes.dart';
import 'support/test_app.dart';

Future<QuizController> _pump(
  WidgetTester tester, {
  FakePokemonApi? api,
  Locale locale = const Locale('en'),
  List<QuizMode> modes = const [QuizMode.guessName, QuizMode.guessType],
  int questionCount = 2,
  FakeShareService? share,
  DateTime? now,
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final controller = QuizController(
    api: api ?? FakePokemonApi(varyingStats: true),
    repository: fakeRepository(),
    stats: QuizStatsStore(),
    questionCount: questionCount,
    modes: modes,
    clock: now == null ? null : () => now,
  );
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    testApp(
      QuizPage(controller: controller),
      locale: locale,
      services: AppServices(share: share),
    ),
  );
  await tester.pump();
  return controller;
}

void main() {
  setUpAll(loadRoboto);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('start screen: pick a difficulty and see the hint', (
    tester,
  ) async {
    final controller = await _pump(tester);

    expect(find.text('Start Quiz'), findsOneWidget);
    expect(find.text('All Pokémon, 20 seconds per question.'), findsOneWidget);
    expect(find.text('No score yet'), findsOneWidget);

    await tester.tap(find.text('Easy'));
    await tester.pump();
    expect(controller.difficulty, QuizDifficulty.easy);
    expect(
      find.text('First generation only (151 Pokémon), no timer.'),
      findsOneWidget,
    );
  });

  testWidgets('plays a short game to the results screen', (tester) async {
    final controller = await _pump(tester);
    await tester.tap(find.text('Easy'));
    await tester.pump();

    await tester.tap(find.text('Start Quiz'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Question 1 / 2'), findsOneWidget);
    expect(find.text('Who is this Pokémon?'), findsOneWidget);
    expect(find.text('0 pts'), findsOneWidget);
    expect(find.byType(QuizOptionButton), findsNWidgets(4));

    // Tap the correct option.
    await tester.tap(
      find.byType(QuizOptionButton).at(controller.question.correctIndex),
    );
    await tester.pump();
    expect(find.text('Correct! +100'), findsOneWidget);
    expect(find.textContaining("It's "), findsOneWidget);
    expect(find.text('Next Question'), findsOneWidget);

    await tester.tap(find.text('Next Question'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Question 2 / 2'), findsOneWidget);
    expect(find.textContaining('What type is'), findsOneWidget);

    // Wrong answer on the type question.
    await tester.tap(
      find
          .byType(QuizOptionButton)
          .at((controller.question.correctIndex + 1) % 4),
    );
    await tester.pump();
    expect(find.text('Wrong'), findsOneWidget);
    expect(find.textContaining(' type'), findsWidgets);
    expect(find.text('See Results'), findsOneWidget);

    await tester.tap(find.text('See Results'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Results'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('100'), findsWidgets); // score pill
    expect(find.text('New record! 🎉'), findsOneWidget);

    await tester.tap(find.text('Change difficulty'));
    await tester.pump();
    expect(find.text('Start Quiz'), findsOneWidget);
    expect(find.text('Best score: 100'), findsOneWidget);
  });

  testWidgets('answer options are announced as buttons', (tester) async {
    final handle = tester.ensureSemantics();
    final controller = await _pump(tester);
    controller.setDifficulty(QuizDifficulty.easy);
    await tester.pump();
    await tester.tap(find.text('Start Quiz'));
    await tester.pump();
    await tester.pump();

    final option = find.byType(QuizOptionButton).first;
    final semantics = tester.getSemantics(option);
    expect(semantics.flagsCollection.isButton, isTrue);
    expect(semantics.label, isNotEmpty);

    // After answering, the right option says so.
    controller.answer(controller.question.correctIndex);
    await tester.pump();
    final right = tester.getSemantics(
      find.byType(QuizOptionButton).at(controller.question.correctIndex),
    );
    expect(right.label, endsWith(', correct answer'));
    handle.dispose();
  });

  testWidgets('a Pokémon that cannot be loaded can be retried', (tester) async {
    final api = FakePokemonApi(varyingStats: true);
    final controller = await _pump(tester, api: api);
    controller.setDifficulty(QuizDifficulty.easy);
    api.failing.addAll(controller.allPokemon.map((p) => p.name));
    await tester.pump();

    await tester.tap(find.text('Start Quiz'));
    await tester.pump();
    await tester.pump();
    expect(find.text("Couldn't load this Pokémon."), findsOneWidget);

    api.failing.clear();
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump();
    expect(find.text("Couldn't load this Pokémon."), findsNothing);
    expect(find.byType(QuizOptionButton), findsNWidgets(4));
  });

  testWidgets('is available in Italian', (tester) async {
    await _pump(tester, locale: const Locale('it'));

    expect(find.text('Inizia il quiz'), findsOneWidget);
    expect(find.text('Difficoltà'), findsOneWidget);
    expect(find.text('Facile'), findsOneWidget);
  });

  testWidgets('the countdown pauses while the tab is hidden', (tester) async {
    final controller = await _pump(tester);
    controller.setDifficulty(QuizDifficulty.hard);
    await tester.pump();
    await tester.tap(find.text('Start Quiz'));
    await tester.pump();
    await tester.pump();

    await tester.pump(const Duration(seconds: 3));
    final before = controller.timeLeft.value;
    expect(before, lessThan(1));

    // Hide the tab the way the shell does: tickers off for its subtree.
    await tester.pumpWidget(
      testApp(
        TickerMode(enabled: false, child: QuizPage(controller: controller)),
      ),
    );
    await tester.pump(const Duration(seconds: 20));
    expect(controller.answered, isFalse);
    expect(controller.timeLeft.value, closeTo(before, 0.02));

    await tester.pumpWidget(
      testApp(
        TickerMode(enabled: true, child: QuizPage(controller: controller)),
      ),
    );
    await tester.pump(const Duration(seconds: 11));
    expect(controller.timedOut, isTrue);
  });

  testWidgets('fits a small phone, before and after answering', (tester) async {
    final controller = await _pump(tester);
    // 360 × 568 dp, an old compact phone (the helper's default is taller).
    tester.view.physicalSize = const Size(1080, 1704);
    tester.view.devicePixelRatio = 3;
    controller.setDifficulty(QuizDifficulty.hard);
    await tester.pump();
    await tester.tap(find.text('Start Quiz'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(QuizOptionButton), findsNWidgets(4));
    expect(tester.takeException(), isNull); // no RenderFlex overflow

    controller.answer(controller.question.correctIndex);
    await tester.pump();
    expect(find.text('Next Question'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('question kinds', () {
    Future<void> start(WidgetTester tester, QuizController controller) async {
      controller.setDifficulty(QuizDifficulty.easy);
      await tester.pump();
      await tester.tap(find.byType(QuizPrimaryButton).first);
      await tester.pump();
      await tester.pump();
    }

    testWidgets('a dual-type Pokémon is asked for both types', (tester) async {
      final controller = await _pump(
        tester,
        api: FakePokemonApi(types: ['fire', 'flying'], varyingStats: true),
        modes: [QuizMode.guessType],
      );
      await start(tester, controller);

      expect(find.textContaining('What types does'), findsOneWidget);
      expect(find.text('Fire / Flying'), findsOneWidget);
      expect(find.byType(QuizOptionButton), findsNWidgets(4));
    });

    testWidgets('a single-type Pokémon is asked for its type', (tester) async {
      final controller = await _pump(
        tester,
        api: FakePokemonApi(types: ['water'], varyingStats: true),
        modes: [QuizMode.guessType],
      );
      await start(tester, controller);

      expect(find.textContaining('What type is'), findsOneWidget);
      expect(find.text('Water'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(QuizOptionButton),
          matching: find.textContaining(' / '),
        ),
        findsNothing,
      );
    });

    testWidgets('a stat question shows both Pokémon and two answers', (
      tester,
    ) async {
      final controller = await _pump(tester, modes: [QuizMode.higherStat]);
      await start(tester, controller);

      final q = controller.question;
      expect(
        find.textContaining(RegExp(r'Which one has the higher')),
        findsOneWidget,
      );
      expect(find.byType(QuizOptionButton), findsNWidgets(2));
      expect(find.byType(PokemonImage), findsNWidgets(2));
      for (final name in q.options) {
        expect(
          find.text(name[0].toUpperCase() + name.substring(1)),
          findsOneWidget,
        );
      }

      await tester.tap(find.byType(QuizOptionButton).at(q.correctIndex));
      await tester.pump();
      expect(find.textContaining(' vs '), findsOneWidget);
    });

    testWidgets('a weakness question names the weaknesses', (tester) async {
      final controller = await _pump(
        tester,
        api: FakePokemonApi(types: ['fire'], varyingStats: true),
        modes: [QuizMode.superEffective],
      );
      await start(tester, controller);

      expect(
        find.textContaining('Which type is super effective against'),
        findsOneWidget,
      );
      final q = controller.question;
      await tester.tap(find.byType(QuizOptionButton).at(q.correctIndex));
      await tester.pump();
      expect(
        find.text(
          'Mon${_number(q)} takes extra damage from Water, Ground, Rock',
        ),
        findsOneWidget,
      );
    });

    testWidgets('the questions are translated', (tester) async {
      final controller = await _pump(
        tester,
        api: FakePokemonApi(types: ['fire', 'flying'], varyingStats: true),
        modes: [QuizMode.guessType],
        locale: const Locale('it'),
      );
      await start(tester, controller);

      expect(find.textContaining('Che tipi ha'), findsOneWidget);
      expect(find.text('Fuoco / Volante'), findsOneWidget);
    });
  });

  group('daily challenge', () {
    final today = DateTime(2026, 10, 23, 9);

    testWidgets('the start screen offers it, then shows the result', (
      tester,
    ) async {
      final controller = await _pump(
        tester,
        now: today,
        questionCount: 2,
        modes: [QuizMode.guessName],
      );
      expect(find.text('Daily challenge'), findsOneWidget);
      expect(find.text("Play today's challenge"), findsOneWidget);

      await tester.tap(find.text("Play today's challenge"));
      await tester.pump();
      await tester.pump();
      expect(controller.isDaily, isTrue);
      expect(find.text('Question 1 / 2'), findsOneWidget);

      for (var i = 0; i < 2; i++) {
        await tester.tap(
          find.byType(QuizOptionButton).at(controller.question.correctIndex),
        );
        await tester.pump();
        await tester.tap(find.byType(QuizPrimaryButton));
        await tester.pump();
        await tester.pump();
      }

      // Results of the challenge: no replay, a Back button instead.
      expect(find.text('Daily challenge'), findsOneWidget);
      expect(find.text('Play Again'), findsNothing);
      expect(find.text('🔥 1-day streak'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pump();

      expect(find.text("Play today's challenge"), findsNothing);
      expect(find.text('Today: 2 / 2 · 225 pts'), findsOneWidget);
      expect(find.text('🔥 1-day streak'), findsOneWidget);
    });

    testWidgets('is available in Italian', (tester) async {
      await _pump(tester, now: today, locale: const Locale('it'));

      expect(find.text('Sfida del giorno'), findsOneWidget);
      expect(find.text('Gioca la sfida di oggi'), findsOneWidget);
    });
  });

  group('sharing', () {
    Future<void> playToResults(
      WidgetTester tester,
      QuizController controller, {
      required bool daily,
    }) async {
      // The start buttons: Start first, the daily challenge's below it.
      final buttons = find.byType(QuizPrimaryButton);
      if (daily) {
        await tester.tap(buttons.last);
      } else {
        controller.setDifficulty(QuizDifficulty.easy);
        await tester.pump();
        await tester.tap(buttons.first);
      }
      await tester.pump();
      await tester.pump();
      for (var i = 0; i < 2; i++) {
        final q = controller.question;
        // First right, then wrong.
        final pick = i == 0 ? q.correctIndex : (q.correctIndex + 1) % 4;
        await tester.tap(find.byType(QuizOptionButton).at(pick));
        await tester.pump();
        await tester.tap(find.byType(QuizPrimaryButton));
        await tester.pump();
        await tester.pump();
      }
    }

    testWidgets('shares the score and one square per answer', (tester) async {
      final share = FakeShareService();
      final controller = await _pump(
        tester,
        share: share,
        modes: [QuizMode.guessName],
      );
      await playToResults(tester, controller, daily: false);

      await tester.tap(find.text('Share result'));
      await tester.pump();

      expect(share.shared, ['PokéFlutter Quiz (Easy)\n1/2 · 100 pts\n🟩🟥']);
    });

    testWidgets('the daily challenge is shared with its date', (tester) async {
      final share = FakeShareService();
      final controller = await _pump(
        tester,
        share: share,
        now: DateTime(2026, 10, 23, 9),
        modes: [QuizMode.guessName],
      );
      await playToResults(tester, controller, daily: true);

      await tester.tap(find.text('Share result'));
      await tester.pump();

      expect(share.shared, [
        'PokéFlutter Daily 2026-10-23\n1/2 · 100 pts\n🟩🟥',
      ]);
    });

    testWidgets('a share sheet that fails does not break the results', (
      tester,
    ) async {
      final controller = await _pump(
        tester,
        share: _BrokenShare(),
        modes: [QuizMode.guessName],
      );
      await playToResults(tester, controller, daily: false);

      await tester.tap(find.text('Share result'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Share result'), findsOneWidget);
    });

    testWidgets('is available in Italian', (tester) async {
      final share = FakeShareService();
      final controller = await _pump(
        tester,
        share: share,
        locale: const Locale('it'),
        modes: [QuizMode.guessName],
      );
      await playToResults(tester, controller, daily: false);

      await tester.tap(find.text('Condividi il risultato'));
      await tester.pump();

      expect(share.shared, ['PokéFlutter Quiz (Facile)\n1/2 · 100 pt\n🟩🟥']);
    });
  });
}

class _BrokenShare extends FakeShareService {
  @override
  Future<void> shareText(String text) async => throw StateError('no sheet');
}

String _number(QuizQuestion q) => q.subject.name.substring(3);
