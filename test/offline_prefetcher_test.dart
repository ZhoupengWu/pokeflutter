import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/app_services.dart';
import 'package:pokeflutter/data/favourites_manager.dart';
import 'package:pokeflutter/data/offline_prefetcher.dart';
import 'package:pokeflutter/model/pokemon_list_item.dart';
import 'package:pokeflutter/views/home/settings_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/detail_fakes.dart';
import 'support/quiz_fakes.dart';
import 'support/test_app.dart';

PokemonListItem _item(String name, int id) =>
    PokemonListItem(name: name, url: 'https://pokeapi.co/api/v2/pokemon/$id/');

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  late FakePokemonApi pokemon;
  late FakeSpeciesApi species;
  late FakeEvolutionApi evolution;
  late FakeAbilityApi abilities;
  late List<String> images;

  OfflinePrefetcher prefetcher() => OfflinePrefetcher(
    pokemon: pokemon,
    species: species,
    evolution: evolution,
    abilities: abilities,
    downloadImage: (url) async => images.add(url),
  );

  setUp(() {
    pokemon = FakePokemonApi();
    species = FakeSpeciesApi();
    evolution = FakeEvolutionApi();
    abilities = FakeAbilityApi();
    images = [];
  });

  group('OfflinePrefetcher', () {
    test('downloads details, species, chain, abilities and images', () async {
      final progress = <(int, int)>[];

      final result = await prefetcher().prefetch([
        _item('mon1', 1),
        _item('mon2', 2),
      ], onProgress: (done, total) => progress.add((done, total)));

      expect(result.total, 2);
      expect(result.isComplete, isTrue);
      expect(pokemon.requested, unorderedEquals(['mon1', 'mon2']));
      expect(species.requested, unorderedEquals(['mon1', 'mon2']));
      expect(evolution.requested, unorderedEquals(['mon1', 'mon2']));
      expect(abilities.requested, ['blaze', 'blaze']);
      // Sprite and artwork of each Pokémon.
      expect(images.toSet(), {
        'https://img/sprite.png',
        'https://img/artwork.png',
      });
      expect(progress.first, (0, 2));
      expect(progress.last, (2, 2));
    });

    test('a Pokémon that cannot be downloaded is counted, not fatal', () async {
      pokemon = FakePokemonApi(failing: {'mon1'});

      final result = await prefetcher().prefetch([
        _item('mon1', 1),
        _item('mon2', 2),
      ]);

      expect(result.failed, 1);
      expect(result.isComplete, isFalse);
      expect(species.requested, ['mon2']); // the other one went through
    });

    test('a failing part of a Pokémon counts as a failure', () async {
      evolution.fail = true;

      final result = await prefetcher().prefetch([_item('mon1', 1)]);

      expect(result.failed, 1);
    });

    test('nothing to download is a complete run', () async {
      final result = await prefetcher().prefetch([]);

      expect(result.total, 0);
      expect(result.isComplete, isTrue);
    });
  });

  group('settings sheet', () {
    Future<FavouritesManager> open(
      WidgetTester tester, {
      List<PokemonListItem> favourites = const [],
      Locale locale = const Locale('en'),
    }) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final manager = FavouritesManager();
      manager.notifier.value = favourites;
      await tester.pumpWidget(
        testApp(
          const SettingsSheet(),
          services: AppServices(favourites: manager, prefetcher: prefetcher()),
          locale: locale,
        ),
      );
      await tester.pumpAndSettle();
      return manager;
    }

    testWidgets('without favourites the button is off and says why', (
      tester,
    ) async {
      await open(tester);

      expect(
        find.text('Add favourites to save them for offline use'),
        findsOneWidget,
      );
      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('saves the favourites and says so', (tester) async {
      await open(tester, favourites: [_item('mon1', 1), _item('mon2', 2)]);

      await tester.tap(find.text('Save favourites for offline use'));
      await tester.pumpAndSettle();

      expect(find.text('Favourites saved'), findsOneWidget);
      expect(pokemon.requested, unorderedEquals(['mon1', 'mon2']));
    });

    testWidgets('reports the Pokémon that could not be saved', (tester) async {
      pokemon = FakePokemonApi(failing: {'mon1'});
      await open(tester, favourites: [_item('mon1', 1), _item('mon2', 2)]);

      await tester.tap(find.text('Save favourites for offline use'));
      await tester.pumpAndSettle();

      expect(
        find.text('1 Pokémon could not be saved. Check your connection.'),
        findsOneWidget,
      );
    });

    testWidgets('is translated', (tester) async {
      await open(
        tester,
        favourites: [_item('mon1', 1)],
        locale: const Locale('it'),
      );
      expect(find.text("Salva i preferiti per l'uso offline"), findsOneWidget);

      await tester.tap(find.text("Salva i preferiti per l'uso offline"));
      await tester.pumpAndSettle();
      expect(find.text('Preferiti salvati'), findsOneWidget);
    });
  });
}
