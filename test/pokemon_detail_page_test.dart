import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/controllers/pokemon_detail_controller.dart';
import 'package:pokeflutter/app_services.dart';
import 'package:pokeflutter/data/favourites_manager.dart';
import 'package:pokeflutter/theme/app_colors.dart';
import 'package:pokeflutter/model/pokemon_list_item.dart';
import 'package:pokeflutter/theme/theme.dart';
import 'package:pokeflutter/views/detail/pokemon_detail_page.dart';
import 'package:pokeflutter/views/detail/stat_radar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/detail_fakes.dart';
import 'support/fixtures.dart';
import 'support/quiz_fakes.dart';
import 'support/test_app.dart';

final _item = PokemonListItem(
  name: 'mon6',
  url: 'https://pokeapi.co/api/v2/pokemon/6/',
);

/// The favourites the page under test reads (fresh for every test).
late FavouritesManager favourites;

Future<PokemonDetailController> _pump(
  WidgetTester tester, {
  FakePokemonApi? api,
  FakeEvolutionApi? evolution,
  FakeSpeciesApi? species,
  FakeAbilityApi? ability,
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
    speciesApi: species ?? FakeSpeciesApi(),
    abilityApi: ability ?? FakeAbilityApi(),
    repository: fakeRepository(count: 500),
  );
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    testApp(
      PokemonDetailPage(pokemon: _item, controller: controller),
      services: AppServices(favourites: favourites),
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
    favourites = FavouritesManager();
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

  testWidgets('abilities are shown with their translated name', (tester) async {
    await _pump(tester, locale: const Locale('it'));

    expect(find.text('Fuocardore'), findsOneWidget);
    expect(find.text('Blaze'), findsNothing);
  });

  testWidgets('an ability without a translation shows its English id', (
    tester,
  ) async {
    await _pump(tester, ability: FakeAbilityApi(fail: true));

    expect(find.text('Blaze'), findsOneWidget);
  });

  testWidgets('the sparkle button swaps in the shiny artwork', (tester) async {
    await _pump(tester);
    Finder artwork(String url) => find.byWidgetPredicate(
      (w) =>
          w is Image &&
          w.image is NetworkImage &&
          (w.image as NetworkImage).url == url,
    );

    expect(artwork('https://img/artwork.png'), findsWidgets);
    expect(artwork('https://img/shiny.png'), findsNothing);

    await tester.tap(find.byTooltip('Show shiny'));
    await tester.pump();
    expect(artwork('https://img/shiny.png'), findsWidgets);
    expect(artwork('https://img/artwork.png'), findsNothing);

    await tester.tap(find.byTooltip('Show normal'));
    await tester.pump();
    expect(artwork('https://img/artwork.png'), findsWidgets);
  });

  testWidgets('no sparkle button without a shiny artwork', (tester) async {
    await _pump(tester, api: FakePokemonApi(shiny: false));

    expect(find.byTooltip('Show shiny'), findsNothing);
  });

  testWidgets('shows the Pokédex entry in English', (tester) async {
    await _pump(tester);

    expect(find.text('Pokédex entry'), findsOneWidget);
    expect(find.text('Mouse Pokémon'), findsOneWidget);
    expect(
      find.text('It stores electricity in its cheeks. Really.'),
      findsOneWidget,
    );
    expect(find.text('Mythical'), findsOneWidget);
    expect(find.text("Habitat: Water's edge"), findsOneWidget);
    expect(find.text('Legendary'), findsNothing);
  });

  testWidgets('shows the Pokédex entry in Italian', (tester) async {
    await _pump(tester, locale: const Locale('it'));

    expect(find.text('Scheda Pokédex'), findsOneWidget);
    expect(find.text('Pokémon Topo'), findsOneWidget);
    expect(find.text('Accumula elettricità nelle guance.'), findsOneWidget);
    expect(find.text('Misterioso'), findsOneWidget);
    expect(find.text('Habitat: Riva'), findsOneWidget);
  });

  testWidgets('without species information the entry is left out', (
    tester,
  ) async {
    await _pump(tester, species: FakeSpeciesApi(fail: true));

    expect(find.text('Pokédex entry'), findsNothing);
    expect(find.text('About'), findsOneWidget); // the rest is still there
  });

  testWidgets('the stats can be shown as a radar chart and back', (
    tester,
  ) async {
    await _pump(tester);
    await _scrollTo(tester, find.text('Base Stats'));

    expect(find.byType(LinearProgressIndicator), findsWidgets);
    expect(find.byType(StatRadar), findsNothing);

    await tester.tap(find.byTooltip('Show as radar chart'));
    await tester.pump();
    expect(find.byType(StatRadar), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await tester.tap(find.byTooltip('Show as bars'));
    await tester.pump();
    expect(find.byType(StatRadar), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsWidgets);
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

  testWidgets('the matchups link to the full type chart', (tester) async {
    await _pump(tester);
    await _scrollTo(tester, find.text('Full type chart'));

    await tester.tap(find.text('Full type chart'));
    await tester.pumpAndSettle();

    expect(find.text('Type chart'), findsOneWidget);
    expect(find.text('Super effective (2×)'), findsOneWidget);
  });

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

  testWidgets('a favourite heart is red on a white disc, readable on red', (
    tester,
  ) async {
    // Charizard-like red Pokémon: the page background is the fire colour.
    await _pump(tester, api: FakePokemonApi(types: ['fire']));
    await tester.tap(find.byTooltip('Add to favourites'));
    await tester.pump();

    final button = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.favorite_rounded),
    );
    expect(button.style?.backgroundColor?.resolve({}), Colors.white);
    expect((button.icon as Icon).color, dangerRed);

    await tester.tap(find.byTooltip('Remove from favourites'));
    await tester.pump();
    final outline = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.favorite_border_rounded),
    );
    expect(outline.style, isNull);
  });

  testWidgets('the favourite button toggles the Pokémon', (tester) async {
    await _pump(tester);

    await tester.tap(find.byTooltip('Add to favourites'));
    await tester.pump();
    expect(favourites.isFavourite('mon6'), isTrue);
    expect(find.byTooltip('Remove from favourites'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove from favourites'));
    await tester.pump();
    expect(favourites.isFavourite('mon6'), isFalse);
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
        speciesApi: FakeSpeciesApi(),
        abilityApi: FakeAbilityApi(),
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
