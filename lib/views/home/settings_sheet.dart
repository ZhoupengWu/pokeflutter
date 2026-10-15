import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/l10n_extensions.dart';
import '../../theme/app_colors.dart';
import '../../core/format_bytes.dart';
import '../../data/app_settings.dart';
import '../../data/favourites_manager.dart';
import '../../data/offline_prefetcher.dart';
import '../../data/offline_storage.dart';

/// Bottom sheet with the app preferences (theme and language).
class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<AppSettings>();
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(context.l10n.settings, style: textTheme.headlineSmall),
              SizedBox(height: 16.h),
              Text(context.l10n.settingsTheme, style: textTheme.titleSmall),
              SizedBox(height: 8.h),
              ListenableBuilder(
                listenable: settings,
                builder: (context, _) => SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: const Icon(Icons.brightness_auto_rounded),
                        label: Text(context.l10n.themeSystem),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: const Icon(Icons.light_mode_rounded),
                        label: Text(context.l10n.themeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: const Icon(Icons.dark_mode_rounded),
                        label: Text(context.l10n.themeDark),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (modes) =>
                        settings.setThemeMode(modes.first),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(context.l10n.settingsLanguage, style: textTheme.titleSmall),
              SizedBox(height: 8.h),
              ListenableBuilder(
                listenable: settings,
                builder: (context, _) => SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: _systemLanguage,
                        label: Text(context.l10n.languageSystem),
                      ),
                      const ButtonSegment(value: 'en', label: Text('English')),
                      const ButtonSegment(value: 'it', label: Text('Italiano')),
                    ],
                    selected: {
                      settings.locale?.languageCode ?? _systemLanguage,
                    },
                    onSelectionChanged: (codes) => settings.setLocale(
                      codes.first == _systemLanguage
                          ? null
                          : Locale(codes.first),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(context.l10n.settingsStorage, style: textTheme.titleSmall),
              SizedBox(height: 4.h),
              const _StorageRow(),
            ],
          ),
        ),
      ),
    );
  }
}

/// How much is saved for offline use, and the button to clear it.
class _StorageRow extends StatefulWidget {
  const _StorageRow();

  @override
  State<_StorageRow> createState() => _StorageRowState();
}

class _StorageRowState extends State<_StorageRow> {
  late final OfflineStorage _storage = context.read<OfflineStorage>();
  late final OfflinePrefetcher _prefetcher = context.read<OfflinePrefetcher>();
  late final FavouritesManager _favourites = context.read<FavouritesManager>();
  int? _bytes;
  bool _clearing = false;

  /// Progress of a running download, and how the last one ended.
  ({int done, int total})? _saving;
  PrefetchResult? _saved;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final bytes = await _storage.sizeBytes();
    if (mounted) setState(() => _bytes = bytes);
  }

  Future<void> _clear() async {
    setState(() => _clearing = true);
    await _storage.clear();
    if (!mounted) return;
    setState(() => _clearing = false);
    await _refresh();
  }

  Future<void> _saveFavourites() async {
    final items = _favourites.favourites;
    setState(() {
      _saved = null;
      _saving = (done: 0, total: items.length);
    });
    final result = await _prefetcher.prefetch(
      items,
      onProgress: (done, total) {
        if (mounted) setState(() => _saving = (done: done, total: total));
      },
    );
    if (!mounted) return;
    setState(() {
      _saving = null;
      _saved = result;
    });
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final bytes = _bytes;
    final empty = bytes != null && bytes == 0;
    final hasFavourites = _favourites.favourites.isNotEmpty;
    final saving = _saving;
    final saved = _saved;
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: colors.muted);

    final storageRow = Row(
      children: [
        Expanded(
          child: Text(
            bytes == null
                ? ''
                : empty
                ? l10n.storageEmpty
                : l10n.storageUsed(formatBytes(bytes)),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.muted),
          ),
        ),
        SizedBox(width: 8.w),
        Semantics(
          label: l10n.storageClearSemantics,
          button: true,
          excludeSemantics: true,
          onTap: empty || _clearing ? null : _clear,
          child: TextButton(
            onPressed: empty || _clearing || bytes == null ? null : _clear,
            child: Text(l10n.storageClear),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        storageRow,
        SizedBox(height: 4.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: hasFavourites && saving == null ? _saveFavourites : null,
            icon: const Icon(Icons.download_rounded),
            label: Text(l10n.storageSaveFavourites),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          saving != null
              ? l10n.storageSaving(saving.done, saving.total)
              : saved != null
              ? (saved.isComplete
                    ? l10n.storageSaved
                    : l10n.storageSaveFailed(saved.failed))
              : hasFavourites
              ? ''
              : l10n.storageNoFavourites,
          style: style,
        ),
      ],
    );
  }
}

/// Segment value meaning "follow the system language".
const _systemLanguage = 'system';
