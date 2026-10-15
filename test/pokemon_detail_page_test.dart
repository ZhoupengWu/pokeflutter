import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/controllers/pokemon_detail_controller.dart';
import 'package:pokeflutter/model/pokemon_list_item.dart';
import 'package:pokeflutter/utils/favourites_manager.dart';
import 'package:pokeflutter/utils/theme.dart';
import 'package:pokeflutter/views/detail/pokemon_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/detail_fakes.dart';
import 'support/fixtures.dart';
import 'support/quiz_fakes.dart';
import 'support/test_app.dart';

final _item = PokemonListItem(
  name: 'mon6',
  url: 'https://pokeapi.co/api/v2/pokemon/6/',
);

Future<PokemonDetailController> _pump(
  WidgetTester tester, {
  FakePokemonApi? api,
  FakeEvolutionApi? evolution,
  Locale locale = const Locale('en'),
  ThemeData? theme,
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final controller = PokemonDetailController(
    item: _item,
    api: api ?? FakePokemonApi(types: ['fire', 'flying']),
    evolutionApi: evolution ?? FakeEvolutionApi(chainBody: eeveeChainBody()),
    repository: fakeRepository(count: 500),
  );
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    testApp(
      PokemonDetailPage(pokemon: _item, controller: controller),
      locale: locale,
      theme: theme,
    ),
  );
  await tester.pump(); // first frame; the load runs in the background
  await tester.pump();
  await tester.pump();
  return controller;
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) => tester
    .scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FavouritesManager.instance.notifier.value = [];
  });

  testWidgets('shows the header, about, abilities and stats', (tester) async {
    await _pump(tester);

    expect(find.text('Mon6'), findsOneWidget);
    expect(find.text('#006'), findsOneWidget);
    expect(find.text('Fire'), findsWidgets);
    expect(find.text('Flying'), findsWidgets);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('90.5 kg'), findsOneWidget);
    expect(find.text('170 cm'), findsOneWidget);
    expect(find.text('Abilities'), findsOneWidget);
    expect(find.text('Blaze'), findsOneWidget);
    expect(find.text('Base Stats'), findsOneWidget);
    expect(find.text('HP'), findsOneWidget);
    expect(find.text('78'), findsOneWidget);
  });

  testWidgets('type matchups follow the dual type (fire / flying)', (
    tester,
  ) async {
    await _pump(tester);
    await _scrollTo(tester, find.text('Type matchups'));

    expect(find.text('Weak to'), findsOneWidget);
    expect(find.text('Resists'), findsOneWidget);
    expect(find.text('Immune to'), findsOneWidget);
    // Rock hits 4×; ground does nothing.
    expect(find.bySemanticsLabel('Rock: 4× damage'), findsOneWidget);
    expect(find.bySemanticsLabel('Water: 2× damage'), findsOneWidget);
    expect(find.bySemanticsLabel('Grass: ¼× damage'), findsOneWidget);
    expect(find.bySemanticsLabel('Ground: 0× damage'), findsOneWidget);
  }, semanticsEnabled: true);

  testWidgets('evolution branches are listed with how to reach them', (
    tester,
  ) async {
    await _pump(tester);
    await _scrollTo(tester, find.text('Evolution'));

    expect(find.text('Eevee'), findsOneWidget);
    expect(find.text('Vaporeon'), findsOneWidget);
    expect(find.text('Water Stone'), findsOneWidget);
    expect(find.text('Friendship'), findsOneWidget);
    expect(find.text('Lv. 20'), findsOneWidget);
  });

  testWidgets('a Pokémon without evolutions says so', (tester) async {
    await _pump(
      tester,
      evolution: FakeEvolutionApi(chainBody: singleStageChainBody()),
    );
    await _scrollTo(tester, find.text("This Pokémon doesn't evolve."));

    expect(find.text("This Pokémon doesn't evolve."), findsOneWidget);
  });

  testWidgets('evolutions failing to load can be retried on their own', (
    tester,
  ) async {
    final evolution = FakeEvolutionApi(chainBody: eeveeChainBody(), fail: true);
    await _pump(tester, evolution: evolution);
    await _scrollTo(tester, find.text("Couldn't load the evolutions."));

    // The stats are still there.
    expect(find.text('Base Stats'), findsOneWidget);

    evolution.fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump();
    await _scrollTo(tester, find.text('Vaporeon'));
    expect(find.text("Couldn't load the evolutions."), findsNothing);
    expect(find.text('Vaporeon'), findsOneWidget);
  });

  testWidgets('failing to load the Pokémon offers a retry', (tester) async {
    final api = FakePokemonApi(failing: {'mon6'});
    await _pump(tester, api: api);

    expect(find.text('Failed to load Pokémon'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);

    api.failing.clear();
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Failed to load Pokémon'), findsNothing);
    expect(find.text('About'), findsOneWidget);
  });

  testWidgets('the favourite button toggles the Pokémon', (tester) async {
    await _pump(tester);

    await tester.tap(find.byTooltip('Add to favourites'));
    await tester.pump();
    expect(FavouritesManager.instance.isFavourite('mon6'), isTrue);
    expect(find.byTooltip('Remove from favourites'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove from favourites'));
    await tester.pump();
    expect(FavouritesManager.instance.isFavourite('mon6'), isFalse);
  });

  testWidgets('is translated and readable in the dark theme', (tester) async {
    await _pump(tester, locale: const Locale('it'), theme: darkTheme);

    expect(find.text('Informazioni'), findsOneWidget);
    expect(find.text('Statistiche base'), findsOneWidget);
    expect(find.text('Fuoco'), findsWidgets);
    expect(find.text('90,5 kg'), findsOneWidget);
    await _scrollTo(tester, find.text('Efficacia dei tipi'));
    expect(find.text('Debole a'), findsOneWidget);
  });

  group('going back', () {
    final other = PokemonListItem(
      name: 'mon7',
      url: 'https://pokeapi.co/api/v2/pokemon/7/',
    );

    PokemonDetailPage page(PokemonListItem item) => PokemonDetailPage(
      pokemon: item,
      controller: PokemonDetailController(
        item: item,
        api: FakePokemonApi(types: ['fire']),
        evolutionApi: FakeEvolutionApi(),
        repository: fakeRepository(count: 500),
      ),
    );

    /// Home → Mon6 → Mon7, as after following an evolution.
    Future<void> openTwoPages(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(testApp(const Text('home')));
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(MaterialPageRoute<void>(builder: (_) => page(_item)));
      await tester.pumpAndSettle();
      navigator.push(MaterialPageRoute<void>(builder: (_) => page(other)));
      await tester.pumpAndSettle();
      expect(find.text('Mon7'), findsOneWidget);
    }

    testWidgets('the arrow in the page goes straight to the first screen', (
      tester,
    ) async {
      await openTwoPages(tester);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
      expect(find.text('Mon6'), findsNothing);
    });

    testWidgets('the system back button steps back one Pokémon', (
      tester,
    ) async {
      await openTwoPages(tester);

      await tester.binding.handlePopRoute(); // the Android back button
      await tester.pumpAndSettle();

      expect(find.text('Mon6'), findsOneWidget);
      expect(find.text('home'), findsNothing);

      await tester.binding.handlePopRoute(); // the Android back button
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
    });
  });
}
