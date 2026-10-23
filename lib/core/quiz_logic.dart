import 'dart:math';
import '../model/pokemon_list_item.dart';
import '../model/quiz_model.dart';
import 'type_chart.dart';

class QuizLogic {
  /// The base stats a [QuizMode.higherStat] question can compare.
  static const comparedStats = [
    'hp',
    'attack',
    'defense',
    'special-attack',
    'special-defense',
    'speed',
  ];

  /// Generates [count] questions from [allPokemon]. Every group of questions
  /// covers each [QuizMode] once, in a random order. Passing [modes] asks only
  /// those, in that order, over and over.
  ///
  /// Only the questions that need no Pokémon details come back complete
  /// ([QuizMode.guessName]); the others are unresolved — see [resolve].
  /// Only the Pokémon allowed by [difficulty] are asked about or offered as
  /// wrong answers. The same [random] gives the same questions, which is how
  /// the daily challenge is the same for everyone.
  static List<QuizQuestion> generateQuestions(
    List<PokemonListItem> allPokemon, {
    int count = 10,
    QuizDifficulty difficulty = QuizDifficulty.normal,
    Random? random,
    List<QuizMode>? modes,
  }) {
    final rng = random ?? Random();
    final pool = allPokemon.where(difficulty.includes).toList();
    if (pool.length < 4) return [];

    final subjects = (List<PokemonListItem>.of(
      pool,
    )..shuffle(rng)).take(count).toList();
    final order = <QuizMode>[];
    while (order.length < subjects.length) {
      order.addAll(modes ?? (List<QuizMode>.of(QuizMode.values)..shuffle(rng)));
    }

    return [
      for (var i = 0; i < subjects.length; i++)
        switch (order[i]) {
          QuizMode.guessName => _nameQuestion(subjects[i], pool, rng),
          QuizMode.higherStat => _statQuestion(subjects[i], pool, rng),
          final mode => QuizQuestion(
            subject: subjects[i],
            options: const [],
            correctIndex: -1,
            mode: mode,
            seed: rng.nextInt(1 << 30),
          ),
        },
    ];
  }

  // ── Guess the name from the sprite ────────────────────────────────────────

  static QuizQuestion _nameQuestion(
    PokemonListItem subject,
    List<PokemonListItem> pool,
    Random rng,
  ) {
    final candidates =
        pool.map((p) => p.name).where((n) => n != subject.name).toList()
          ..shuffle(rng);
    final options = [subject.name, ...candidates.take(3)]..shuffle(rng);

    return QuizQuestion(
      subject: subject,
      options: options,
      correctIndex: options.indexOf(subject.name),
      mode: QuizMode.guessName,
      seed: rng.nextInt(1 << 30),
    );
  }

  // ── Which one has the higher stat ─────────────────────────────────────────

  /// The two Pokémon are known up front (their sprites are shown side by
  /// side, in the order of the options); the winner depends on their stats.
  static QuizQuestion _statQuestion(
    PokemonListItem subject,
    List<PokemonListItem> pool,
    Random rng,
  ) {
    PokemonListItem rival;
    do {
      rival = pool[rng.nextInt(pool.length)];
    } while (rival.name == subject.name);
    final options = [subject.name, rival.name];
    if (rng.nextBool()) options.insert(0, options.removeLast());

    return QuizQuestion(
      subject: subject,
      options: options,
      correctIndex: -1,
      mode: QuizMode.higherStat,
      rival: rival,
      stat: comparedStats[rng.nextInt(comparedStats.length)],
      seed: rng.nextInt(1 << 30),
    );
  }

  // ── Resolving the questions that need the Pokémon's data ──────────────────

  /// Completes [question] once the data of its Pokémon is known: [types] of
  /// the subject, and for [QuizMode.higherStat] the base [stats] of the
  /// subject and of its rival (PokéAPI stat id → value).
  ///
  /// The result only depends on the question and the data, never on chance
  /// beyond [QuizQuestion.seed]. A question that cannot be asked about this
  /// Pokémon (a tie on every stat, no weakness) becomes a type question.
  static QuizQuestion resolve(
    QuizQuestion question, {
    required List<String> types,
    Map<String, int> stats = const {},
    Map<String, int> rivalStats = const {},
  }) {
    if (question.isResolved) return question;
    return switch (question.mode) {
      QuizMode.guessName => question,
      QuizMode.guessType => resolveTypeQuestion(question, types),
      QuizMode.superEffective => resolveSuperEffective(question, types),
      QuizMode.higherStat => resolveHigherStat(
        question,
        types: types,
        stats: stats,
        rivalStats: rivalStats,
      ),
    };
  }

