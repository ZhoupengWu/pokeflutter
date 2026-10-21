import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/app_services.dart';
import 'package:pokeflutter/controllers/team_controller.dart';
import 'package:pokeflutter/data/team_manager.dart';
import 'package:pokeflutter/views/shared/pokemon_image.dart';
import 'package:pokeflutter/views/team/team_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/detail_fakes.dart';
import 'support/fonts.dart';
import 'support/quiz_fakes.dart';
import 'support/test_app.dart';

late TeamManager _team;
late FakePokemonApi _api;

Future<TeamController> _pump(
  WidgetTester tester, {
  List<int> saved = const [],
  Locale locale = const Locale('en'),
  List<String> types = const ['water'],
}) async {
  SharedPreferences.setMockInitialValues({
    'team_pokemon_names': [for (final id in saved) 'mon$id'],
  });
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final repository = fakeRepository();
  _team = TeamManager();
  await tester.runAsync(() async => _team.init(await repository.getAll()));
  _api = FakePokemonApi(types: types);
  final controller = TeamController(
    team: _team,
    api: _api,
    repository: repository,
  );
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    testApp(
      TeamPage(controller: controller),
      services: AppServices(
        team: _team,
        pokemonApi: _api,
        repository: repository,
        evolutionApi: FakeEvolutionApi(),
        speciesApi: FakeSpeciesApi(),
        abilityApi: FakeAbilityApi(),
      ),
      locale: locale,
    ),
  );
  await tester.runAsync(controller.init);
  await tester.pump();
  await tester.pump();
  return controller;
}

void main() {
  setUpAll(loadRoboto);

  testWidgets('an empty team shows six empty slots and a hint', (tester) async {
    await _pump(tester);

    expect(find.text('Team'), findsOneWidget);
    expect(find.text('Add a Pokémon'), findsNWidgets(6));
    expect(
      find.text('Add a Pokémon to start building your team.'),
      findsOneWidget,
    );
    expect(find.text('Clear team'), findsNothing);
    expect(find.text('Weak to'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the saved team is shown with names and types', (tester) async {
    await _pump(tester, saved: [1, 2]);

    expect(find.text('Mon1'), findsOneWidget);
    expect(find.text('Mon2'), findsOneWidget);
    // The type of both cards, and once more among the types not covered.
    expect(find.text('Water'), findsNWidgets(3));
    expect(find.text('Add a Pokémon'), findsNWidgets(4));
    expect(find.text('Clear team'), findsOneWidget);
  });

  testWidgets('the content of a card is centred in it', (tester) async {
    await _pump(tester, saved: [1]);

    final card = tester.getRect(
      find
          .ancestor(of: find.text('Mon1'), matching: find.byType(InkWell))
          .first,
    );
    final sprite = tester.getCenter(find.byType(PokemonImage).first);
    final name = tester.getCenter(find.text('Mon1'));
    final type = tester.getCenter(find.text('Water').first);

    for (final center in [sprite, name, type]) {
      expect((center.dx - card.center.dx).abs(), lessThan(2));
    }
  });

  testWidgets('shows what the team is weak to and what it covers', (
    tester,
  ) async {
    await _pump(tester, saved: [1, 2]);

    expect(find.text('Defence'), findsOneWidget);
    expect(find.text('Weak to'), findsOneWidget);
    // Two water Pokémon are both weak to electric and grass.
    expect(find.text('Electric ×2'), findsOneWidget);
    expect(find.text('Grass ×2'), findsOneWidget);
    expect(find.text('Offence'), findsOneWidget);
    expect(find.text('Hits super effectively'), findsOneWidget);
    expect(find.text('Not covered'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty slot opens the picker and adds the choice', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('Add a Pokémon').first);
    await tester.pumpAndSettle();
    expect(find.text('Search Pokémon...'), findsOneWidget);

    await tester.tap(find.text('Mon3'));
    await tester.pumpAndSettle();

    expect(find.text('Mon3'), findsOneWidget); // now on a card
    expect(find.text('Add a Pokémon'), findsNWidgets(5));
    expect(_team.members.map((p) => p.name), ['mon3']);
  });

  testWidgets('the picker does not offer Pokémon already in the team', (
    tester,
  ) async {
    await _pump(tester, saved: [1]);

    await tester.tap(find.text('Add a Pokémon').first);
    await tester.pumpAndSettle();

    // Mon1 is only on its card; the list below starts at Mon2.
    expect(find.text('Mon1'), findsOneWidget);
    expect(find.text('Mon2'), findsOneWidget);
  });

  testWidgets('the cross removes a member and Clear empties the team', (
    tester,
  ) async {
    await _pump(tester, saved: [1, 2]);

    await tester.tap(find.byTooltip('Remove Mon1 from the team'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Mon1'), findsNothing);
    expect(find.text('Mon2'), findsOneWidget);

    await tester.tap(find.text('Clear team'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Mon2'), findsNothing);
    expect(find.text('Add a Pokémon'), findsNWidgets(6));
    expect(_team.members, isEmpty);
  });

  testWidgets('a Pokémon that cannot be loaded can be retried', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = await _pump(tester, saved: [1]);
    // Reload the page with a failing API for the member.
    _api.failing.add('mon1');
    controller.details.clear();
    await tester.runAsync(controller.loadDetails);
    await tester.pump();

    expect(
      find.text('1 Pokémon could not be loaded. Tap to retry'),
      findsOneWidget,
    );

    _api.failing.clear();
    await tester.tap(find.text('1 Pokémon could not be loaded. Tap to retry'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    await tester.pump();
    expect(
      find.text('1 Pokémon could not be loaded. Tap to retry'),
      findsNothing,
    );
  });

  testWidgets('is translated', (tester) async {
    await _pump(tester, saved: [1], locale: const Locale('it'));

    expect(find.text('Squadra'), findsOneWidget);
    expect(find.text('Difesa'), findsOneWidget);
    expect(find.text('Debole a'), findsOneWidget);
    expect(find.text('Elettro ×1'), findsOneWidget);
    expect(find.text('Svuota la squadra'), findsOneWidget);
    expect(find.text('Attacco'), findsOneWidget);
  });
}
