import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/views/widgets/search_bar.dart';

Widget _app({
  required ValueChanged<String> onSearch,
  VoidCallback? onFilterTap,
  int activeFilterCount = 0,
}) => ScreenUtilInit(
  designSize: const Size(360, 979),
  builder: (_, _) => MaterialApp(
    home: Scaffold(
      body: SearchBarWidget(
        onSearch: onSearch,
        onFilterTap: onFilterTap,
        activeFilterCount: activeFilterCount,
      ),
    ),
  ),
);

void main() {
  testWidgets('reports typed text and can clear it', (tester) async {
    final queries = <String>[];
    await tester.pumpWidget(_app(onSearch: queries.add));

    await tester.enterText(find.byType(TextField), 'pika');
    await tester.pump();
    expect(queries, ['pika']);

    await tester.tap(find.bySemanticsLabel('Clear search'));
    await tester.pump();
    expect(queries, ['pika', '']);
    expect(find.bySemanticsLabel('Clear search'), findsNothing);
  });

  testWidgets('filter button is labelled and tappable', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await tester.pumpWidget(
      _app(onSearch: (_) {}, onFilterTap: () => taps++, activeFilterCount: 2),
    );

    final button = find.bySemanticsLabel('Filter by type, 2 selected');
    expect(button, findsOneWidget);

    await tester.tap(button);
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('filter label without active filters', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(onSearch: (_) {}));

    expect(find.bySemanticsLabel('Filter by type'), findsOneWidget);
    handle.dispose();
  });
}
