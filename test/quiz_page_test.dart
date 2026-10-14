import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/controllers/quiz_controller.dart';
import 'package:pokeflutter/model/quiz_model.dart';
import 'package:pokeflutter/utils/quiz_stats_store.dart';
import 'package:pokeflutter/views/quiz/quiz_page.dart';
import 'package:pokeflutter/views/quiz/quiz_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/quiz_fakes.dart';
import 'support/test_app.dart';

Future<QuizController> _pump(
  WidgetTester tester, {
  FakePokemonApi? api,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final controller = QuizController(
    api: api ?? FakePokemonApi(),
    repository: fakeRepository(),
    stats: QuizStatsStore.test(),
    questionCount: 2,
  );
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    testApp(QuizPage(controller: controller), locale: locale),
  );
  await tester.pump();
  return controller;
}

void main() {
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
    final api = FakePokemonApi();
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
}
