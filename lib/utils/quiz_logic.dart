import 'dart:math';
import '../model/pokemon_list_item.dart';
import '../model/quiz_model.dart';
import 'pokemon_constants.dart';

class QuizLogic {
  static final _random = Random();
  static final _allTypes = listPokemonTypeColor.keys.toList();

  /// Generates [count] questions from [allPokemon].
  /// Alternates between [QuizMode.guessName] and [QuizMode.guessType].
  /// Type questions come back unresolved — see [resolveTypeQuestion].
  ///
  /// Only the Pokémon allowed by [difficulty] are asked about or offered as
  /// wrong answers.
  static List<QuizQuestion> generateQuestions(
    List<PokemonListItem> allPokemon, {
    int count = 10,
    QuizDifficulty difficulty = QuizDifficulty.normal,
  }) {
    final pool = allPokemon.where(difficulty.includes).toList();
    if (pool.length < 4) return [];

    final shuffled = List<PokemonListItem>.from(pool)..shuffle(_random);
    final subjects = shuffled.take(count).toList();

    return subjects.asMap().entries.map((entry) {
      final mode = entry.key.isEven ? QuizMode.guessName : QuizMode.guessType;
      return mode == QuizMode.guessName
          ? _nameQuestion(entry.value, pool)
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

  /// The real types are only known after the API responds, so the question is
  /// created unresolved (no options). The quiz page completes it with
  /// [resolveTypeQuestion] once the Pokémon details are available.
  static QuizQuestion _typeQuestion(PokemonListItem subject) {
    return QuizQuestion(
      subject: subject,
      options: const [],
      correctIndex: 0,
      mode: QuizMode.guessType,
    );
  }

  /// Builds the answer options of a [QuizMode.guessType] question from the
  /// real [pokemonTypes] of its subject.
  ///
  /// One of the Pokémon's own types is the correct answer; the distractors
  /// never include any of its types, so there is always exactly one right
  /// option, even for dual-type Pokémon.
  static QuizQuestion resolveTypeQuestion(
    QuizQuestion question,
    List<String> pokemonTypes,
  ) {
    final owned = pokemonTypes.map((t) => t.toLowerCase()).toList();
    if (owned.isEmpty) return question;
    final correctType = owned[_random.nextInt(owned.length)];
    final distractors = _allTypes.where((t) => !owned.contains(t)).toList()
      ..shuffle(_random);
    final options = [correctType, ...distractors.take(3)]..shuffle(_random);

    return QuizQuestion(
      subject: question.subject,
      options: options,
      correctIndex: options.indexOf(correctType),
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
}
