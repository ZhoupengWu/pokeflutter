import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/app_services.dart';
import 'package:pokeflutter/data/pokemon_type_index.dart';
import 'package:pokeflutter/views/compare/compare_page.dart';
import 'package:pokeflutter/views/favourites/favourite_page.dart';
import 'package:pokeflutter/views/home/home_page.dart';
import 'package:pokeflutter/views/quiz/quiz_page.dart';
import 'package:pokeflutter/views/shell_page.dart';
import 'package:pokeflutter/views/team/team_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/detail_fakes.dart';
import 'support/quiz_fakes.dart';
import 'support/test_app.dart';

void main() {
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'pokemon_type_index_v2': '{"mon1": ["fire"]}',
    }),
  );

  testWidgets('tabs are built on first visit and then kept alive', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final services = AppServices(
      repository: fakeRepository(),
      pokemonApi: FakePokemonApi(),
      evolutionApi: FakeEvolutionApi(),
      speciesApi: FakeSpeciesApi(),
      abilityApi: FakeAbilityApi(),
      typeIndex: PokemonTypeIndex(),
    );

    await tester.pumpWidget(testApp(const ShellPage(), services: services));
    await tester.pump();

    // Only Home exists at first.
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(ComparePage), findsNothing);
    expect(find.byType(QuizPage), findsNothing);
    expect(find.byType(FavouritePage), findsNothing);
    expect(find.byType(TeamPage), findsNothing);

    await tester.tap(find.text('Quiz'));
    await tester.pump();
    expect(find.byType(QuizPage), findsOneWidget);
    expect(find.byType(ComparePage), findsNothing);

    await tester.tap(find.text('Team'));
    await tester.pump();
    expect(find.byType(TeamPage), findsOneWidget);
    expect(find.text('Add a Pokémon'), findsNWidgets(6));

    // Going back to Home does not throw the Quiz tab away.
    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(find.byType(QuizPage, skipOffstage: false), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
  });
}
