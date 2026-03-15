import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'model/pokemon_list_item.dart';
import 'utils/favourites_manager.dart';
import 'utils/theme.dart';
import 'views/shell_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the full Pokémon list so FavouritesManager can re-hydrate
  // saved names into proper PokemonListItem objects.
  final jsonFile = await rootBundle.loadString('assets/pokemonList.json');
  final decoded = jsonDecode(jsonFile);
  final allPokemon = (decoded['pokemonList'] as List)
      .map((item) => PokemonListItem(name: item['name'], url: item['url']))
      .toList();

  await FavouritesManager.instance.init(allPokemon);

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