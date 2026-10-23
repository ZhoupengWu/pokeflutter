import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/model/quiz_model.dart';
import 'package:pokeflutter/data/quiz_stats_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

QuizResult _game({required int correct, int streak = 0}) {
  final result = QuizResult(totalQuestions: 10);
  for (var i = 0; i < correct; i++) {
    result.record(isCorrect: true);
  }
  for (var i = correct; i < 10; i++) {
    result.record(isCorrect: false);
  }
  result.bestStreak = streak == 0 ? correct : streak;
  return result;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('starts with empty records', () async {
    final records = await QuizStatsStore().load();

    expect(records.keys, QuizDifficulty.values);
    expect(records.values.map((r) => r.gamesPlayed), everyElement(0));
  });

  test('the first scoring game is a record and is saved', () async {
    final store = QuizStatsStore();

    expect(
      await store.submit(QuizDifficulty.normal, _game(correct: 4)),
      isTrue,
    );

    final record = (await QuizStatsStore().load())[QuizDifficulty.normal]!;
    expect(record.bestScore, _game(correct: 4).score);
    expect(record.gamesPlayed, 1);
  });

  test('only a better score replaces the record', () async {
    final store = QuizStatsStore();
    await store.submit(QuizDifficulty.hard, _game(correct: 8));

    expect(await store.submit(QuizDifficulty.hard, _game(correct: 3)), isFalse);
    expect(await store.submit(QuizDifficulty.hard, _game(correct: 10)), isTrue);

    final record = (await store.load())[QuizDifficulty.hard]!;
    expect(record.bestScore, _game(correct: 10).score);
    expect(record.bestStreak, 10);
    expect(record.gamesPlayed, 3);
  });

  test('difficulties keep separate records', () async {
    final store = QuizStatsStore();
    await store.submit(QuizDifficulty.easy, _game(correct: 9));

    final records = await store.load();
    expect(records[QuizDifficulty.easy]!.gamesPlayed, 1);
    expect(records[QuizDifficulty.normal]!.gamesPlayed, 0);
  });

  test('corrupted data is ignored', () async {
    SharedPreferences.setMockInitialValues({'quiz_records_v1': '{not json'});

    final records = await QuizStatsStore().load();
    expect(records[QuizDifficulty.easy]!.bestScore, 0);
  });

  group('daily challenge', () {
    test('starts empty', () async {
      final daily = await QuizStatsStore().loadDaily();

      expect(daily.lastDate, isNull);
      expect(daily.gamesPlayed, 0);
      expect(daily.isDoneOn('2026-10-23'), isFalse);
      expect(daily.streakOn(DateTime(2026, 10, 23)), 0);
    });

    test('dates are keyed and seeded by their day only', () {
      expect(
        QuizStatsStore.dateKey(DateTime(2026, 3, 5, 23, 59)),
        '2026-03-05',
      );
      expect(QuizStatsStore.dailySeed(DateTime(2026, 3, 5, 8)), 20260305);
      expect(
        QuizStatsStore.dailySeed(DateTime(2026, 3, 5, 8)),
        QuizStatsStore.dailySeed(DateTime(2026, 3, 5, 22)),
      );
      expect(
        QuizStatsStore.dailySeed(DateTime(2026, 3, 6)),
        isNot(QuizStatsStore.dailySeed(DateTime(2026, 3, 5))),
      );
    });

    test('saves the result of the day, with every answer', () async {
      final store = QuizStatsStore();
      final result = QuizResult(totalQuestions: 3)
        ..record(isCorrect: true)
        ..record(isCorrect: false)
        ..record(isCorrect: true);

      await store.submitDaily(DateTime(2026, 10, 23), result);
      final daily = await store.loadDaily();

      expect(daily.isDoneOn('2026-10-23'), isTrue);
      expect(daily.score, 200);
      expect(daily.outcomes, [true, false, true]);
      expect(daily.correct, 2);
      expect(daily.streak, 1);
      expect(daily.gamesPlayed, 1);
    });

    test(
      'playing on consecutive days builds a streak, a gap breaks it',
      () async {
        final store = QuizStatsStore();
        final result = _game(correct: 5);

        await store.submitDaily(DateTime(2026, 10, 30), result);
        await store.submitDaily(DateTime(2026, 10, 31), result); // month end
        var daily = await store.submitDaily(DateTime(2026, 11, 1), result);
        expect(daily.streak, 3);
        expect(daily.streakOn(DateTime(2026, 11, 2)), 3); // still alive
        expect(daily.streakOn(DateTime(2026, 11, 3)), 0); // missed a day

        daily = await store.submitDaily(DateTime(2026, 11, 3), result);
        expect(daily.streak, 1);
        expect(daily.bestStreak, 3);
        expect(daily.gamesPlayed, 4);
      },
    );

    test('a second game on the same day changes nothing', () async {
      final store = QuizStatsStore();
      await store.submitDaily(DateTime(2026, 10, 23), _game(correct: 4));

      final again = await store.submitDaily(
        DateTime(2026, 10, 23),
        _game(correct: 10),
      );

      expect(again.gamesPlayed, 1);
      expect(again.correct, 4);
    });

    test('corrupted data starts over', () async {
      SharedPreferences.setMockInitialValues({'quiz_daily_v1': '{oops'});

      final daily = await QuizStatsStore().loadDaily();

      expect(daily.gamesPlayed, 0);
    });
  });
}
