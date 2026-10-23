import 'pokemon_list_item.dart';

enum QuizMode {
  /// Who is this silhouette?
  guessName,

  /// What type (or which two types) does this Pokémon have?
  guessType,

  /// Which of these two Pokémon has the higher base stat?
  higherStat,

  /// Which of these types is super effective against this Pokémon?
  superEffective,
}

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
  /// Separates the two types of a pair answer ("fire/flying").
  static const typeSeparator = '/';

  final PokemonListItem subject; // Pokémon being asked about
  final List<String> options; // answer strings (see [mode] for what they are)
  final int correctIndex; // index of the right option, -1 until resolved
  final QuizMode mode;

  /// The opponent of a [QuizMode.higherStat] question.
  final PokemonListItem? rival;

  /// The compared base stat of a [QuizMode.higherStat] question (a PokéAPI
  /// stat id such as `special-attack`).
  final String? stat;

  /// Seeds the choices that need the Pokémon's data (right answer and
  /// distractors), so that the same questions give the same options to
  /// everybody, as the daily challenge needs.
  final int seed;

  /// Types of the subject, known once the question is resolved.
  final List<String> types;

  const QuizQuestion({
    required this.subject,
    required this.options,
    required this.correctIndex,
    required this.mode,
    this.rival,
    this.stat,
    this.seed = 0,
    this.types = const [],
  });

  QuizQuestion copyWith({
    List<String>? options,
    int? correctIndex,
    QuizMode? mode,
    String? stat,
    List<String>? types,
  }) => QuizQuestion(
    subject: subject,
    options: options ?? this.options,
    correctIndex: correctIndex ?? this.correctIndex,
    mode: mode ?? this.mode,
    rival: rival,
    stat: stat ?? this.stat,
    seed: seed,
    types: types ?? this.types,
  );

  /// Name questions are complete when created; the others need the Pokémon
  /// details first. See [QuizLogic.resolve].
  bool get isResolved => correctIndex >= 0;

  String get correctAnswer => options[correctIndex];

  /// A type question about a dual-type Pokémon asks for both types: its
  /// options are pairs, never a single type that would also be true.
  bool get asksForPair => mode == QuizMode.guessType && types.length > 1;

  /// The types an option stands for (one, or two for a pair).
  static List<String> typesOfOption(String option) =>
      option.split(typeSeparator);
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

  /// Whether each answer so far was right, in order (the share grid).
  final List<bool> outcomes = [];

  QuizResult({required this.totalQuestions});

  static const pointsPerCorrect = 100;
  static const streakBonus = 25;
  static const maxStreakBonusSteps = 4;

  /// Records an answer and returns the points it earned (0 when wrong).
  int record({required bool isCorrect}) {
    answered++;
    outcomes.add(isCorrect);
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
