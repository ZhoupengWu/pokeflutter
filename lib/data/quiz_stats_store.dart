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

/// Persists the best quiz results per difficulty with `shared_preferences`.
class QuizStatsStore {
  QuizStatsStore();

  static const _key = 'quiz_records_v1';

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
