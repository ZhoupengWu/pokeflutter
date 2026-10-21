import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/views/types/type_chart_page.dart';
import 'package:pokeflutter/theme/app_colors.dart';

import 'support/fonts.dart';
import 'support/test_app.dart';

Future<void> _open(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(testApp(const TypeChartPage(), locale: locale));
  await tester.pump();
}

void main() {
  setUpAll(loadRoboto);

  testWidgets('shows the title, hint and legend', (tester) async {
    await _open(tester);

    expect(find.text('Type chart'), findsOneWidget);
    expect(find.textContaining('Rows are the attacking type'), findsOneWidget);
    expect(find.text('Super effective (2×)'), findsOneWidget);
    expect(find.text('Not very effective (½×)'), findsOneWidget);
    expect(find.text('No effect (0×)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cells announce who hits whom and how hard', (tester) async {
    await _open(tester);

    expect(find.bySemanticsLabel('Fire against Grass: 2×'), findsOneWidget);
    expect(find.bySemanticsLabel('Fire against Water: ½×'), findsOneWidget);
    expect(find.bySemanticsLabel('Normal against Ghost: 0×'), findsOneWidget);
    // A neutral matchup is not announced.
    expect(find.bySemanticsLabel('Fire against Normal: 1×'), findsNothing);
  }, semanticsEnabled: true);

  testWidgets('is translated', (tester) async {
    await _open(tester, locale: const Locale('it'));

    expect(find.text('Tabella dei tipi'), findsOneWidget);
    expect(find.text('Superefficace (2×)'), findsOneWidget);
    expect(find.text('Nessun effetto (0×)'), findsOneWidget);
  });

  test('cell colours and labels', () {
    expect(TypeChartPage.cellColor(2), successGreen);
    expect(TypeChartPage.cellColor(1), isNull);
    expect(TypeChartPage.cellLabel(0.5), '½');
    expect(TypeChartPage.cellLabel(0), '0');
    expect(TypeChartPage.cellLabel(1), '');
  });
}
