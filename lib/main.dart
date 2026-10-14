import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'utils/app_settings.dart';
import 'utils/favourites_manager.dart';
import 'utils/pokemon_repository.dart';
import 'utils/pokemon_type_index.dart';
import 'utils/theme.dart';
import 'views/shell_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Draw behind the system bars; their colours come from the page overlay style.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // FavouritesManager re-hydrates saved names into PokemonListItem objects.
  final allPokemon = await PokemonRepository.instance.getAll();

  await FavouritesManager.instance.init(allPokemon);
  await AppSettings.instance.init();

  // Types of every Pokémon (grid colours and badges). Not awaited: the grid
  // repaints when the index arrives. Failures are retried on next use.
  unawaited(PokemonTypeIndex.instance.ensureLoaded());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, AppSettings? settings}) : _settings = settings;

  final AppSettings? _settings;

  @override
  Widget build(BuildContext context) {
    final settings = _settings ?? AppSettings.instance;
    return ScreenUtilInit(
      designSize: const Size(360, 979),
      minTextAdapt: true,
      builder: (context, child) {
        return ListenableBuilder(
          listenable: settings,
          builder: (context, _) => MaterialApp(
            title: 'PokéFlutter',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: settings.themeMode,
            builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
              value: pageOverlayStyle(Theme.of(context).brightness),
              child: child!,
            ),
            home: const ShellPage(),
          ),
        );
      },
    );
  }
}
