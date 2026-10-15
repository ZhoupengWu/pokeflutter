import 'dart:io';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'disk_cache.dart';

/// What the app keeps on the device so it works offline (Pokémon details and
/// evolution chains in a [DiskCache], artwork in the image cache), and a way
/// to measure and empty it. Favourites, settings and quiz records are not
/// part of it.
///
/// Every part is optional: without them the storage is simply empty, which is
/// what tests and unsupported platforms get.
class OfflineStorage {
  OfflineStorage({
    this.disk,
    Future<int> Function()? imagesSize,
    Future<void> Function()? clearImages,
  }) : _imagesSize = imagesSize,
       _clearImages = clearImages;

  /// The production storage: the shared [disk] cache plus the images stored by
  /// `cached_network_image`.
  factory OfflineStorage.production(DiskCache disk) => OfflineStorage(
    disk: disk,
    imagesSize: _cachedImagesSize,
    clearImages: _clearCachedImages,
  );

  final DiskCache? disk;
  final Future<int> Function()? _imagesSize;
  final Future<void> Function()? _clearImages;

  /// Bytes used by everything that can be cleared.
  Future<int> sizeBytes() async =>
      (await disk?.sizeBytes() ?? 0) + (await _imagesSize?.call() ?? 0);

  /// Deletes the saved data and images. Anything shown is fetched again the
  /// next time it is needed.
  Future<void> clear() async {
    await disk?.clear();
    await _clearImages?.call();
  }

  // `cached_network_image` keeps its files in this folder of the temp dir.
  static const _imagesFolder = 'libCachedImageData';

  static Future<int> _cachedImagesSize() async {
    try {
      final base = await getTemporaryDirectory();
      final dir = Directory('${base.path}/$_imagesFolder');
      if (!await dir.exists()) return 0;
      var total = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) total += await entity.length();
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> _clearCachedImages() async {
    try {
      await DefaultCacheManager().emptyCache();
    } catch (_) {}
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}
