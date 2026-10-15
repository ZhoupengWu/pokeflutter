import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pokeflutter/app_services.dart';
import 'package:pokeflutter/l10n/app_localizations.dart';
import 'package:pokeflutter/theme/theme.dart';

/// Wraps [child] the way the real app does: services, screen-util sizing, the
/// app theme and localisations (English unless [locale] says otherwise),
/// inside a [Scaffold].
///
/// [services] defaults to real, unused collaborators; pass an [AppServices]
/// with fakes for whatever the widget under test reads from the tree.
Widget testApp(
  Widget child, {
  AppServices? services,
  ThemeData? theme,
  Locale locale = const Locale('en'),
}) => AppProviders(
  services: services ?? AppServices(),
  child: ScreenUtilInit(
    designSize: const Size(360, 979),
    builder: (_, _) => MaterialApp(
      theme: theme ?? lightTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  ),
);