  /// Builds the options of a [QuizMode.guessType] question from the real
  /// [pokemonTypes] of its subject.
  ///
  /// A single-type Pokémon is offered single types, none of them its own but
  /// the answer. A dual-type Pokémon is offered pairs of types, and the answer
  /// is the whole pair: asking for "a type" would make both of its types
  /// right. No other option is the same pair, in any order.
  static QuizQuestion resolveTypeQuestion(
    QuizQuestion question,
    List<String> pokemonTypes,
  ) {
    final owned = pokemonTypes.map((t) => t.toLowerCase()).toSet().toList();
    if (owned.isEmpty) return question;
    final rng = Random(question.seed);

    final answer = owned.length == 1
        ? owned.first
        : owned.take(2).join(QuizQuestion.typeSeparator);
    final options = owned.length == 1
        ? _singleOptions(owned.first, rng)
        : _pairOptions(owned[0], owned[1], rng);
    options.shuffle(rng);

    return question.copyWith(
      mode: QuizMode.guessType,
      options: options,
      correctIndex: options.indexOf(answer),
      types: owned,
    );
  }

  static List<String> _singleOptions(String type, Random rng) {
    final others = TypeChart.types.where((t) => t != type).toList()
      ..shuffle(rng);
    return [type, ...others.take(3)];
  }

  static String _pairKey(String a, String b) =>
      ([a, b]..sort()).join(QuizQuestion.typeSeparator);

  static List<String> _pairOptions(String a, String b, Random rng) {
    final options = ['$a${QuizQuestion.typeSeparator}$b'];
    final seen = {_pairKey(a, b)};
    void add(String x, String y) {
      if (x == y || !seen.add(_pairKey(x, y))) return;
      options.add('$x${QuizQuestion.typeSeparator}$y');
    }

    // Near misses first: one real type with a wrong partner.
    final foreign = TypeChart.types.where((t) => t != a && t != b).toList()
      ..shuffle(rng);
    final kept = [a, b]..shuffle(rng);
    for (var i = 0; i < 2; i++) {
      rng.nextBool() ? add(kept[i], foreign[i]) : add(foreign[i], kept[i]);
    }
    while (options.length < 4) {
      add(
        TypeChart.types[rng.nextInt(TypeChart.types.length)],
        TypeChart.types[rng.nextInt(TypeChart.types.length)],
      );
    }
    return options;
  }

  /// A [QuizMode.superEffective] question: one of the attacking types the
  /// subject is weak to is the answer; the others hit it for normal damage or
  /// less. A Pokémon without weaknesses gets a type question instead.
  static QuizQuestion resolveSuperEffective(
    QuizQuestion question,
    List<String> pokemonTypes,
  ) {
    final owned = pokemonTypes.map((t) => t.toLowerCase()).toSet().toList();
    final profile = TypeChart.defensiveProfile(owned);
    final weak = TypeChart.types.where((t) => profile[t]! > 1).toList();
    if (weak.isEmpty) return resolveTypeQuestion(question, owned);
    final rng = Random(question.seed);

    final answer = weak[rng.nextInt(weak.length)];
    final distractors = TypeChart.types.where((t) => profile[t]! <= 1).toList()
      ..shuffle(rng);
    final options = [answer, ...distractors.take(3)]..shuffle(rng);

    return question.copyWith(
      options: options,
      correctIndex: options.indexOf(answer),
      types: owned,
    );
  }

  /// A [QuizMode.higherStat] question: the Pokémon with the higher value of
  /// the asked stat is the answer. When they tie, the next stat is tried.
  static QuizQuestion resolveHigherStat(
    QuizQuestion question, {
    required List<String> types,
    required Map<String, int> stats,
    required Map<String, int> rivalStats,
  }) {
    final first = max(0, comparedStats.indexOf(question.stat ?? ''));
    for (var i = 0; i < comparedStats.length; i++) {
      final stat = comparedStats[(first + i) % comparedStats.length];
      final mine = stats[stat];
      final theirs = rivalStats[stat];
      if (mine == null || theirs == null || mine == theirs) continue;
      final winner = mine > theirs ? question.subject : question.rival!;
      return question.copyWith(
        stat: stat,
        correctIndex: question.options.indexOf(winner.name),
        types: types,
      );
    }
    return resolveTypeQuestion(
      question.copyWith(mode: QuizMode.guessType, options: const []),
      types,
    );
  }
}
