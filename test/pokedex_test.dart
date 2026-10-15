import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/core/pokedex.dart';

void main() {
  test('generations are contiguous and cover 1–1025', () {
    expect(generations.first.firstId, 1);
    expect(generations.last.lastId, 1025);
    for (var i = 1; i < generations.length; i++) {
      expect(generations[i].firstId, generations[i - 1].lastId + 1);
      expect(generations[i].number, i + 1);
    }
  });

  test('generationOf finds the right generation', () {
    expect(generationOf(1), 1);
    expect(generationOf(151), 1);
    expect(generationOf(152), 2);
    expect(generationOf(25), 1); // Pikachu
    expect(generationOf(493), 4); // Arceus
    expect(generationOf(1025), 9);
  });

  test('alternate forms and unknown numbers have no generation', () {
    expect(generationOf(10034), isNull); // Mega Charizard X
    expect(generationOf(0), isNull);
    expect(generationOf(1026), isNull);
  });

  test('roman numerals', () {
    expect(
      generations.map((g) => g.roman).join(' '),
      'I II III IV V VI VII VIII IX',
    );
  });
}
