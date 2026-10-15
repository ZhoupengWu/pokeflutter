import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/main.dart';
import 'package:pokeflutter/app_services.dart';
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
    // Assets and preferences are read through the real event loop, not the
    // fake test clock.
    final services = AppServices();
    await tester.runAsync(services.init);

    await tester.pumpWidget(MyApp(services: services));
    // Let the pages receive the list, then rebuild with it.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    expect(find.text('Pokédex'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Grass'), findsOneWidget);
    expect(find.text('Poison'), findsOneWidget);
    expect(find.text('Types unavailable offline.'), findsNothing);

    await tester.tap(find.text('Quiz'));
    // The tab is built now and loads the list in the background.
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
    }
    expect(find.text('Start Quiz'), findsOneWidget);
    bool tickersOn(String text) => TickerMode.valuesOf(
      tester.element(find.text(text, skipOffstage: false)),
    ).enabled;
    expect(tickersOn('Start Quiz'), isTrue);

    await tester.tap(find.text('Compare'));
    await tester.pump();
    expect(find.text('Select two Pokémon to start comparing'), findsOneWidget);

    // Hidden tabs have their tickers off, so a quiz countdown cannot run
    // while another tab is showing.
    expect(tickersOn('Start Quiz'), isFalse);

    await tester.tap(find.text('Favourites'));
    await tester.pump();
    expect(
      find.text('Tap the ♥ on any Pokémon to save it here.'),
      findsOneWidget,
    );
  });

  testWidgets('follows the language chosen in the settings', (tester) async {
    SharedPreferences.setMockInitialValues({
      'pokemon_type_index_v2': '{"bulbasaur": ["grass", "poison"]}',
      'settings_locale': 'it',
    });
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final services = AppServices();
    await tester.runAsync(services.init);
    final settings = services.settings;

    await tester.pumpWidget(MyApp(services: services));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    expect(find.text('Preferiti'), findsOneWidget); // bottom navigation
    expect(find.text('Confronta'), findsOneWidget);
    expect(find.text('Erba'), findsOneWidget); // Grass
    expect(find.text('Veleno'), findsOneWidget); // Poison

    await settings.setLocale(const Locale('en'));
    await tester.pump();
    expect(find.text('Favourites'), findsOneWidget);
    expect(find.text('Grass'), findsOneWidget);
  });
}
