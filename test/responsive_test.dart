import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/theme/responsive.dart';

void main() {
  group('designSizeFor', () {
    test('keeps the phone design on the reference phone', () {
      final size = designSizeFor(const Size(390, 844));

      expect(size.width, closeTo(360, 0.001));
      expect(size.height, closeTo(979, 0.001));
    });

    test('a smaller phone scales down, not up', () {
      final size = designSizeFor(const Size(320, 640));

      expect(size.width, closeTo(360, 0.001)); // 320 dp wide = scale 0.89
      expect(320 / size.width, lessThan(1));
    });

    test('scaling stops at the cap, so a tablet is not magnified', () {
      final tablet = designSizeFor(const Size(820, 1180));
      final bigTablet = designSizeFor(const Size(1280, 1920));

      // Same scale (480/360) for both: more room, same control size.
      expect(820 / tablet.width, closeTo(480 / 360, 0.001));
      expect(1280 / bigTablet.width, closeTo(480 / 360, 0.001));
    });

    test('landscape keeps the same on-screen proportions as portrait', () {
      final portrait = designSizeFor(const Size(390, 844));
      final landscape = designSizeFor(const Size(844, 390));

      // Horizontal and vertical scale match the portrait ones.
      expect(844 / landscape.width, closeTo(390 / portrait.width, 0.001));
      expect(390 / landscape.height, closeTo(844 / portrait.height, 0.001));
    });
  });

  testWidgets('ContentWidth limits and centres the content', (tester) async {
    tester.view.physicalSize = const Size(1600, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: ContentWidth(child: SizedBox.expand(key: Key('content'))),
      ),
    );

    final rect = tester.getRect(find.byKey(const Key('content')));
    expect(rect.width, maxContentWidth);
    expect(rect.center.dx, 800);
  });
}
