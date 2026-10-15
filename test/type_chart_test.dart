import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/core/type_chart.dart';

void main() {
  test('single matchups', () {
    expect(TypeChart.multiplier('fire', 'grass'), 2);
    expect(TypeChart.multiplier('fire', 'water'), 0.5);
    expect(TypeChart.multiplier('fire', 'normal'), 1);
    expect(TypeChart.multiplier('electric', 'ground'), 0);
    expect(TypeChart.multiplier('ghost', 'normal'), 0);
    expect(TypeChart.multiplier('dragon', 'fairy'), 0);
    expect(TypeChart.multiplier('FIRE', 'Grass'), 2);
    expect(TypeChart.multiplier('shadow', 'grass'), 1);
  });

  test('every type is a known attacker and defender', () {
    expect(TypeChart.types, hasLength(18));
    for (final a in TypeChart.types) {
      for (final d in TypeChart.types) {
        expect(
          [0.0, 0.5, 1.0, 2.0],
          contains(TypeChart.multiplier(a, d)),
          reason: '$a → $d',
        );
      }
    }
  });

  test('the number of matchups per effectiveness is stable', () {
    // Pairs per effectiveness in the generation 6+ chart (51 super effective,
    // 61 not very effective, 8 immunities), guarding against typos.
    var double = 0, half = 0, none = 0;
    for (final a in TypeChart.types) {
      for (final d in TypeChart.types) {
        switch (TypeChart.multiplier(a, d)) {
          case 2:
            double++;
          case 0.5:
            half++;
          case 0:
            none++;
        }
      }
    }
    expect((double, half, none), (51, 61, 8));
  });

  test('dual types multiply (Charizard: fire / flying)', () {
    final profile = TypeChart.defensiveProfile(['fire', 'flying']);

    expect(TypeChart.typesWithMultiplier(profile, 4), ['rock']);
    expect(
      TypeChart.typesWithMultiplier(profile, 2),
      unorderedEquals(['water', 'electric']),
    );
    expect(TypeChart.typesWithMultiplier(profile, 0), ['ground']);
    expect(
      TypeChart.typesWithMultiplier(profile, 0.25),
      unorderedEquals(['grass', 'bug']),
    );
    expect(profile['ice'], 1); // 2 × 0.5
    expect(profile['fighting'], 0.5);
  });

  test('a single type (Pikachu: electric)', () {
    final profile = TypeChart.defensiveProfile(['electric']);

    expect(TypeChart.typesWithMultiplier(profile, 2), ['ground']);
    expect(
      TypeChart.typesWithMultiplier(profile, 0.5),
      unorderedEquals(['electric', 'flying', 'steel']),
    );
  });

  test('immunity wins over weakness (Gengar: ghost / poison)', () {
    final profile = TypeChart.defensiveProfile(['ghost', 'poison']);

    expect(profile['normal'], 0);
    expect(profile['fighting'], 0); // ghost immune × poison resist
    expect(profile['ground'], 2);
  });
}
