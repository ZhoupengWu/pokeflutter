import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/controllers/quiz_controller.dart';
import 'package:pokeflutter/model/quiz_model.dart';
import 'package:pokeflutter/data/quiz_stats_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/quiz_fakes.dart';

QuizController _controller({
  FakePokemonApi? api,
  int questionCount = 3,
  QuizStatsStore? stats,
}) => QuizController(
  api: api ?? FakePokemonApi(),
  repository: fakeRepository(),
  stats: stats ?? QuizStatsStore.test(),
  questionCount: questionCount,
);

/// Answers the current question with its correct option.
void _answerCorrectly(QuizController c) => c.answer(c.question.correctIndex);

/// Answers the current question with a wrong option.
void _answerWrong(QuizController c) =>
    c.answer((c.question.correctIndex + 1) % c.question.options.length);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('init loads the list, so a quiz can start', () async {
    final c = _controller();
    expect(c.canStart, isFalse);

    await c.init();

    expect(c.allPokemon, hasLength(30));
    expect(c.canStart, isTrue);
    expect(c.screen, QuizScreen.start);
    c.dispose();
  });

  test('start loads the first question and unlocks answering', () async {
    final c = _controller();
    await c.init();

    final start = c.start();
    expect(c.screen, QuizScreen.quiz);
    expect(c.isLoadingPokemon, isTrue);
    expect(c.canAnswer, isFalse);
    await start;

    expect(c.isLoadingPokemon, isFalse);
    expect(c.pokemon, isNotNull);
    expect(c.question.isResolved, isTrue);
    expect(c.canAnswer, isTrue);
    c.dispose();
  });

  test(
    'a correct answer scores points and a wrong one breaks the streak',
    () async {
      final c = _controller();
      await c.init();
      await c.start();

      _answerCorrectly(c);
      expect(c.answered, isTrue);
      expect(c.lastPoints, 100);
      expect(c.result.score, 100);

      await c.next();
      expect(c.answered, isFalse);
      expect(c.index, 1);
      _answerWrong(c);
      expect(c.lastPoints, 0);
      expect(c.result.streak, 0);
      expect(c.result.wrong, 1);
      c.dispose();
    },
  );

  test('answers are ignored once the question is answered', () async {
    final c = _controller();
    await c.init();
    await c.start();

    _answerCorrectly(c);
    _answerWrong(c);

    expect(c.result.answered, 1);
    expect(c.result.correct, 1);
    c.dispose();
  });

  test('type questions are resolved from the real types', () async {
    final c = _controller(
      api: FakePokemonApi(types: ['water']),
      questionCount: 2,
    );
    await c.init();
    await c.start();
    await _skipTo(c, QuizMode.guessType);

    expect(c.question.isResolved, isTrue);
    expect(c.question.correctAnswer, 'water');
    c.dispose();
  });

  test('a failed load offers a retry and cannot be answered', () async {
    final api = FakePokemonApi();
    final c = _controller(api: api);
    await c.init();
    // The failure is on the first question, whichever Pokémon it is.
    api.failing.addAll(c.allPokemon.map((p) => p.name));

    await c.start();
    expect(c.pokemon, isNull);
    expect(c.isLoadingPokemon, isFalse);
    expect(c.canAnswer, isFalse);
    c.answer(0);
    expect(c.result.answered, 0);

    api.failing.clear();
    await c.retry();
    expect(c.pokemon, isNotNull);
    expect(c.canAnswer, isTrue);
    c.dispose();
  });

  test('finishing a game shows the results and saves the record', () async {
    final stats = QuizStatsStore.test();
    final c = _controller(stats: stats);
    await c.init();
    await c.start();

    for (var i = 0; i < 3; i++) {
      _answerCorrectly(c);
      await c.next();
    }

    expect(c.screen, QuizScreen.results);
    expect(c.result.correct, 3);
    expect(c.isNewRecord, isTrue);
    expect(c.record.gamesPlayed, 1);
    expect(c.record.bestScore, c.result.score);

    // Playing again starts from scratch; a worse game is no record.
    await c.start();
    expect(c.screen, QuizScreen.quiz);
    expect(c.result.score, 0);
    expect(c.isNewRecord, isFalse);
    for (var i = 0; i < 3; i++) {
      _answerWrong(c);
      await c.next();
    }
    expect(c.isNewRecord, isFalse);
    expect(c.record.gamesPlayed, 2);
    c.dispose();
  });

  test('next does nothing before the question is answered', () async {
    final c = _controller();
    await c.init();
    await c.start();

    await c.next();

    expect(c.index, 0);
    c.dispose();
  });

  test('difficulty decides which Pokémon are asked about', () async {
    final c = _controller();
    await c.init();
    c.setDifficulty(QuizDifficulty.easy);
    await c.start();

    expect(c.questions.every((q) => q.subject.id <= 151), isTrue);
    expect(c.record, same(c.records[QuizDifficulty.easy]));
    c.dispose();
  });

  group('timer', () {
    testWidgets('runs out: the question counts as wrong', (tester) async {
      final c = _controller();
      await c.init();
      c.setDifficulty(QuizDifficulty.hard); // 10 s
      await c.start();
      expect(c.timeLeft.value, 1);

      await tester.pump(const Duration(seconds: 5));
      expect(c.answered, isFalse);
      expect(c.timeLeft.value, closeTo(0.5, 0.02));

      await tester.pump(const Duration(seconds: 6));
      expect(c.answered, isTrue);
      expect(c.timedOut, isTrue);
      expect(c.selectedOption, isNull);
      expect(c.result.wrong, 1);
      expect(c.lastPoints, 0);
      c.dispose();
    });

    testWidgets('answering stops the clock', (tester) async {
      final c = _controller();
      await c.init();
      c.setDifficulty(QuizDifficulty.hard);
      await c.start();

      await tester.pump(const Duration(seconds: 2));
      _answerCorrectly(c);
      await tester.pump(const Duration(seconds: 20));

      expect(c.timedOut, isFalse);
      expect(c.result.correct, 1);
      c.dispose();
    });

    testWidgets('pause freezes the countdown and resume continues it', (
      tester,
    ) async {
      final c = _controller();
      await c.init();
      c.setDifficulty(QuizDifficulty.hard);
      await c.start();

      await tester.pump(const Duration(seconds: 4));
      c.pause();
      await tester.pump(const Duration(seconds: 30));
      expect(c.answered, isFalse);
      expect(c.timeLeft.value, closeTo(0.6, 0.02));

      c.resume();
      await tester.pump(const Duration(seconds: 7));
      expect(c.timedOut, isTrue);
      c.dispose();
    });

    testWidgets('the easy level has no timer', (tester) async {
      final c = _controller();
      await c.init();
      c.setDifficulty(QuizDifficulty.easy);
      await c.start();

      await tester.pump(const Duration(minutes: 5));

      expect(c.answered, isFalse);
      expect(c.timeLeft.value, 1);
      c.dispose();
    });

    testWidgets('each question gets a fresh clock', (tester) async {
      final c = _controller();
      await c.init();
      c.setDifficulty(QuizDifficulty.hard);
      await c.start();

      await tester.pump(const Duration(seconds: 6));
      _answerCorrectly(c);
      await c.next();
      expect(c.timeLeft.value, 1);
      await tester.pump(const Duration(seconds: 5));

      expect(c.answered, isFalse);
      expect(c.timeLeft.value, closeTo(0.5, 0.02));
      c.dispose();
    });
  });
}

/// Moves on (answering anything) until the current question has [mode].
Future<void> _skipTo(QuizController c, QuizMode mode) async {
  while (c.question.mode != mode) {
    _answerCorrectly(c);
    await c.next();
  }
}
