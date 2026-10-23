import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/model/pokemon_list_item.dart';
import 'package:pokeflutter/model/quiz_model.dart';
import 'package:pokeflutter/core/pokemon_constants.dart';
import 'package:pokeflutter/core/quiz_logic.dart';
import 'package:pokeflutter/core/type_chart.dart';

void main() {
  final pool = List.generate(
    30,
    (i) => PokemonListItem(
      name: 'mon$i',
      url: 'https://pokeapi.co/api/v2/pokemon/${i + 1}/',
    ),
  );

  group('generateQuestions', () {
    test('creates the requested number of questions, every mode in turn', () {
      final questions = QuizLogic.generateQuestions(pool, count: 8);

      expect(questions, hasLength(8));
      // Each group of four holds every mode once.
      for (final group in [questions.take(4), questions.skip(4)]) {
        expect(group.map((q) => q.mode).toSet(), QuizMode.values.toSet());
      }
    });

    test('asks only the given modes, in that order', () {
      final questions = QuizLogic.generateQuestions(
        pool,
        count: 5,
        modes: [QuizMode.guessName, QuizMode.guessType],
      );

      expect(questions.map((q) => q.mode), [
        QuizMode.guessName,
        QuizMode.guessType,
        QuizMode.guessName,
        QuizMode.guessType,
        QuizMode.guessName,
      ]);
    });

    test('the same random gives the same questions', () {
      List<String> describe(int seed) => [
        for (final q in QuizLogic.generateQuestions(pool, random: Random(seed)))
          '${q.mode.name}:${q.subject.name}:${q.rival?.name}:${q.stat}:'
              '${q.options.join(",")}:${q.seed}',
      ];

      expect(describe(7), describe(7));
      expect(describe(7), isNot(describe(8)));
    });

    test('stat questions pit two different Pokémon against each other', () {
      final questions = QuizLogic.generateQuestions(
        pool,
        count: 40,
        modes: [QuizMode.higherStat],
      );

      for (final q in questions) {
        expect(q.isResolved, isFalse);
        expect(q.rival, isNotNull);
        expect(q.rival!.name, isNot(q.subject.name));
        expect(q.options.toSet(), {q.subject.name, q.rival!.name});
        expect(QuizLogic.comparedStats, contains(q.stat));
      }
    });

    test('name questions have 4 distinct options including the answer', () {
      final questions = QuizLogic.generateQuestions(pool, count: 10);

      for (final q in questions.where((q) => q.mode == QuizMode.guessName)) {
        expect(q.isResolved, isTrue);
        expect(q.options.toSet(), hasLength(4));
        expect(q.correctAnswer, q.subject.name);
      }
    });

    test('all but the name questions wait for the Pokémon data', () {
      final questions = QuizLogic.generateQuestions(pool, count: 12);

      for (final q in questions) {
        expect(q.isResolved, q.mode == QuizMode.guessName);
      }
    });

    test('returns nothing when there are too few Pokémon', () {
      expect(QuizLogic.generateQuestions(pool.take(3).toList()), isEmpty);
    });

    test('easy only asks about (and offers) first-generation Pokémon', () {
      final mixed = [
        ...List.generate(
          10,
          (i) => PokemonListItem(
            name: 'gen1-$i',
            url: 'https://pokeapi.co/api/v2/pokemon/${i + 1}/',
          ),
        ),
        ...List.generate(
          10,
          (i) => PokemonListItem(
            name: 'later-$i',
            url: 'https://pokeapi.co/api/v2/pokemon/${200 + i}/',
          ),
        ),
      ];
      for (var run = 0; run < 20; run++) {
        final questions = QuizLogic.generateQuestions(
          mixed,
          difficulty: QuizDifficulty.easy,
        );
        expect(questions, hasLength(10));
        for (final q in questions) {
          expect(q.subject.name, startsWith('gen1-'));
          if (q.isResolved) {
            expect(q.options, everyElement(startsWith('gen1-')));
          }
        }
      }
    });

    test('alternate forms are never asked about', () {
      final forms = [
        ...pool,
        PokemonListItem(
          name: 'charizard-mega-x',
          url: 'https://pokeapi.co/api/v2/pokemon/10034/',
        ),
      ];
      for (var run = 0; run < 20; run++) {
        final questions = QuizLogic.generateQuestions(forms, count: 30);
        expect(
          questions.map((q) => q.subject.name),
          isNot(contains('charizard-mega-x')),
        );
      }
    });

    test('too few Pokémon for the difficulty means no quiz', () {
      final fewGen1 = [
        ...pool.take(3),
        PokemonListItem(
          name: 'later',
          url: 'https://pokeapi.co/api/v2/pokemon/500/',
        ),
      ];
      expect(
        QuizLogic.generateQuestions(fewGen1, difficulty: QuizDifficulty.easy),
        isEmpty,
      );
    });
  });

  group('QuizResult', () {
    test('scores 100 per answer plus a bonus that grows with the streak', () {
      final result = QuizResult(totalQuestions: 10);

      expect(result.record(isCorrect: true), 100);
      expect(result.record(isCorrect: true), 125);
      expect(result.record(isCorrect: true), 150);
      expect(result.score, 375);
      expect(result.streak, 3);
    });

    test('the streak bonus is capped at four steps', () {
      final result = QuizResult(totalQuestions: 10);
      final points = [
        for (var i = 0; i < 7; i++) result.record(isCorrect: true),
      ];

      expect(points, [100, 125, 150, 175, 200, 200, 200]);
    });

    test('a wrong answer scores nothing and resets the streak', () {
      final result = QuizResult(totalQuestions: 10)
        ..record(isCorrect: true)
        ..record(isCorrect: true);

      expect(result.record(isCorrect: false), 0);
      expect(result.streak, 0);
      expect(result.bestStreak, 2);
      expect(result.record(isCorrect: true), 100);
      expect(result.bestStreak, 2);
      expect(result.correct, 3);
      expect(result.wrong, 1);
      expect(result.accuracy, 0.75);
    });
  });

  group('QuizDifficulty', () {
    test('only the harder levels are timed', () {
      expect(QuizDifficulty.easy.isTimed, isFalse);
      expect(QuizDifficulty.normal.secondsPerQuestion, 20);
      expect(QuizDifficulty.hard.secondsPerQuestion, 10);
    });
  });

  group('resolveTypeQuestion', () {
    QuizQuestion unresolved(int seed) => QuizQuestion(
      subject: pool.first,
      options: const [],
      correctIndex: -1,
      mode: QuizMode.guessType,
      seed: seed,
    );

    test('a single-type Pokémon is asked for one type, among single types', () {
      for (var seed = 0; seed < 100; seed++) {
        final q = QuizLogic.resolveTypeQuestion(unresolved(seed), ['fire']);

        expect(q.isResolved, isTrue);
        expect(q.asksForPair, isFalse);
        expect(q.subject, pool.first);
        expect(q.options.toSet(), hasLength(4));
        expect(q.correctAnswer, 'fire');
        expect(q.options.where((o) => o == 'fire'), hasLength(1));
        expect(listPokemonTypeColor.keys, containsAll(q.options));
      }
    });

    test('a dual-type Pokémon is asked for both types, among pairs', () {
      for (var seed = 0; seed < 300; seed++) {
        final q = QuizLogic.resolveTypeQuestion(unresolved(seed), [
          'grass',
          'poison',
        ]);

        expect(q.asksForPair, isTrue);
        expect(q.options, hasLength(4));
        expect(q.correctAnswer, 'grass/poison');

        // Every option is two different real types ...
        final sets = <String>{};
        for (final option in q.options) {
          final types = QuizQuestion.typesOfOption(option);
          expect(types, hasLength(2));
          expect(types.toSet(), hasLength(2));
          expect(TypeChart.types, containsAll(types));
          sets.add((types..sort()).join('/'));
        }
        // ... and no two options are the same pair, in either order.
        expect(sets, hasLength(4));
      }
    });

    test('a pair is never also offered the other way round', () {
      for (var seed = 0; seed < 100; seed++) {
        final q = QuizLogic.resolveTypeQuestion(unresolved(seed), [
          'fire',
          'flying',
        ]);

        expect(q.options, isNot(contains('flying/fire')));
      }
    });

    test('the same seed gives the same options', () {
      final a = QuizLogic.resolveTypeQuestion(unresolved(5), ['water', 'ice']);
      final b = QuizLogic.resolveTypeQuestion(unresolved(5), ['water', 'ice']);

      expect(a.options, b.options);
      expect(a.correctIndex, b.correctIndex);
    });

    test('leaves the question untouched when no types are given', () {
      final q = unresolved(1);
      expect(QuizLogic.resolveTypeQuestion(q, []), q);
    });
  });

  group('resolveSuperEffective', () {
    QuizQuestion unresolved(int seed) => QuizQuestion(
      subject: pool.first,
      options: const [],
      correctIndex: -1,
      mode: QuizMode.superEffective,
      seed: seed,
    );

    test('the answer is a weakness and no other option is', () {
      for (final types in [
        ['fire'],
        ['grass', 'poison'],
        ['water', 'flying'],
        ['dragon', 'flying'],
      ]) {
        final profile = TypeChart.defensiveProfile(types);
        for (var seed = 0; seed < 100; seed++) {
          final q = QuizLogic.resolveSuperEffective(unresolved(seed), types);

          expect(q.mode, QuizMode.superEffective);
          expect(q.options.toSet(), hasLength(4));
          expect(profile[q.correctAnswer], greaterThan(1));
          final others = [
            for (var i = 0; i < 4; i++)
              if (i != q.correctIndex) q.options[i],
          ];
          for (final other in others) {
            expect(profile[other], lessThanOrEqualTo(1));
          }
        }
      }
    });

    test('a Pokémon without weaknesses gets a type question instead', () {
      final q = QuizLogic.resolveSuperEffective(unresolved(1), ['unknown']);

      expect(q.mode, QuizMode.guessType);
      expect(q.isResolved, isTrue);
      expect(q.correctAnswer, 'unknown');
    });
  });

  group('resolveHigherStat', () {
    final question = QuizQuestion(
      subject: pool[0],
      rival: pool[1],
      options: [pool[1].name, pool[0].name],
      correctIndex: -1,
      mode: QuizMode.higherStat,
      stat: 'attack',
      seed: 3,
    );

    test('the Pokémon with the higher stat is the answer', () {
      final stronger = QuizLogic.resolveHigherStat(
        question,
        types: ['fire'],
        stats: {'attack': 90},
        rivalStats: {'attack': 50},
      );
      expect(stronger.isResolved, isTrue);
      expect(stronger.correctAnswer, pool[0].name);

      final weaker = QuizLogic.resolveHigherStat(
        question,
        types: ['fire'],
        stats: {'attack': 40},
        rivalStats: {'attack': 50},
      );
      expect(weaker.correctAnswer, pool[1].name);
      expect(weaker.stat, 'attack');
    });

    test('a tie moves on to the next stat', () {
      final q = QuizLogic.resolveHigherStat(
        question,
        types: ['fire'],
        stats: {'attack': 50, 'defense': 70},
        rivalStats: {'attack': 50, 'defense': 60},
      );

      expect(q.mode, QuizMode.higherStat);
      expect(q.stat, 'defense');
      expect(q.correctAnswer, pool[0].name);
    });

    test('a tie on every stat becomes a type question', () {
      final q = QuizLogic.resolveHigherStat(
        question,
        types: ['fire', 'flying'],
        stats: {'attack': 50},
        rivalStats: {'attack': 50},
      );

      expect(q.mode, QuizMode.guessType);
      expect(q.isResolved, isTrue);
      expect(q.asksForPair, isTrue);
    });
  });

  group('resolve', () {
    test('picks the right resolution for the mode', () {
      final byMode = {
        for (final q in QuizLogic.generateQuestions(pool, count: 8))
          q.mode: QuizLogic.resolve(
            q,
            types: ['fire'],
            stats: {for (final s in QuizLogic.comparedStats) s: 100},
            rivalStats: {for (final s in QuizLogic.comparedStats) s: 50},
          ),
      };

      for (final q in byMode.values) {
        expect(q.isResolved, isTrue);
      }
      expect(byMode[QuizMode.higherStat]!.correctAnswer, isNotEmpty);
      expect(byMode[QuizMode.superEffective]!.mode, QuizMode.superEffective);
    });

    test('leaves a resolved question alone', () {
      final q = QuizLogic.generateQuestions(
        pool,
        count: 1,
        modes: [QuizMode.guessName],
      ).single;

      expect(QuizLogic.resolve(q, types: ['fire']), same(q));
    });
  });
}
