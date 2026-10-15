import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokeflutter/model/pokemon_list_item.dart';
import 'package:pokeflutter/data/pokemon_type_index.dart';
import 'package:pokeflutter/views/shared/grid_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/test_app.dart';

/// Fake PokéAPI where only charizard (fire/flying) has types.
http.Response _typeResponse(http.Request request) {
  final type = request.url.pathSegments.last;
  final slot = switch (type) {
    'fire' => 1,
    'flying' => 2,
    _ => 0,
  };
  return http.Response(
    slot == 0
        ? '{"pokemon": []}'
        : '{"pokemon": [{"pokemon": {"name": "charizard"}, "slot": $slot}]}',
    200,
  );
}

Widget _app(Widget child) =>
    testApp(SizedBox(width: 160, height: 100, child: child));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final charizard = PokemonListItem(
    name: 'charizard',
    url: 'https://pokeapi.co/api/v2/pokemon/6/',
  );

  test('id and sprite URL come from the list item URL', () {
    expect(charizard.id, 6);
    expect(charizard.spriteUrl, endsWith('/sprites/pokemon/6.png'));
    expect(
      PokemonListItem(
        name: 'x',
        url: 'https://pokeapi.co/api/v2/pokemon/10034/',
      ).id,
      10034,
    );
  });

  testWidgets('shows name and id, then the types once the index loads', (
    tester,
  ) async {
    final index = PokemonTypeIndex(
      client: MockClient((r) async => _typeResponse(r)),
    );
    await tester.pumpWidget(
      _app(GridItem(pokemon: charizard, typeIndex: index)),
    );

    expect(find.text('Charizard'), findsOneWidget);
    expect(find.text('#006'), findsOneWidget);
    expect(find.text('Fire'), findsNothing);

    await tester.runAsync(index.ensureLoaded);
    await tester.pump();

    expect(find.text('Fire'), findsOneWidget);
    expect(find.text('Flying'), findsOneWidget);
  });

  testWidgets('is announced to screen readers as a button', (tester) async {
    final handle = tester.ensureSemantics();
    final index = PokemonTypeIndex(
      client: MockClient((r) async => _typeResponse(r)),
    );
    await tester.pumpWidget(
      _app(GridItem(pokemon: charizard, typeIndex: index)),
    );
    await tester.runAsync(index.ensureLoaded);
    await tester.pump();

    expect(
      tester.getSemantics(find.byType(GridItem)),
      matchesSemantics(
        label: 'Charizard, number 6, Fire and Flying type',
        isButton: true,
        hasTapAction: true,
        hasEnabledState: false,
      ),
    );
    handle.dispose();
  });
}
