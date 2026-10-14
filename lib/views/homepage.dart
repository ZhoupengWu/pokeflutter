import 'dart:math';
import 'package:flutter/material.dart';
import '../l10n/l10n_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors.dart';
import '../utils/pokemon_constants.dart';
import '../utils/pokemon_repository.dart';
import '../utils/pokemon_type_index.dart';
import 'widgets/random_floating_button.dart';
import 'widgets/pokemon_list.dart';
import 'widgets/search_bar.dart';
import 'widgets/settings_sheet.dart';
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
  bool _isFilterLoading = false;
  bool _filterFailed = false;
  bool _typesUnavailable = false; // type index could not be loaded
  int _filterRequest = 0; // discards results of superseded filter runs

  @override
  void initState() {
    super.initState();
    _readJSONFile();
    _loadTypes();
  }

  /// Types colour the cards; without them the grid still works, in grey.
  Future<void> _loadTypes() async {
    final loaded = await PokemonTypeIndex.instance.ensureLoaded();
    if (!mounted) return;
    setState(() => _typesUnavailable = !loaded);
  }

  Future<void> _readJSONFile() async {
    final items = await PokemonRepository.instance.getAll();
    if (!mounted) return;

    setState(() {
      _allPokemon.addAll(items);
      _filteredPokemon = List.from(_allPokemon);
    });
  }

  /// Applies search text and type filters to the full list.
  /// Type filtering needs the [PokemonTypeIndex]; it is downloaded on first
  /// use and the list shows a spinner (or a retry prompt) in the meantime.
  Future<void> _applyFilters() async {
    final request = ++_filterRequest;
    final typeFilters = _activeTypeFilters;

    if (typeFilters.isNotEmpty && !PokemonTypeIndex.instance.isLoaded) {
      setState(() {
        _isFilterLoading = true;
        _filterFailed = false;
      });
      final loaded = await PokemonTypeIndex.instance.ensureLoaded();
      if (!mounted || request != _filterRequest) return;
      if (!loaded) {
        setState(() {
          _isFilterLoading = false;
          _filterFailed = true;
        });
        return;
      }
    }

    setState(() {
      _isFilterLoading = false;
      _filterFailed = false;
      _filteredPokemon = _allPokemon.where((p) {
        final matchesSearch =
            _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery);
        final matchesType =
            typeFilters.isEmpty ||
            PokemonTypeIndex.instance.matchesAny(p.name, typeFilters);
        return matchesSearch && matchesType;
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

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SettingsSheet(),
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

  Widget _buildResults() {
    if (_isFilterLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_filterFailed) {
      return _Message(
        icon: Icons.wifi_off_rounded,
        text: context.l10n.typesLoadFailed,
        action: TextButton(
          onPressed: _applyFilters,
          child: Text(context.l10n.retry),
        ),
      );
    }
    if (_filteredPokemon.isEmpty && _allPokemon.isNotEmpty) {
      return _Message(
        icon: Icons.search_off_rounded,
        text: context.l10n.noPokemonFound,
      );
    }
    return PokemonList(pokemonList: _filteredPokemon);
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
            padding: EdgeInsets.only(left: 24.w, right: 12.w, bottom: 4.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.homeTitle,
                    style: textTheme.displaySmall,
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.settings,
                  icon: Icon(
                    Icons.settings_rounded,
                    color: context.colors.muted,
                  ),
                  onPressed: _openSettings,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              context.l10n.homeSubtitle,
              style: textTheme.bodyLarge?.copyWith(
                color: context.colors.muted,
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
          if (_typesUnavailable) _TypesUnavailableBanner(onRetry: _loadTypes),
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
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }
}

// ── Empty / error message ─────────────────────────────────────────────────────
class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? action;

  const _Message({required this.icon, required this.text, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64.r, color: context.colors.border),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.colors.subtle),
              textAlign: TextAlign.center,
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

// ── "Types could not be loaded" banner ────────────────────────────────────────
class _TypesUnavailableBanner extends StatelessWidget {
  final VoidCallback onRetry;

  const _TypesUnavailableBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 0),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 16.r,
            color: context.colors.subtle,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              context.l10n.typesUnavailableOffline,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.colors.subtle),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
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
            final color = listPokemonTypeColor[type] ?? context.colors.muted;
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
                    context.l10n.typeName(type),
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: Colors.white),
                  ),
                  SizedBox(width: 4.w),
                  Semantics(
                    button: true,
                    label: context.l10n.removeFilter(
                      context.l10n.typeName(type),
                    ),
                    excludeSemantics: true,
                    onTap: () => onRemove(type),
                    child: GestureDetector(
                      onTap: () => onRemove(type),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14.r,
                        color: Colors.white,
                      ),
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
                border: Border.all(color: context.colors.subtle),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                context.l10n.clearAll,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: context.colors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
