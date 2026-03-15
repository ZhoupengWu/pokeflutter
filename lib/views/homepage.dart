import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/palette.dart';
import 'widgets/random_floating_button.dart';
import 'widgets/pokemon_list.dart';
import 'widgets/search_bar.dart';
import '../model/pokemon_list_item.dart';
import 'pokemon_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<PokemonListItem> _allPokemon = [];
  List<PokemonListItem> _filteredPokemon = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _readJSONFile();
  }

  void _readJSONFile() async {
    final jsonFile = await rootBundle.loadString('assets/pokemonList.json');
    final decoded = jsonDecode(jsonFile);

    final items = (decoded['pokemonList'] as List)
        .map((item) => PokemonListItem(name: item['name'], url: item['url']))
        .toList();

    if (!mounted) return;

    setState(() {
      _allPokemon.addAll(items);
      _filteredPokemon = List.from(_allPokemon);
    });
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
      _filteredPokemon = _searchQuery.isEmpty
          ? List.from(_allPokemon)
          : _allPokemon
              .where((p) => p.name.toLowerCase().contains(_searchQuery))
              .toList();
    });
  }

  void _goToRandomPokemon() {
    if (_allPokemon.isEmpty) return;
    final random = _allPokemon[Random().nextInt(_allPokemon.length)];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PokemonDetailPage(pokemon: random),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      floatingActionButton: RandomFloatingButton(onPressed: _goToRandomPokemon),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 16),
          Padding(
            padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 4.h),
            child: Text('Pokédex', style: textTheme.displaySmall),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Use the advanced search to find Pokémon by type, weakness, ability and more!',
              style: textTheme.bodyLarge?.copyWith(color: gray[400], height: 1.5),
            ),
          ),
          SizedBox(height: 16.h),
          SearchBarWidget(onSearch: _onSearch),
          SizedBox(height: 24.h),
          Expanded(child: PokemonList(pokemonList: _filteredPokemon)),
        ],
      ),
    );
  }
}