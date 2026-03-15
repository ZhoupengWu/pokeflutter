import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'views/shell_page.dart';
import 'utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 979),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'PokéFlutter',
          debugShowCheckedModeBanner: false,
          theme: pokeFlutterTheme,
          home: const ShellPage(),
        );
      },
    );
  }
}