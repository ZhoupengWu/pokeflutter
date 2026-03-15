import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/palette.dart';
import '../utils/capitalize.dart';
import '../utils/pokemon_costants.dart';
import 'widgets/random_floating_button.dart';
import 'widgets/pokemon_list.dart';
import 'widgets/search_bar.dart';
import 'widgets/type_filter_sheet.dart';
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
  Set<String> _activeTypeFilters = {};

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

  void _applyFilters() {
    setState(() {
      _filteredPokemon = _allPokemon.where((p) {
        final matchesSearch =
            _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery);
        return matchesSearch;
      }).toList();
    });
  }

  void _onSearch(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
  }

  void _onTypeFiltersChanged(Set<String> filters) {
    setState(() => _activeTypeFilters = filters);
    _applyFilters();
  }

  void _openFilterSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TypeFilterSheet(
          selectedTypes: _activeTypeFilters,
          onApply: _onTypeFiltersChanged,
        ),
      ),
    );
  }

  void _goToRandomPokemon() {
    if (_allPokemon.isEmpty) return;
    final random = _allPokemon[Random().nextInt(_allPokemon.length)];
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PokemonDetailPage(pokemon: random)),
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
              style: textTheme.bodyLarge?.copyWith(
                color: gray[400],
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SearchBarWidget(
            onSearch: _onSearch,
            activeFilterCount: _activeTypeFilters.length,
            onFilterTap: _openFilterSheet,
          ),
          if (_activeTypeFilters.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _ActiveFilterChips(
              filters: _activeTypeFilters,
              onRemove: (type) {
                final updated = Set<String>.from(_activeTypeFilters)
                  ..remove(type);
                _onTypeFiltersChanged(updated);
              },
              onClearAll: () => _onTypeFiltersChanged({}),
            ),
          ],
          SizedBox(height: 16.h),
          Expanded(
            child: PokemonList(
              pokemonList: _filteredPokemon,
              activeTypeFilters: _activeTypeFilters,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active filter chips row ───────────────────────────────────────────────────
class _ActiveFilterChips extends StatelessWidget {
  final Set<String> filters;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;

  const _ActiveFilterChips({
    required this.filters,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        children: [
          ...filters.map((type) {
            final color = listPokemonTypeColor[type] ?? gray[400]!;
            return Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    type.capitalize(),
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: Colors.white),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () => onRemove(type),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14.r,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }),
          GestureDetector(
            onTap: onClearAll,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                border: Border.all(color: gray[300]!),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Clear all',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: gray[400]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}