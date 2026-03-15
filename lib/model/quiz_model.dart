import '../model/pokemon_list_item.dart';

enum QuizMode { guessName, guessType }

class QuizQuestion {
  final PokemonListItem subject; // Pokémon being asked about
  final List<String> options; // 4 answer strings
  final int correctIndex; // index of the correct answer in options
  final QuizMode mode;

  const QuizQuestion({
    required this.subject,
    required this.options,
    required this.correctIndex,
    required this.mode,
  });

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