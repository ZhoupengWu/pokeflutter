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
}
