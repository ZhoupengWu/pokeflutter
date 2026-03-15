import 'dart:math';
import '../model/pokemon_list_item.dart';
import '../model/quiz_model.dart';
import 'pokemon_costants.dart';

class QuizLogic {
  static final _random = Random();
  static final _allTypes = listPokemonTypeColor.keys.toList();

  /// Generates [count] questions from [allPokemon].
  /// Alternates between [QuizMode.guessName] and [QuizMode.guessType].
  static List<QuizQuestion> generateQuestions(
    List<PokemonListItem> allPokemon, {
    int count = 10,
  }) {
    if (allPokemon.length < 4) return [];

    final shuffled = List<PokemonListItem>.from(allPokemon)..shuffle(_random);
    final subjects = shuffled.take(count).toList();

    return subjects.asMap().entries.map((entry) {
      final mode = entry.key.isEven ? QuizMode.guessName : QuizMode.guessType;
      return mode == QuizMode.guessName
          ? _nameQuestion(entry.value, allPokemon)
          : _typeQuestion(entry.value);
    }).toList();
  }

  // ── Guess the name from the sprite ────────────────────────────────────────

  static QuizQuestion _nameQuestion(
    PokemonListItem subject,
    List<PokemonListItem> allPokemon,
  ) {
    final distractors = _pickDistinctNames(subject.name, allPokemon, 3);
    final options = [subject.name, ...distractors]..shuffle(_random);
    final correctIndex = options.indexOf(subject.name);

    return QuizQuestion(
      subject: subject,
      options: options,
      correctIndex: correctIndex,
      mode: QuizMode.guessName,
    );
  }

  // ── Guess the type from the name ──────────────────────────────────────────

  static QuizQuestion _typeQuestion(PokemonListItem subject) {
    // We don't know the type until the API responds, so we use a
    // random correct type from the pool and 3 wrong ones.
    // The quiz page resolves the real type after fetching details.
    final correctType = _allTypes[_random.nextInt(_allTypes.length)];
    final distractors = _pickDistinctStrings(correctType, _allTypes, 3);
    final options = [correctType, ...distractors]..shuffle(_random);
    final correctIndex = options.indexOf(correctType);

    return QuizQuestion(
      subject: subject,
      options: options,
      correctIndex: correctIndex,
      mode: QuizMode.guessType,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static List<String> _pickDistinctNames(
    String exclude,
    List<PokemonListItem> pool,
    int count,
  ) {
    final candidates =
        pool.map((p) => p.name).where((n) => n != exclude).toList()
          ..shuffle(_random);
    return candidates.take(count).toList();
  }

  static List<String> _pickDistinctStrings(
    String exclude,
    List<String> pool,
    int count,
  ) {
    final candidates = pool.where((s) => s != exclude).toList()
      ..shuffle(_random);
    return candidates.take(count).toList();
  }
}