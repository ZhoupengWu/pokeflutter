import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../model/pokemon_list_item.dart';
import '../model/pokemon.dart';
import '../utils/pokemon_api.dart';
import '../utils/pokemon_costants.dart';
import '../utils/capitalize.dart';
import '../utils/palette.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  List<PokemonListItem> _allPokemon = [];
  PokemonListItem? _selectedA;
  PokemonListItem? _selectedB;
  Pokemon? _pokemonA;
  Pokemon? _pokemonB;
  bool _loadingA = false;
  bool _loadingB = false;

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  void _loadList() async {
    final jsonFile = await rootBundle.loadString('assets/pokemonList.json');
    final decoded = jsonDecode(jsonFile);
    final items = (decoded['pokemonList'] as List)
        .map((item) => PokemonListItem(name: item['name'], url: item['url']))
        .toList();
    if (!mounted) return;
    setState(() => _allPokemon = items);
  }

  Future<void> _selectPokemon(bool isA) async {
    final result = await showModalBottomSheet<PokemonListItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => _PokemonPickerSheet(allPokemon: _allPokemon),
    );
    if (result == null) return;

    if (isA) {
      setState(() {
        _selectedA = result;
        _pokemonA = null;
        _loadingA = true;
      });
      final data = await PokemonApi.getPokemonDetails(result.name);
      if (!mounted) return;
      setState(() {
        _pokemonA = data;
        _loadingA = false;
      });
    } else {
      setState(() {
        _selectedB = result;
        _pokemonB = null;
        _loadingB = true;
      });
      final data = await PokemonApi.getPokemonDetails(result.name);
      if (!mounted) return;
      setState(() {
        _pokemonB = data;
        _loadingB = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 4.h),
              child: Text('Compare', style: textTheme.displaySmall),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'Select two Pokémon to compare their stats.',
                style: textTheme.bodyLarge?.copyWith(
                  color: gray[400],
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // ── Selector row ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Expanded(
                    child: _PokemonSlot(
                      pokemon: _pokemonA,
                      selected: _selectedA,
                      isLoading: _loadingA,
                      label: 'Pokémon A',
                      onTap: () => _selectPokemon(true),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      'VS',
                      style: textTheme.titleLarge?.copyWith(
                        color: gray[300],
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _PokemonSlot(
                      pokemon: _pokemonB,
                      selected: _selectedB,
                      isLoading: _loadingB,
                      label: 'Pokémon B',
                      onTap: () => _selectPokemon(false),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ── Stats comparison ──────────────────────────────────────────
            if (_pokemonA != null && _pokemonB != null)
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: _StatsComparison(a: _pokemonA!, b: _pokemonB!),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Text(
                    _selectedA == null && _selectedB == null
                        ? 'Select two Pokémon to start comparing'
                        : 'Select the second Pokémon to compare',
                    style: textTheme.bodyMedium?.copyWith(color: gray[300]),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Pokemon slot widget ───────────────────────────────────────────────────────
class _PokemonSlot extends StatelessWidget {
  final Pokemon? pokemon;
  final PokemonListItem? selected;
  final bool isLoading;
  final String label;
  final VoidCallback onTap;

  const _PokemonSlot({
    required this.pokemon,
    required this.selected,
    required this.isLoading,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = pokemon != null
        ? (listPokemonTypeColor[pokemon!.typesList[0].toLowerCase()] ??
              gray[200]!)
        : gray[100]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 140.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : pokemon != null
            ? _loadedSlot(context, pokemon!)
            : _emptySlot(context),
      ),
    );
  }

  Widget _emptySlot(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.add_circle_outline_rounded, size: 32.r, color: gray[300]),
      SizedBox(height: 8.h),
      Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: gray[300]),
      ),
    ],
  );

  Widget _loadedSlot(BuildContext context, Pokemon p) => Padding(
    padding: EdgeInsets.all(10.r),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          p.name.capitalize(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Image.network(
          p.urlImage,
          height: 72.r,
          width: 72.r,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.catching_pokemon, size: 48.r, color: Colors.white38),
        ),
      ],
    ),
  );
}

// ── Stats comparison table ───────────────────────────────────────────────────
class _StatsComparison extends StatelessWidget {
  final Pokemon a;
  final Pokemon b;

  const _StatsComparison({required this.a, required this.b});

  static const _statLabels = {
    'hp': 'HP',
    'attack': 'ATK',
    'defense': 'DEF',
    'special-attack': 'SpA',
    'special-defense': 'SpD',
    'speed': 'SPD',
  };

  Color _colorA(int vA, int vB) =>
      vA >= vB ? const Color(0xFF38BF4B) : Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorA =
        listPokemonTypeColor[a.typesList[0].toLowerCase()] ?? gray[400]!;
    final colorB =
        listPokemonTypeColor[b.typesList[0].toLowerCase()] ?? gray[400]!;

    return Column(
      children: [
        // Stat header
        Row(
          children: [
            Expanded(
              child: Text(
                a.name.capitalize(),
                style: textTheme.labelMedium?.copyWith(
                  color: colorA,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 40.w),
            Expanded(
              child: Text(
                b.name.capitalize(),
                style: textTheme.labelMedium?.copyWith(
                  color: colorB,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Stat rows
        ...a.stats.map((statA) {
          final statB = b.stats.firstWhere(
            (s) => s.name == statA.name,
            orElse: () => PokemonStat(name: statA.name, value: 0),
          );
          final label =
              _statLabels[statA.name] ??
              statA.name.substring(0, 3).toUpperCase();

          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                // Bar A (grows right-to-left)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        statA.value.toString(),
                        style: textTheme.bodySmall?.copyWith(
                          color: _colorA(statA.value, statB.value),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: RotatedBox(
                          quarterTurns: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: statA.value / 255.0,
                              minHeight: 8.h,
                              backgroundColor: gray[100],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _colorA(statA.value, statB.value),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Stat label center
                SizedBox(
                  width: 40.w,
                  child: Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: gray[400],
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Bar B (grows left-to-right)
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: statB.value / 255.0,
                            minHeight: 8.h,
                            backgroundColor: gray[100],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _colorA(statB.value, statA.value),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        statB.value.toString(),
                        style: textTheme.bodySmall?.copyWith(
                          color: _colorA(statB.value, statA.value),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 24.h),
      ],
    );
  }
}

// ── Pokemon picker bottom sheet ───────────────────────────────────────────────
class _PokemonPickerSheet extends StatefulWidget {
  final List<PokemonListItem> allPokemon;

  const _PokemonPickerSheet({required this.allPokemon});

  @override
  State<_PokemonPickerSheet> createState() => _PokemonPickerSheetState();
}

class _PokemonPickerSheetState extends State<_PokemonPickerSheet> {
  String _query = '';

  List<PokemonListItem> get _filtered => _query.isEmpty
      ? widget.allPokemon
      : widget.allPokemon
            .where((p) => p.name.toLowerCase().contains(_query))
            .toList();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          SizedBox(height: 8.h),
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: gray[200],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search Pokémon...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: gray[200]!),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final p = _filtered[i];
                return ListTile(
                  title: Text(p.name.capitalize()),
                  onTap: () => Navigator.pop(context, p),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}