import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/pokedex.dart';
import '../../core/pokemon_constants.dart';
import '../../l10n/l10n_extensions.dart';
import '../../theme/app_colors.dart';
import '../../theme/contrast.dart';
import '../../theme/shapes.dart';

/// What the user picked in the [FilterSheet].
class FilterSelection {
  const FilterSelection({
    required this.types,
    required this.generations,
    required this.sort,
    this.weakTo = const {},
  });

  final Set<String> types;

  /// Attacking types the Pokémon must be weak to (any of them).
  final Set<String> weakTo;
  final Set<int> generations;
  final PokemonSort sort;

  /// Filters and sort orders that differ from "show everything, by number".
  int get count =>
      types.length +
      weakTo.length +
      generations.length +
      (sort == PokemonSort.numberAsc ? 0 : 1);
}

/// Display name of a sort order.
String sortName(AppLocalizations l10n, PokemonSort sort) => switch (sort) {
  PokemonSort.numberAsc => l10n.sortNumberAsc,
  PokemonSort.numberDesc => l10n.sortNumberDesc,
  PokemonSort.nameAsc => l10n.sortNameAsc,
  PokemonSort.nameDesc => l10n.sortNameDesc,
};

/// Bottom sheet to filter the Pokédex by type and generation and to choose
/// how it is sorted. Nothing changes until Apply.
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.initial, required this.onApply});

  final FilterSelection initial;
  final ValueChanged<FilterSelection> onApply;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late Set<String> _types;
  late Set<String> _weakTo;
  late Set<int> _generations;
  late PokemonSort _sort;

  @override
  void initState() {
    super.initState();
    _types = Set.of(widget.initial.types);
    _weakTo = Set.of(widget.initial.weakTo);
    _generations = Set.of(widget.initial.generations);
    _sort = widget.initial.sort;
  }

  FilterSelection get _selection => FilterSelection(
    types: _types,
    weakTo: _weakTo,
    generations: _generations,
    sort: _sort,
  );

  void _toggle<T>(Set<T> set, T value) => setState(() {
    if (!set.remove(value)) set.add(value);
  });

  void _clearAll() => setState(() {
    _types.clear();
    _weakTo.clear();
    _generations.clear();
    _sort = PokemonSort.numberAsc;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;
    final types = listPokemonTypeColor.keys.toList()..sort();
    final count = _selection.count;

    Widget heading(String text) => Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: textTheme.titleSmall?.copyWith(color: colors.muted),
        ),
      ),
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      // Keep the Apply button above the system navigation bar.
      padding: EdgeInsets.fromLTRB(
        24.w,
        16.h,
        24.w,
        24.h + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.filterSheetTitle,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.strong,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (count > 0)
                TextButton(
                  onPressed: _clearAll,
                  child: Text(
                    l10n.clearAll,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.redAccent,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  heading(l10n.filterTypeSection),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      for (final type in types)
                        _TypeChip(
                          type: type,
                          selected: _types.contains(type),
                          onTap: () => _toggle(_types, type),
                        ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  heading(l10n.filterWeakToSection),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      for (final type in types)
                        _TypeChip(
                          type: type,
                          selected: _weakTo.contains(type),
                          onTap: () => _toggle(_weakTo, type),
                        ),
                    ],
                  ),
                  if (_weakTo.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(
                        l10n.filterWeakToHint,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.subtle,
                        ),
                      ),
                    ),
                  SizedBox(height: 20.h),

                  heading(l10n.filterGenerationSection),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      for (final generation in generations)
                        FilterChip(
                          label: Text(l10n.generationName(generation.roman)),
                          selected: _generations.contains(generation.number),
                          showCheckmark: false,
                          onSelected: (_) =>
                              _toggle(_generations, generation.number),
                        ),
                    ],
                  ),
                  if (_generations.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(
                        l10n.filterGenerationHint,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.subtle,
                        ),
                      ),
                    ),
                  SizedBox(height: 20.h),

                  heading(l10n.filterSortSection),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      for (final sort in PokemonSort.values)
                        ChoiceChip(
                          label: Text(sortName(l10n, sort)),
                          selected: _sort == sort,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _sort = sort),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selection);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.strong,
                foregroundColor: colors.onStrong,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radiusPill),
                ),
                elevation: 0,
              ),
              child: Text(
                count == 0 ? l10n.showAll : l10n.applyCount(count),
                style: textTheme.titleSmall?.copyWith(color: colors.onStrong),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final String type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = listPokemonTypeColor[type]!;
    return Semantics(
      button: true,
      selected: selected,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: selected ? color : color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(radiusPill),
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            context.l10n.typeName(type),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected
                  ? Colors.white
                  : ensureContrast(color, context.colors.surface),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
