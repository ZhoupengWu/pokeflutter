import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/app_services.dart';
import 'package:pokeflutter/data/favourites_manager.dart';
import 'package:pokeflutter/data/pokemon_repository.dart';
import 'package:pokeflutter/data/pokemon_type_index.dart';
import 'package:pokeflutter/model/pokemon_list_item.dart';
import 'package:pokeflutter/views/compare/compare_page.dart';
import 'package:pokeflutter/views/detail/pokemon_detail_page.dart';
import 'package:pokeflutter/views/home/home_page.dart';
import 'package:pokeflutter/views/quiz/quiz_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/detail_fakes.dart';
import 'support/quiz_fakes.dart';
import 'support/test_app.dart';

/// Services whose network-facing parts are fakes, so pages can build their own
/// controllers from the tree.
AppServices _fakeServices() => AppServices(
  repository: fakeRepository(),
  pokemonApi: FakePokemonApi(),
  evolutionApi: FakeEvolutionApi(),
  speciesApi: FakeSpeciesApi(),
  abilityApi: FakeAbilityApi(),
  // Seeded in setUp: the index loads from storage and never hits the network.
  typeIndex: PokemonTypeIndex(),
);

void main() {
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'pokemon_type_index_v2': '{"mon1": ["fire"]}',
    }),
  );

  testWidgets('every service is available below AppProviders', (tester) async {
    final services = AppServices();
    late BuildContext inner;
    await tester.pumpWidget(
      AppProviders(
        services: services,
        child: Builder(
          builder: (context) {
            inner = context;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(inner.read<AppServices>(), same(services));
    expect(inner.read<FavouritesManager>(), same(services.favourites));
    expect(inner.read<PokemonTypeIndex>(), same(services.typeIndex));
    expect(inner.read<PokemonRepository>(), same(services.repository));
  });

  testWidgets('init loads the list, favourites and settings', (tester) async {
    SharedPreferences.setMockInitialValues({
      'favourite_pokemon_names': ['mon2'],
      'settings_locale': 'it',
      'pokemon_type_index_v2': '{"mon1": ["fire"]}',
    });
    final services = _fakeServices();

    await tester.runAsync(services.init);

    expect(services.favourites.isFavourite('mon2'), isTrue);
    expect(services.settings.locale, const Locale('it'));
  });

  testWidgets('the Home tab builds its controller from the services', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      testApp(const HomePage(), services: _fakeServices()),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Mon1'), findsOneWidget); // from the fake repository
  });

  testWidgets('Compare, Quiz and the detail page use the fake API', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final services = _fakeServices();

    await tester.pumpWidget(testApp(const ComparePage(), services: services));
    await tester.pump();
    await tester.pump();
    expect(find.text('Pokémon A'), findsOneWidget);

    await tester.pumpWidget(testApp(const QuizPage(), services: services));
    await tester.pump();
    await tester.pump();
    expect(find.text('Start Quiz'), findsOneWidget);

    await tester.pumpWidget(
      testApp(
        PokemonDetailPage(
          pokemon: PokemonListItem(
            name: 'mon3',
            url: 'https://pokeapi.co/api/v2/pokemon/3/',
          ),
        ),
        services: services,
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('Mon3'), findsOneWidget);
  });
}
