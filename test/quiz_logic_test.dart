import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/model/pokemon_list_item.dart';
import 'package:pokeflutter/model/quiz_model.dart';
import 'package:pokeflutter/utils/pokemon_constants.dart';
import 'package:pokeflutter/utils/quiz_logic.dart';

void main() {
  final pool = List.generate(
    30,
    (i) => PokemonListItem(name: 'mon$i', url: 'https://example.com/$i/'),
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
