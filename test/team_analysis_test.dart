import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/core/team_analysis.dart';
import 'package:pokeflutter/core/type_chart.dart';

void main() {
  test('an empty team has no weaknesses and covers nothing', () {
    final a = TeamAnalysis.of([]);

    expect(a.size, 0);
    expect(a.weaknesses, isEmpty);
    expect(a.resistances, isEmpty);
    expect(a.covered, isEmpty);
    expect(a.uncovered, TypeChart.types);
  });

  test('counts who is weak to and who resists each type', () {
    final a = TeamAnalysis.of([
      ['fire', 'flying'], // Charizard: weak to rock ×4, water, electric
      ['water'], // Squirtle: weak to grass, electric
    ]);

    expect(a.weakCount['electric'], 2); // both
    expect(a.weakCount['rock'], 1);
    expect(a.weakCount['water'], 1); // Charizard only
    expect(a.weakCount['grass'], 1); // Squirtle only
    expect(a.resistCount['water'], 1); // Squirtle resists it, Charizard is weak
    expect(a.resistCount['ground'], 1); // Charizard is immune
    expect(a.resistCount['fire'], 2); // fire resists it, water resists it
  });

  test('weaknesses are the types hurting more than they are resisted', () {
    final a = TeamAnalysis.of([
      ['fire', 'flying'],
      ['water'],
    ]);

    // electric: 2 weak, 0 resist. rock: 1 weak. water: 1 weak but 1 resists, so
    // not a weakness. grass: Squirtle is weak but Charizard resists it ×¼.
    expect(a.weaknesses.first, 'electric');
    expect(a.weaknesses, contains('rock'));
    expect(a.weaknesses, isNot(contains('water')));
    expect(a.weaknesses, isNot(contains('grass')));
  });

  test('resistances list the types resisted by more than are weak', () {
    final a = TeamAnalysis.of([
      ['steel'],
      ['steel', 'fairy'],
    ]);

    // Both are immune to poison (steel) and resist normal.
    expect(a.resistances.first, anyOf('normal', 'poison', 'dragon', 'psychic'));
    expect(a.resistances, containsAll(['normal', 'poison', 'ice']));
    expect(a.resistances, isNot(contains('fire'))); // both are weak to fire
    expect(a.weaknesses, contains('fire'));
  });

  test('ties keep the order of the types', () {
    final a = TeamAnalysis.of([
      ['normal'], // weak to fighting only
      ['rock'], // weak to fighting, water, grass, ground, steel
    ]);

    // fighting 2; water, grass, ground, steel 1 each (PokéAPI order).
    expect(a.weaknesses.first, 'fighting');
    expect(a.weaknesses.sublist(1), ['water', 'grass', 'ground', 'steel']);
  });

  test('offence: a type is covered when a member hits it for double', () {
    final a = TeamAnalysis.of([
      [
        'fire',
        'flying',
      ], // fire: grass, ice, bug, steel; flying: grass, fighting, bug
    ]);

    expect(a.covered, {'grass', 'ice', 'bug', 'steel', 'fighting'});
    expect(a.uncovered, hasLength(18 - 5));
    expect(a.uncovered, isNot(contains('grass')));
    expect(a.uncovered, contains('water'));
  });

  test('adding members only ever widens the coverage', () {
    final one = TeamAnalysis.of([
      ['fire'],
    ]);
    final two = TeamAnalysis.of([
      ['fire'],
      ['water'],
    ]);

    expect(two.covered.containsAll(one.covered), isTrue);
    expect(two.covered, contains('rock')); // water hits rock, fire does not
  });
}
