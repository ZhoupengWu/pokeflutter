import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/palette.dart';
import 'widgets/random_floating_button.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/pokemon_list.dart';
import 'widgets/search_bar.dart';
import '../model/pokemon_list_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<PokemonListItem> pokemonList = [];

  @override
  void initState() {
    super.initState();
    readJSONFile();
  }

  void readJSONFile() async {
    final jsonFile = await rootBundle.loadString('assets/pokemonList.json');
    final decoded = jsonDecode(jsonFile);

    final items = (decoded['pokemonList'] as List)
      .map((item) => PokemonListItem(name: item['name'], url: item['url']))
      .toList();

    if (!mounted) return;

    setState(() {
      pokemonList.addAll(items);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // FAB floats above content — not inside the Column
      floatingActionButton: const RandomFloatingButton(),
      bottomNavigationBar: const BottomNavBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Respect status bar height + a small fixed gap
          SizedBox(height: MediaQuery.of(context).padding.top + 16),
          // Title
          Padding(
            padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 4.h),
            child: Text('Pokédex', style: textTheme.displaySmall),
          ),
          // Subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Use the advanced search to find Pokémon by type, weakness, ability and more!',
              style: textTheme.bodyLarge?.copyWith(color: gray[400], height: 1.5),
            ),
          ),
          SizedBox(height: 16.h),
          SearchBarWidget(),
          SizedBox(height: 24.h),
          Expanded(child: PokemonList(pokemonList: pokemonList)),
        ],
      ),
    );
  }
}