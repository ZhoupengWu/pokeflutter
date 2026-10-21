import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/app_services.dart';
import 'package:pokeflutter/core/format_bytes.dart';
import 'package:pokeflutter/data/disk_cache.dart';
import 'package:pokeflutter/data/offline_storage.dart';
import 'package:pokeflutter/views/home/settings_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/test_app.dart';

void main() {
  test('formatBytes uses B, KB, MB and GB', () {
    expect(formatBytes(0), '0 B');
    expect(formatBytes(999), '999 B');
    expect(formatBytes(1000), '1.0 KB');
    expect(formatBytes(1536), '1.5 KB');
    expect(formatBytes(3200000), '3.2 MB');
    expect(formatBytes(2500000000), '2.5 GB');
  });

  group('OfflineStorage', () {
    late Directory dir;
    setUp(() async => dir = await Directory.systemTemp.createTemp('storage'));
    tearDown(() async {
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    test('is empty without a disk cache or images', () async {
      final storage = OfflineStorage();
      expect(await storage.sizeBytes(), 0);
      await storage.clear(); // does nothing, does not throw
    });

    test('adds up the disk cache and the images, and clears both', () async {
      final disk = DiskCache(directory: () async => dir);
      await disk.write('pokemon-pikachu', 'x' * 100);
      var images = 5000;
      final storage = OfflineStorage(
        disk: disk,
        imagesSize: () async => images,
        clearImages: () async => images = 0,
      );

      expect(await disk.sizeBytes(), greaterThan(100));
      expect(await storage.sizeBytes(), 5000 + await disk.sizeBytes());

      await storage.clear();

      expect(await disk.sizeBytes(), 0);
      expect(await storage.sizeBytes(), 0);
      expect(await disk.read('pokemon-pikachu'), isNull);
    });
  });

  group('settings sheet', () {
    // Pumps the sheet on a tall screen so the storage row is visible.
    Future<void> open(
      WidgetTester tester,
      OfflineStorage storage, {
      Locale locale = const Locale('en'),
    }) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        testApp(
          const SettingsSheet(),
          services: AppServices(storage: storage),
          locale: locale,
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows what is saved and clears it', (tester) async {
      var bytes = 3200000;
      await open(
        tester,
        OfflineStorage(
          imagesSize: () async => bytes,
          clearImages: () async => bytes = 0,
        ),
      );

      expect(find.text('OFFLINE DATA'), findsOneWidget);
      expect(
        find.text('3.2 MB of Pokémon data and images saved on this device'),
        findsOneWidget,
      );

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(bytes, 0);
      expect(find.text('Nothing saved on this device'), findsOneWidget);
      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Clear'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('is translated', (tester) async {
      await open(
        tester,
        OfflineStorage(imagesSize: () async => 1500),
        locale: const Locale('it'),
      );

      expect(find.text('DATI OFFLINE'), findsOneWidget);
      expect(
        find.text(
          '1.5 KB di dati e immagini dei Pokémon salvati su questo dispositivo',
        ),
        findsOneWidget,
      );
      expect(find.text('Svuota'), findsOneWidget);
    });
  });
}
