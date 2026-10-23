import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/core/pokedex.dart';
import 'package:pokeflutter/views/home/filter_sheet.dart';

import 'support/test_app.dart';

const _empty = FilterSelection(
  types: {},
  generations: {},
  sort: PokemonSort.numberAsc,
);

Future<List<FilterSelection>> _open(
  WidgetTester tester, {
  FilterSelection initial = _empty,
  Locale locale = const Locale('en'),
  bool bottomAligned = false,
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final applied = <FilterSelection>[];
  await tester.pumpWidget(
    testApp(
      bottomAligned
          ? Align(
              alignment: Alignment.bottomCenter,
              child: FilterSheet(initial: initial, onApply: applied.add),
            )
          : FilterSheet(initial: initial, onApply: applied.add),
      locale: locale,
    ),
  );
  return applied;
}

/// Taps a chip even when it is below the fold of the sheet's scroll view.
Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.pump();
  await tester.tap(find.text(text));
  await tester.pump();
}

void main() {
  testWidgets('starts with nothing to apply', (tester) async {
    await _open(tester);

    expect(find.text('Filter and sort'), findsOneWidget);
    expect(find.text('Show all'), findsOneWidget);
    expect(find.text('Clear all'), findsNothing);
    expect(find.text('Gen I'), findsOneWidget);
    expect(find.text('Gen IX'), findsOneWidget);
    expect(find.text('Number (low to high)'), findsOneWidget);
  });

  testWidgets('applies the chosen types, generations and sort', (tester) async {
    final applied = await _open(tester);

    await tester.ensureVisible(find.text('Fire').first);
    await tester.pump();
    await tester.tap(find.text('Fire').first);
    await tester.pump();
    await _tap(tester, 'Gen II');
    await _tap(tester, 'Gen IV');
    await _tap(tester, 'Name (A–Z)');
    expect(find.text('Apply (4)'), findsOneWidget);
    expect(
      find.text('Alternate forms are hidden when a generation is selected.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Apply (4)'));
    await tester.pump();

    expect(applied, hasLength(1));
    expect(applied.single.types, {'fire'});
    expect(applied.single.generations, {2, 4});
    expect(applied.single.sort, PokemonSort.nameAsc);
  });

  testWidgets('tapping a selected chip again deselects it', (tester) async {
    final applied = await _open(tester);

    await _tap(tester, 'Gen III');
    await _tap(tester, 'Gen III');
    await tester.tap(find.text('Show all'));

    expect(applied.single.generations, isEmpty);
  });

  testWidgets('Clear all resets everything, including the sort', (
    tester,
  ) async {
    final applied = await _open(
      tester,
      initial: const FilterSelection(
        types: {'water'},
        generations: {1},
        sort: PokemonSort.nameDesc,
      ),
    );
    expect(find.text('Apply (3)'), findsOneWidget);

    await tester.tap(find.text('Clear all'));
    await tester.pump();
    await tester.tap(find.text('Show all'));

    expect(applied.single.types, isEmpty);
    expect(applied.single.generations, isEmpty);
    expect(applied.single.sort, PokemonSort.numberAsc);
  });

  testWidgets('the weak-to section is separate from the type section', (
    tester,
  ) async {
    final applied = await _open(tester);
    expect(find.text('Weak to'), findsOneWidget);

    // The same type name appears in both sections; the second is weak-to.
    final fire = find.text('Fire');
    expect(fire, findsNWidgets(2));
    await tester.ensureVisible(fire.last);
    await tester.pump();
    await tester.tap(fire.last);
    await tester.pump();
    expect(find.text('Apply (1)'), findsOneWidget);

    await tester.tap(find.text('Apply (1)'));
    await tester.pump();

    expect(applied.single.weakTo, {'fire'});
    expect(applied.single.types, isEmpty);
  });

  testWidgets('Clear all also clears the weak-to types', (tester) async {
    final applied = await _open(
      tester,
      initial: const FilterSelection(
        types: {},
        weakTo: {'ground', 'ice'},
        generations: {},
        sort: PokemonSort.numberAsc,
      ),
    );
    expect(find.text('Apply (2)'), findsOneWidget);

    await tester.tap(find.text('Clear all'));
    await tester.pump();
    await tester.tap(find.text('Show all'));

    expect(applied.single.weakTo, isEmpty);
  });

  testWidgets('is translated', (tester) async {
    await _open(tester, locale: const Locale('it'));

    expect(find.text('Filtra e ordina'), findsOneWidget);
    expect(find.text('Generazione'), findsOneWidget);
    expect(find.text('Gen. VII'), findsOneWidget);
    expect(find.text('Nome (A–Z)'), findsOneWidget);
    expect(find.text('Debole a'), findsOneWidget);
    expect(find.text('Fuoco'), findsNWidgets(2));
  });

  testWidgets('fits a small phone', (tester) async {
    await _open(tester);
    tester.view.physicalSize = const Size(1080, 1704);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Show all'), findsOneWidget);
  });

  testWidgets('keeps the Apply button above the system navigation bar', (
    tester,
  ) async {
    await _open(tester, bottomAligned: true);
    // 48 dp navigation bar at the bottom of a 3x screen (edge-to-edge).
    tester.view.viewPadding = const FakeViewPadding(bottom: 144);
    addTearDown(tester.view.resetViewPadding);
    await tester.pump();

    final screenHeight = tester.view.physicalSize.height / 3;
    final apply = tester.getRect(
      find.widgetWithText(ElevatedButton, 'Show all'),
    );
    expect(apply.bottom, lessThanOrEqualTo(screenHeight - 48));
  });
}
