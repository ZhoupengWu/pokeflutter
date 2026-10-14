import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'utils/favourites_manager.dart';
import 'utils/pokemon_repository.dart';
import 'utils/pokemon_type_index.dart';
import 'utils/theme.dart';
import 'views/shell_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FavouritesManager re-hydrates saved names into PokemonListItem objects.
  final allPokemon = await PokemonRepository.instance.getAll();

  await FavouritesManager.instance.init(allPokemon);

  // Types of every Pokémon (grid colours and badges). Not awaited: the grid
  // repaints when the index arrives. Failures are retried on next use.
  unawaited(PokemonTypeIndex.instance.ensureLoaded());

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
