import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/model/pokemon_list_item.dart';
import 'package:pokeflutter/model/quiz_model.dart';
import 'package:pokeflutter/core/pokemon_constants.dart';
import 'package:pokeflutter/core/quiz_logic.dart';

void main() {
  final pool = List.generate(
    30,
    (i) => PokemonListItem(
      name: 'mon$i',
      url: 'https://pokeapi.co/api/v2/pokemon/${i + 1}/',
    ),
  );

  group('generateQuestions', () {
    test('creates the requested number of questions, alternating modes', () {
      final questions = QuizLogic.generateQuestions(pool, count: 10);

      expect(questions, hasLength(10));
      for (var i = 0; i < questions.length; i++) {
        expect(
          questions[i].mode,
          i.isEven ? QuizMode.guessName : QuizMode.guessType,
        );
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

    test('type questions are unresolved until the real types are known', () {
      final questions = QuizLogic.generateQuestions(pool, count: 10);

      for (final q in questions.where((q) => q.mode == QuizMode.guessType)) {
        expect(q.isResolved, isFalse);
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
    final unresolved = QuizLogic.generateQuestions(
      pool,
      count: 2,
    ).firstWhere((q) => q.mode == QuizMode.guessType);

    test('the correct option is the real type of a single-type Pokémon', () {
      for (var i = 0; i < 100; i++) {
        final q = QuizLogic.resolveTypeQuestion(unresolved, ['fire']);

        expect(q.isResolved, isTrue);
        expect(q.subject, unresolved.subject);
        expect(q.options.toSet(), hasLength(4));
        expect(q.correctAnswer, 'fire');
        expect(listPokemonTypeColor.keys, containsAll(q.options));
      }
    });

    test('dual-type Pokémon: exactly one of their types is offered', () {
      for (var i = 0; i < 100; i++) {
        final q = QuizLogic.resolveTypeQuestion(unresolved, [
          'grass',
          'poison',
        ]);

        expect(['grass', 'poison'], contains(q.correctAnswer));
        final ownTypes = q.options.where(['grass', 'poison'].contains);
        expect(ownTypes, hasLength(1));
      }
    });

    test('leaves the question untouched when no types are given', () {
      expect(QuizLogic.resolveTypeQuestion(unresolved, []), unresolved);
    });
  });
}
