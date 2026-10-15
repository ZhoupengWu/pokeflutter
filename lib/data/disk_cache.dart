import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// A value read back from a [DiskCache].
class DiskCacheEntry {
  const DiskCacheEntry(this.value, this.savedAt);

  /// The stored text.
  final String value;

  /// When it was written (for deciding if it is still fresh).
  final DateTime savedAt;
}

/// Small persistent key/value cache: one JSON file per key in a directory,
/// bounded by [maxEntries] (the least recently used files are deleted first).
///
/// It is an optimisation: every failure (no directory, full disk, corrupted
/// file, unsupported platform) is swallowed and simply behaves like a miss.
class DiskCache {
  DiskCache({Future<Directory> Function()? directory, this.maxEntries = 400})
    : _directory = directory ?? _defaultDirectory;

  /// Files kept at most.
  final int maxEntries;

  final Future<Directory> Function() _directory;
  Future<Directory?>? _ready;

  static Future<Directory> _defaultDirectory() async {
    final base = await getApplicationSupportDirectory();
    return Directory('${base.path}/pokeapi_cache');
  }

  Future<Directory?> _dir() => _ready ??= _open();

  Future<Directory?> _open() async {
    try {
      final dir = await _directory();
      await dir.create(recursive: true);
      return dir;
    } catch (_) {
      return null;
    }
  }

  // Keys become file names, so keep them to a safe alphabet.
  File _file(Directory dir, String key) => File(
    '${dir.path}/${key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9._-]'), '_')}.json',
  );

  /// The entry stored under [key], or null when missing or unreadable.
  Future<DiskCacheEntry?> read(String key) async {
    try {
      final dir = await _dir();
      if (dir == null) return null;
      final file = _file(dir, key);
      if (!await file.exists()) return null;
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      await file.setLastModified(DateTime.now()); // recently used
      return DiskCacheEntry(
        json['value'] as String,
        DateTime.parse(json['savedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  /// Stores [value] under [key] and trims the cache to [maxEntries].
  Future<void> write(String key, String value, {DateTime? now}) async {
    try {
      final dir = await _dir();
      if (dir == null) return;
      await _file(dir, key).writeAsString(
        jsonEncode({
          'savedAt': (now ?? DateTime.now()).toIso8601String(),
          'value': value,
        }),
      );
      await _trim(dir);
    } catch (_) {
      // Not persisted; the in-memory copy is still valid.
    }
  }

  Future<void> _trim(Directory dir) async {
    final files = [
      await for (final entity in dir.list())
        if (entity is File && entity.path.endsWith('.json')) entity,
    ];
    if (files.length <= maxEntries) return;
    final stamped = [
      for (final file in files) (file, (await file.lastModified())),
    ]..sort((a, b) => a.$2.compareTo(b.$2));
    for (final (file, _) in stamped.take(files.length - maxEntries)) {
      await file.delete();
    }
  }

  /// Deletes everything.
  Future<void> clear() async {
    try {
      final dir = await _dir();
      if (dir == null) return;
      await for (final entity in dir.list()) {
        if (entity is File) await entity.delete();
      }
    } catch (_) {}
  }
}
