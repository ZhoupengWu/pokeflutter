import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/app_services.dart';
import 'package:pokeflutter/data/pokemon_type_index.dart';
import 'package:pokeflutter/views/shared/floating_tab_bar.dart';
import 'package:pokeflutter/views/shell_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/detail_fakes.dart';
import 'support/fonts.dart';
import 'support/quiz_fakes.dart';
import 'support/test_app.dart';

const _items = [
  FloatingTabItem(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'One',
  ),
  FloatingTabItem(
    icon: Icons.quiz_outlined,
    selectedIcon: Icons.quiz_rounded,
    label: 'Two',
  ),
  FloatingTabItem(
    icon: Icons.groups_outlined,
    selectedIcon: Icons.groups_rounded,
    label: 'Three',
  ),
];

Future<void> _bar(
  WidgetTester tester, {
  int current = 0,
  ValueChanged<int>? onTap,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    testApp(
      Align(
        alignment: Alignment.bottomCenter,
        child: FloatingTabBar(
          items: _items,
          currentIndex: current,
          onTap: onTap ?? (_) {},
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(loadRoboto);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows every tab and reports the one tapped', (tester) async {
    final taps = <int>[];
    await _bar(tester, onTap: taps.add);

    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('Three'), findsOneWidget);

    await tester.tap(find.text('Three'));
    await tester.tap(find.text('Two'));
    expect(taps, [2, 1]);
  });

  testWidgets('the current tab shows its filled icon and is announced', (
    tester,
  ) async {
    await _bar(tester, current: 1);

    expect(find.byIcon(Icons.quiz_rounded), findsOneWidget);
    expect(find.byIcon(Icons.quiz_outlined), findsNothing);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    final two = tester.getSemantics(find.bySemanticsLabel('Two'));
    final three = tester.getSemantics(find.bySemanticsLabel('Three'));
    expect(two.getSemanticsData().flagsCollection.isSelected, Tristate.isTrue);
    expect(two.getSemanticsData().flagsCollection.isButton, isTrue);
    expect(
      three.getSemanticsData().flagsCollection.isSelected,
      Tristate.isFalse,
    );
  }, semanticsEnabled: true);

  testWidgets('floats: inset from the sides, clear of the bottom, rounded', (
    tester,
  ) async {
    await _bar(tester);

    final pill = tester.getRect(find.byType(ClipRRect).first);
    expect(pill.left, greaterThanOrEqualTo(15)); // not edge to edge
    expect(844 - pill.bottom, greaterThanOrEqualTo(8)); // not on the edge
    expect(pill.height, lessThan(90));
    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect).first);
    expect(
      (clip.borderRadius as BorderRadius).topLeft.x,
      greaterThan(pill.height / 2 - 1), // a full pill
    );
  });

  testWidgets('does not stretch across a tablet', (tester) async {
    await _bar(tester, size: const Size(1024, 768));

    final pill = tester.getRect(find.byType(ClipRRect).first);
    expect(pill.width, lessThanOrEqualTo(FloatingTabBar.maxWidth));
    expect(pill.center.dx, closeTo(512, 1));
  });

  testWidgets('is frosted: it blurs what is behind it', (tester) async {
    await _bar(tester);

    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('in the app, pages learn the bar height from the padding', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
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

    final bar = tester.getRect(find.byType(FloatingTabBar));
    final context = tester.element(find.byType(IndexedStack));
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    // The tab bar sits at the bottom, and the pages are padded by its height.
    expect(bar.bottom, closeTo(844, 1));
    expect(bottomPadding, closeTo(bar.height, 1));
    // The Random button floats above the bar, not behind it.
    final random = tester.getRect(find.byType(FloatingActionButton));
    expect(random.bottom, lessThanOrEqualTo(bar.top));
    expect(tester.takeException(), isNull);
  });
}
