import 'package:flutter/services.dart';

/// Loads the bundled Roboto into the test engine.
///
/// Tests otherwise render every glyph as a one-em square (the Ahem font), which
/// makes text several times wider than in the app and hides or invents
/// overflow. Call it from `setUpAll` in tests that check layout against real
/// text widths.
Future<void> loadRoboto() async {
  final loader = FontLoader('Roboto')
    ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Roboto-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
  await loader.load();
}
