import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/home_controller.dart';
import '../../l10n/l10n_extensions.dart';
import '../../theme/app_colors.dart';
import '../detail/pokemon_detail_page.dart';
import '../shared/pokemon_list.dart';
import 'random_floating_button.dart';
import 'search_bar.dart';
import 'settings_sheet.dart';
import 'type_filter_sheet.dart';
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

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        HomeController(repository: context.read(), typeIndex: context.read());
    _controller.init();
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
        child: TypeFilterSheet(
          selectedTypes: _controller.activeTypes,
          onApply: _controller.setTypeFilters,
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
      floatingActionButton: RandomFloatingButton(onPressed: _goToRandomPokemon),
      body: ListenableBuilder(
        listenable: _controller,
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
              activeFilterCount: _controller.activeTypes.length,
              onFilterTap: _openFilterSheet,
            ),
            if (_controller.typesUnavailable)
              TypesUnavailableBanner(onRetry: _controller.loadTypes),
            if (_controller.activeTypes.isNotEmpty) ...[
              SizedBox(height: 8.h),
              ActiveFilterChips(
                filters: _controller.activeTypes,
                onRemove: (type) => _controller.setTypeFilters(
                  Set.of(_controller.activeTypes)..remove(type),
                ),
                onClearAll: () => _controller.setTypeFilters({}),
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
