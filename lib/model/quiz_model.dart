import '../model/pokemon_list_item.dart';

enum QuizMode { guessName, guessType }

/// How hard a quiz is: which Pokémon can come up and how long you get.
enum QuizDifficulty {
  /// First generation only, no timer.
  easy(maxPokedexNumber: 151, secondsPerQuestion: null),

  /// Every Pokémon, 20 seconds per question.
  normal(maxPokedexNumber: 1025, secondsPerQuestion: 20),

  /// Every Pokémon, 10 seconds per question.
  hard(maxPokedexNumber: 1025, secondsPerQuestion: 10);

  const QuizDifficulty({
    required this.maxPokedexNumber,
    required this.secondsPerQuestion,
  });

  /// Highest Pokédex number that can be asked about. Alternate forms
  /// (Mega, regional… numbered from 10001) are never asked about.
  final int maxPokedexNumber;

  /// Time limit per question, or null for none.
  final int? secondsPerQuestion;

  bool get isTimed => secondsPerQuestion != null;

  bool includes(PokemonListItem pokemon) => pokemon.id <= maxPokedexNumber;
}

class QuizQuestion {
  final PokemonListItem subject; // Pokémon being asked about
  final List<String> options; // 4 answer strings (empty until resolved)
  final int correctIndex; // index of the correct answer in options
  final QuizMode mode;

  const QuizQuestion({
    required this.subject,
    required this.options,
    required this.correctIndex,
    required this.mode,
  });

  /// A [QuizMode.guessType] question is created without options because the
  /// real type is only known once the Pokémon details have been fetched.
  /// See [QuizLogic.resolveTypeQuestion].
  bool get isResolved => options.isNotEmpty;

  String get correctAnswer => options[correctIndex];
}

class QuizResult {
  final int totalQuestions;
  int correct = 0;
  int answered = 0;

  /// Points earned: 100 per correct answer, plus 25 for each answer already
  /// in the current streak (up to four).
  int score = 0;

  /// Correct answers in a row right now.
  int streak = 0;

  /// Longest run of correct answers in this game.
  int bestStreak = 0;

  QuizResult({required this.totalQuestions});

  static const pointsPerCorrect = 100;
  static const streakBonus = 25;
  static const maxStreakBonusSteps = 4;

  /// Records an answer and returns the points it earned (0 when wrong).
  int record({required bool isCorrect}) {
    answered++;
    if (!isCorrect) {
      streak = 0;
      return 0;
    }
    final points =
        pointsPerCorrect +
        streakBonus *
            (streak < maxStreakBonusSteps ? streak : maxStreakBonusSteps);
    correct++;
    streak++;
    if (streak > bestStreak) bestStreak = streak;
    score += points;
    return points;
  }

  int get wrong => answered - correct;
  double get accuracy => answered == 0 ? 0 : correct / answered;
  bool get isFinished => answered >= totalQuestions;
}
