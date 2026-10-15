import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/views/home/search_bar.dart';
import 'support/test_app.dart';

Widget _app({
  required ValueChanged<String> onSearch,
  VoidCallback? onFilterTap,
  int activeFilterCount = 0,
}) => testApp(
  SearchBarWidget(
    onSearch: onSearch,
    onFilterTap: onFilterTap,
    activeFilterCount: activeFilterCount,
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

    final button = find.bySemanticsLabel('Filters, 2 selected');
    expect(button, findsOneWidget);

    await tester.tap(button);
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('filter label without active filters', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(onSearch: (_) {}));

    expect(find.bySemanticsLabel('Filters'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('tapping elsewhere takes the focus off the field', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        Column(
          children: [
            SearchBarWidget(onSearch: (_) {}),
            const Expanded(child: Center(child: Text('somewhere else'))),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.hasPrimaryFocus, isTrue);
    expect(tester.widget<TextField>(find.byType(TextField)).focusNode, isNull);
    expect(
      tester
          .state<EditableTextState>(find.byType(EditableText))
          .widget
          .focusNode
          .hasFocus,
      isTrue,
    );

    await tester.tap(find.text('somewhere else'));
    await tester.pump();
    expect(
      tester
          .state<EditableTextState>(find.byType(EditableText))
          .widget
          .focusNode
          .hasFocus,
      isFalse,
    );
  });
}
