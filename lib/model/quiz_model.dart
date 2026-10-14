import '../model/pokemon_list_item.dart';

enum QuizMode { guessName, guessType }

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

  QuizResult({required this.totalQuestions});

  int get wrong => answered - correct;
  double get accuracy => answered == 0 ? 0 : correct / answered;
  bool get isFinished => answered >= totalQuestions;
}
