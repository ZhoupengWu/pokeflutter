import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/app_services.dart';
import 'package:pokeflutter/data/network_status.dart';
import 'package:pokeflutter/data/pokemon_type_index.dart';
import 'package:pokeflutter/views/home/home_page.dart';
import 'package:pokeflutter/views/shared/pokemon_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/quiz_fakes.dart';
import 'support/test_app.dart';

void main() {
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'pokemon_type_index_v2': '{"mon1": ["fire"]}',
    }),
  );

  testWidgets('Home shows an offline hint and hides it when back online', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final status = NetworkStatus();

    await tester.pumpWidget(
      testApp(
        const HomePage(),
        services: AppServices(
          repository: fakeRepository(),
          typeIndex: PokemonTypeIndex(),
          networkStatus: status,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.textContaining("You're offline"), findsNothing);

    status.reportFailure();
    await tester.pump();
    expect(
      find.text(
        "You're offline. Pokémon you've already opened are still available.",
      ),
      findsOneWidget,
    );

    status.reportSuccess();
    await tester.pump();
    expect(find.textContaining("You're offline"), findsNothing);
  });

  testWidgets('images are loaded through the app image provider', (
    tester,
  ) async {
    final requested = <String>[];
    await tester.pumpWidget(
      testApp(
        const PokemonImage('https://img/a.png', width: 10, height: 10),
        services: AppServices(
          imageProvider: (url) {
            requested.add(url);
            return MemoryImage(_transparentPixel);
          },
        ),
      ),
    );

    expect(requested, ['https://img/a.png']);
    expect(find.byType(Image), findsOneWidget);
  });
}

/// A valid 1×1 transparent PNG.
final _transparentPixel = Uint8List.fromList(const [
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00,
  0x0d, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0xfc, 0xff, 0xff, 0x3f,
  0x00, 0x05, 0xfe, 0x02, 0xfe, 0xa7, 0x35, 0x81, 0x84, 0x00, 0x00, 0x00,
  0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
]);
