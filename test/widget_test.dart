import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/main.dart';
import 'package:pokeflutter/utils/pokemon_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the Pokédex and navigates between the tabs', (
    tester,
  ) async {
    // A stored type index keeps the test off the network.
    SharedPreferences.setMockInitialValues({
      'pokemon_type_index_v2': '{"bulbasaur": ["grass", "poison"]}',
    });
    // A phone-sized screen; the app is designed for 360 dp wide.
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    // Assets are read through the real event loop, not the fake test clock.
    await tester.runAsync(PokemonRepository.instance.getAll);

    await tester.pumpWidget(const MyApp());
    // Let the pages receive the list, then rebuild with it.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    expect(find.text('Pokédex'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Grass'), findsOneWidget);
    expect(find.text('Poison'), findsOneWidget);
    expect(find.text('Types unavailable offline.'), findsNothing);

    await tester.tap(find.text('Compare'));
    await tester.pump();
    expect(find.text('Select two Pokémon to start comparing'), findsOneWidget);

    await tester.tap(find.text('Quiz'));
    await tester.pump();
    expect(find.text('Start Quiz'), findsOneWidget);

    await tester.tap(find.text('Favourite'));
    await tester.pump();
    expect(
      find.text('Tap the ♥ on any Pokémon to save it here.'),
      findsOneWidget,
    );
  });
}
