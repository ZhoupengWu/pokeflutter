import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/data/disk_cache.dart';

void main() {
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('disk_cache'));
  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  DiskCache cache({int maxEntries = 400}) =>
      DiskCache(directory: () async => dir, maxEntries: maxEntries);

  test('stores a value with the time it was saved', () async {
    final saved = DateTime(2026, 1, 2, 3, 4, 5);
    await cache().write('pokemon-pikachu', '{"a":1}', now: saved);

    final entry = await cache().read('pokemon-pikachu'); // a fresh instance
    expect(entry?.value, '{"a":1}');
    expect(entry?.savedAt, saved);
  });

  test('a missing key is a miss', () async {
    expect(await cache().read('nope'), isNull);
  });

  test('writing again replaces the value', () async {
    final c = cache();
    await c.write('k', 'one');
    await c.write('k', 'two');

    expect((await c.read('k'))?.value, 'two');
  });

  test('keys with odd characters are safe file names', () async {
    final c = cache();
    await c.write('Pokemon/Mr. Mime ../x', 'v');

    expect((await c.read('Pokemon/Mr. Mime ../x'))?.value, 'v');
    final names = dir.listSync().map((e) => e.uri.pathSegments.last);
    expect(names.single, matches(RegExp(r'^[a-z0-9._-]+\.json$')));
  });

  test('the least recently used entries are dropped past the limit', () async {
    final c = cache(maxEntries: 3);
    for (final key in ['a', 'b', 'c']) {
      await c.write(key, key);
      // Distinct, increasing modification times regardless of file system.
      await File(
        '${dir.path}/$key.json',
      ).setLastModified(DateTime(2026, 1, 1, 0, 0, key.codeUnitAt(0)));
    }
    await c.read('a'); // touches a: now the most recently used

    await c.write('d', 'd');

    expect(await c.read('b'), isNull); // the oldest untouched one went
    expect((await c.read('a'))?.value, 'a');
    expect((await c.read('c'))?.value, 'c');
    expect((await c.read('d'))?.value, 'd');
    expect(dir.listSync(), hasLength(3));
  });

  test('a corrupted file is a miss, not an error', () async {
    await File('${dir.path}/bad.json').writeAsString('{not json');

    expect(await cache().read('bad'), isNull);
  });

  test('an unusable directory just disables the cache', () async {
    final blocked = DiskCache(
      directory: () async => throw const FileSystemException('read-only'),
    );

    await blocked.write('k', 'v'); // must not throw
    expect(await blocked.read('k'), isNull);
    await blocked.clear();
  });

  test('clear removes everything', () async {
    final c = cache();
    await c.write('a', '1');
    await c.write('b', '2');

    await c.clear();

    expect(await c.read('a'), isNull);
    expect(dir.listSync(), isEmpty);
  });
}
