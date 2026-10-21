import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/model/pokemon.dart';
import 'package:pokeflutter/views/detail/stat_radar.dart';

import 'support/fonts.dart';
import 'support/test_app.dart';

List<PokemonStat> _stats(List<int> values) => [
  for (final (i, v) in values.indexed)
    PokemonStat(
      name: const [
        'hp',
        'attack',
        'defense',
        'special-attack',
        'special-defense',
        'speed',
      ][i],
      value: v,
    ),
];

void main() {
  setUpAll(loadRoboto);

  group('scaleFor', () {
    test('never goes below the minimum, so weak Pokémon look weak', () {
      expect(StatRadar.scaleFor(_stats([10, 20, 30, 40, 50, 60])), 120);
    });

    test('rounds the highest stat up to the next 10', () {
      expect(StatRadar.scaleFor(_stats([45, 49, 49, 65, 65, 126])), 130);
      expect(StatRadar.scaleFor(_stats([255, 10, 10, 10, 10, 10])), 260);
    });
  });

  testWidgets('draws and announces every stat', (tester) async {
    await tester.pumpWidget(
      testApp(
        SizedBox(
          width: 320,
          child: StatRadar(
            stats: _stats([78, 84, 78, 109, 85, 100]),
            accent: Colors.orange,
          ),
        ),
      ),
    );

    expect(find.byType(CustomPaint), findsWidgets);
    expect(
      find.bySemanticsLabel(
        'HP: 78, ATK: 84, DEF: 78, SpA: 109, SpD: 85, SPD: 100',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  }, semanticsEnabled: true);
}
