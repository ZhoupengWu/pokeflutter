import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/utils/app_colors.dart';
import 'package:pokeflutter/utils/app_settings.dart';
import 'package:pokeflutter/utils/theme.dart';
import 'package:pokeflutter/views/widgets/settings_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/test_app.dart';

void main() {
  group('AppSettings', () {
    test('defaults to following the system theme', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = AppSettings.test();
      await settings.init();
      expect(settings.themeMode, ThemeMode.system);
    });

    test('persists the chosen theme mode', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = AppSettings.test();
      await settings.setThemeMode(ThemeMode.dark);
      expect(settings.themeMode, ThemeMode.dark);

      final restored = AppSettings.test();
      await restored.init();
      expect(restored.themeMode, ThemeMode.dark);
    });

    test('ignores an unknown stored value', () async {
      SharedPreferences.setMockInitialValues({'settings_theme_mode': 'neon'});
      final settings = AppSettings.test();
      await settings.init();
      expect(settings.themeMode, ThemeMode.system);
    });
  });

  group('themes', () {
    test('provide matching brightness and colours', () {
      expect(lightTheme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);
      expect(lightTheme.extension<AppColors>(), AppColors.light);
      expect(darkTheme.extension<AppColors>(), AppColors.dark);
    });

    test('system bar icons contrast with the page background', () {
      expect(
        pageOverlayStyle(Brightness.light).statusBarIconBrightness,
        Brightness.dark,
      );
      expect(
        pageOverlayStyle(Brightness.dark).statusBarIconBrightness,
        Brightness.light,
      );
      expect(
        pageOverlayStyle(Brightness.light).statusBarColor,
        Colors.transparent,
      );
    });
  });

  testWidgets('the settings sheet switches the theme mode', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = AppSettings.test();
    await tester.pumpWidget(testApp(SettingsSheet(settings: settings)));

    await tester.tap(find.text('Dark'));
    await tester.pump();
    expect(settings.themeMode, ThemeMode.dark);

    await tester.tap(find.text('Light'));
    await tester.pump();
    expect(settings.themeMode, ThemeMode.light);
  });
}
