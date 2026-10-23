import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/quiz_model.dart';

/// Best results for one [QuizDifficulty].
class QuizRecord {
  final int bestScore;
  final int bestStreak;
  final int gamesPlayed;

  const QuizRecord({
    this.bestScore = 0,
    this.bestStreak = 0,
    this.gamesPlayed = 0,
  });

  Map<String, dynamic> toJson() => {
    'bestScore': bestScore,
    'bestStreak': bestStreak,
    'gamesPlayed': gamesPlayed,
  };

  factory QuizRecord.fromJson(Map<String, dynamic> json) => QuizRecord(
    bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
    bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
    gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
  );
}

DateTime _dayBefore(DateTime date) =>
    DateTime(date.year, date.month, date.day - 1);

/// The daily challenge: today's result (if played) and the streak of days.
class DailyRecord {
  const DailyRecord({
    this.lastDate,
    this.score = 0,
    this.outcomes = const [],
    this.streak = 0,
    this.bestStreak = 0,
    this.gamesPlayed = 0,
  });

  /// Day of the last game, as [QuizStatsStore.dateKey] (null before the first).
  final String? lastDate;

  /// Score and per-question outcomes of that game.
  final int score;
  final List<bool> outcomes;

  /// Consecutive days played up to [lastDate].
  final int streak;
  final int bestStreak;
  final int gamesPlayed;

  int get correct => outcomes.where((o) => o).length;

  bool isDoneOn(String dateKey) => lastDate == dateKey;

  /// The streak still alive on [date]: played today or yesterday, else broken.
  int streakOn(DateTime date) =>
      lastDate == QuizStatsStore.dateKey(date) ||
          lastDate == QuizStatsStore.dateKey(_dayBefore(date))
      ? streak
      : 0;

  Map<String, dynamic> toJson() => {
    'lastDate': lastDate,
    'score': score,
    'outcomes': outcomes.map((o) => o ? '1' : '0').join(),
    'streak': streak,
    'bestStreak': bestStreak,
    'gamesPlayed': gamesPlayed,
  };

  factory DailyRecord.fromJson(Map<String, dynamic> json) => DailyRecord(
    lastDate: json['lastDate'] as String?,
    score: (json['score'] as num?)?.toInt() ?? 0,
    outcomes: [
      for (final c in ((json['outcomes'] as String?) ?? '').split(''))
        if (c == '1' || c == '0') c == '1',
    ],
    streak: (json['streak'] as num?)?.toInt() ?? 0,
    bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
    gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
  );
}

/// Persists the best quiz results per difficulty, and the daily challenge,
/// with `shared_preferences`.
class QuizStatsStore {
  QuizStatsStore();

  static const _key = 'quiz_records_v1';
  static const _dailyKey = 'quiz_daily_v1';

  /// A calendar day as `2026-10-23`: the key of the daily challenge.
  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// The seed of a day's challenge: the same date gives the same questions.
  static int dailySeed(DateTime date) =>
      date.year * 10000 + date.month * 100 + date.day;

  /// The saved daily challenge (an empty record when none).
  Future<DailyRecord> loadDaily() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dailyKey);
    if (raw == null) return const DailyRecord();
    try {
      return DailyRecord.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const DailyRecord(); // corrupted data: start over
    }
  }

  /// Records the daily game of [date]. Playing on consecutive days builds the
  /// streak; a gap starts it again.
  Future<DailyRecord> submitDaily(DateTime date, QuizResult result) async {
    final previous = await loadDaily();
    final today = dateKey(date);
    if (previous.lastDate == today) return previous; // one game a day
    final streak = previous.lastDate == dateKey(_dayBefore(date))
        ? previous.streak + 1
        : 1;
    final record = DailyRecord(
      lastDate: today,
      score: result.score,
      outcomes: List.of(result.outcomes),
      streak: streak,
      bestStreak: streak > previous.bestStreak ? streak : previous.bestStreak,
      gamesPlayed: previous.gamesPlayed + 1,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyKey, jsonEncode(record.toJson()));
    return record;
  }

  /// The saved record for every difficulty (empty records when none).
  Future<Map<QuizDifficulty, QuizRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final records = {
      for (final d in QuizDifficulty.values) d: const QuizRecord(),
    };
    final raw = prefs.getString(_key);
    if (raw == null) return records;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final d in QuizDifficulty.values) {
        final entry = decoded[d.name];
        if (entry is Map<String, dynamic>) {
          records[d] = QuizRecord.fromJson(entry);
        }
      }
    } catch (_) {
      // Corrupted data: start over rather than crash.
    }
    return records;
  }

  /// Records a finished game. Returns true when it beat the previous best
  /// score (the first game with a score above zero counts as a record).
  Future<bool> submit(QuizDifficulty difficulty, QuizResult result) async {
    final records = await load();
    final previous = records[difficulty]!;
    final isRecord = result.score > previous.bestScore;
    records[difficulty] = QuizRecord(
      bestScore: isRecord ? result.score : previous.bestScore,
      bestStreak: result.bestStreak > previous.bestStreak
          ? result.bestStreak
          : previous.bestStreak,
      gamesPlayed: previous.gamesPlayed + 1,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({
        for (final e in records.entries) e.key.name: e.value.toJson(),
      }),
    );
    return isRecord;
  }
}
