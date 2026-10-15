import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/l10n_extensions.dart';
import '../../theme/app_colors.dart';
import '../../data/app_settings.dart';

/// Bottom sheet with the app preferences (theme and language).
class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<AppSettings>();
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
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
                  selected: {settings.locale?.languageCode ?? _systemLanguage},
                  onSelectionChanged: (codes) => settings.setLocale(
                    codes.first == _systemLanguage ? null : Locale(codes.first),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Segment value meaning "follow the system language".
const _systemLanguage = 'system';
