import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pokeflutter/utils/theme.dart';

/// Wraps [child] the way the real app does: screen-util sizing and the app
/// theme, inside a [Scaffold].
Widget testApp(Widget child, {ThemeData? theme}) => ScreenUtilInit(
  designSize: const Size(360, 979),
  builder: (_, _) => MaterialApp(
    theme: theme ?? lightTheme,
    home: Scaffold(body: child),
  ),
);
