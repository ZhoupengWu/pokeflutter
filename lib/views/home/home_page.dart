import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/home_controller.dart';
import '../../core/pokedex.dart';
import '../../core/pokemon_constants.dart';
import '../../data/network_status.dart';
import '../../l10n/l10n_extensions.dart';
import '../../theme/app_colors.dart';
import '../detail/pokemon_detail_page.dart';
import '../shared/pokemon_list.dart';
import 'random_floating_button.dart';
import 'search_bar.dart';
import 'settings_sheet.dart';
import 'filter_sheet.dart';
import 'home_widgets.dart';

/// The Pokédex tab: search, type filters and the grid of Pokémon.
class HomePage extends StatefulWidget {
  /// Pass a [controller] to drive the page from a test.
  const HomePage({super.key, this.controller});

  final HomeController? controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;
  late final NetworkStatus _network;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        HomeController(
          repository: context.read(),
          typeIndex: context.read(),
          names: context.read(),
        );
    _network = context.read<NetworkStatus>();
    _controller.init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.setLanguage(Localizations.localeOf(context).languageCode);
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Future<void> _openFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FilterSheet(
          initial: FilterSelection(
            types: _controller.activeTypes,
            weakTo: _controller.activeWeakTo,
            generations: _controller.activeGenerations,
            sort: _controller.sort,
          ),
          onApply: (selection) => _controller.setSelection(
            types: selection.types,
            weakTo: selection.weakTo,
            generations: selection.generations,
            sort: selection.sort,
          ),
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
    final random = _controller.randomPokemon();
    if (random == null) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PokemonDetailPage(pokemon: random),
      ),
    );
  }

  /// One removable chip per active type, generation and non-default sort.
  List<ActiveFilter> _activeFilters(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return [
      for (final type in _controller.activeTypes)
        ActiveFilter(
          label: l10n.typeName(type),
          color: listPokemonTypeColor[type] ?? colors.muted,
          onRemove: () => _controller.setTypeFilters(
            Set.of(_controller.activeTypes)..remove(type),
          ),
        ),
      for (final type in _controller.activeWeakTo)
        ActiveFilter(
          label: l10n.weakToChip(l10n.typeName(type)),
          color: listPokemonTypeColor[type] ?? colors.muted,
          onRemove: () => _controller.setWeakToFilters(
            Set.of(_controller.activeWeakTo)..remove(type),
          ),
        ),
      for (final number in _controller.activeGenerations.toList()..sort())
        ActiveFilter(
          label: l10n.generationName(generations[number - 1].roman),
          color: colors.muted,
          onRemove: () => _controller.setGenerationFilters(
            Set.of(_controller.activeGenerations)..remove(number),
          ),
        ),
      if (_controller.sort != PokemonSort.numberAsc)
        ActiveFilter(
          label: sortName(l10n, _controller.sort),
          color: colors.muted,
          onRemove: () => _controller.setSort(PokemonSort.numberAsc),
        ),
    ];
  }

  Widget _buildResults(BuildContext context) {
    final l10n = context.l10n;
    if (_controller.isFilterLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.filterFailed) {
      return HomeMessage(
        icon: Icons.wifi_off_rounded,
        text: l10n.typesLoadFailed,
        action: TextButton(
          onPressed: _controller.applyFilters,
          child: Text(l10n.retry),
        ),
      );
    }
    if (_controller.filtered.isEmpty && _controller.allPokemon.isNotEmpty) {
      return HomeMessage(
        icon: Icons.search_off_rounded,
        text: l10n.noPokemonFound,
      );
    }
    return PokemonList(pokemonList: _controller.filtered, heroScope: 'home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // Lifted above the floating tab bar, whose height is the bottom padding.
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        child: RandomFloatingButton(onPressed: _goToRandomPokemon),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_controller, _network]),
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 16),
            Padding(
              padding: EdgeInsets.only(left: 24.w, right: 12.w, bottom: 4.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l10n.homeTitle, style: textTheme.displaySmall),
                  ),
                  IconButton(
                    tooltip: l10n.settings,
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
                l10n.homeSubtitle,
                style: textTheme.bodyLarge?.copyWith(
                  color: context.colors.muted,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SearchBarWidget(
              onSearch: _controller.setSearch,
              activeFilterCount: _controller.activeFilterCount,
              onFilterTap: _openFilterSheet,
            ),
            if (_controller.typesUnavailable)
              ConnectionBanner(
                message: l10n.typesUnavailableOffline,
                onRetry: _controller.loadTypes,
              )
            else if (_network.isOffline)
              ConnectionBanner(message: l10n.offlineBanner),
            if (_controller.activeFilterCount > 0) ...[
              SizedBox(height: 8.h),
              ActiveFilterChips(
                filters: _activeFilters(context),
                onClearAll: () => _controller.setSelection(
                  types: const {},
                  weakTo: const {},
                  generations: const {},
                  sort: PokemonSort.numberAsc,
                ),
              ),
            ],
            SizedBox(height: 16.h),
            Expanded(child: _buildResults(context)),
          ],
        ),
      ),
    );
  }
}
