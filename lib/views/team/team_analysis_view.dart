import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/team_controller.dart';
import '../../core/pokemon_constants.dart';
import '../../core/team_suggestions.dart';
import '../../core/type_chart.dart';
import '../../l10n/l10n_extensions.dart';
import '../../theme/app_colors.dart';
import '../../theme/shapes.dart';
import '../shared/pokemon_image.dart';

/// What the team is weak to and resists, and which types it hits hard.
class TeamAnalysisView extends StatelessWidget {
  const TeamAnalysisView({super.key, required this.controller});

  final TeamController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;
    final failedCount = controller.failed.length;

    if (controller.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(24.r),
        child: Text(
          l10n.teamEmptyHint,
          style: textTheme.bodyMedium?.copyWith(color: colors.subtle),
          textAlign: TextAlign.center,
        ),
      );
    }

    final analysis = controller.analysis;
    final size = analysis.size;

    Widget heading(String title, String hint) => Padding(
      padding: EdgeInsets.only(top: 20.h, bottom: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                color: colors.strong,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            hint,
            style: textTheme.bodySmall?.copyWith(color: colors.subtle),
          ),
        ],
      ),
    );

    Widget group(String label, List<Widget> chips, {String? empty}) => Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(color: colors.muted),
          ),
          SizedBox(height: 6.h),
          if (chips.isEmpty && empty != null)
            Text(
              empty,
              style: textTheme.bodySmall?.copyWith(color: colors.subtle),
            )
          else
            Wrap(spacing: 6.w, runSpacing: 6.h, children: chips),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (failedCount > 0)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: TextButton.icon(
                onPressed: controller.loadDetails,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.teamLoadFailed(failedCount)),
              ),
            ),
          if (size > 0) ...[
            heading(l10n.teamDefence, l10n.teamDefenceHint),
            group(l10n.teamWeakTo, [
              for (final t in analysis.weaknesses)
                _TypeChip(type: t, count: analysis.weakCount[t]!),
            ], empty: l10n.teamNoWeakness),
            group(l10n.teamResists, [
              for (final t in analysis.resistances)
                _TypeChip(type: t, count: analysis.resistCount[t]!),
            ], empty: l10n.teamNoResistance),
            heading(l10n.teamOffence, l10n.teamOffenceHint),
            group(l10n.teamHits, [
              for (final t in TypeChart.types)
                if (analysis.covered.contains(t)) _TypeChip(type: t),
            ], empty: l10n.teamNoCoverage),
            group(l10n.teamMisses, [
              for (final t in analysis.uncovered)
                _TypeChip(type: t, muted: true),
            ], empty: l10n.teamNoGaps),
            if (controller.suggestions.isNotEmpty) ...[
              heading(l10n.teamSuggestions, l10n.teamSuggestionsHint),
              SizedBox(height: 4.h),
              for (final suggestion in controller.suggestions)
                _SuggestionTile(
                  suggestion: suggestion,
                  onAdd: () => controller.add(suggestion.pokemon),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

/// A type pill, with how many members it concerns ("Fire ×3") when given.
class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type, this.count, this.muted = false});

  final String type;
  final int? count;

  /// Drawn as an outline, for the types the team does not cover.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = listPokemonTypeColor[type] ?? context.colors.muted;
    final name = l10n.typeName(type);
    final label = count == null ? name : '$name ×$count';
    final textStyle = Theme.of(context).textTheme.labelMedium;

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: muted ? null : color,
          border: muted ? Border.all(color: color, width: 1.5) : null,
          borderRadius: BorderRadius.circular(radiusPill),
        ),
        child: Text(
          label,
          style: textStyle?.copyWith(
            color: muted ? context.colors.muted : Colors.white,
            fontWeight: count == null ? null : FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// A suggested Pokémon: what it resists of the team's weaknesses and which
/// types it newly hits. Tapping adds it to the team.
class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.suggestion, required this.onAdd});

  final TeamSuggestion suggestion;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final name = context.pokemonName(suggestion.pokemon.name);
    final details = [
      if (suggestion.resists.isNotEmpty)
        l10n.teamSuggestionResists(
          suggestion.resists.map(l10n.typeName).join(', '),
        ),
      if (suggestion.newCoverage.isNotEmpty)
        l10n.teamSuggestionHits(
          suggestion.newCoverage.map(l10n.typeName).join(', '),
        ),
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Semantics(
        button: true,
        label: '${l10n.teamSuggestionAdd(name)}. ${details.join('. ')}',
        excludeSemantics: true,
        onTap: onAdd,
        child: Material(
          color: colors.fill,
          borderRadius: BorderRadius.circular(radiusControl.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(radiusControl.r),
            onTap: onAdd,
            child: Padding(
              padding: EdgeInsets.all(8.r),
              child: Row(
                children: [
                  SizedBox(
                    width: 48.r,
                    height: 48.r,
                    child: PokemonImage(
                      suggestion.pokemon.spriteUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.catching_pokemon,
                        size: 32.r,
                        color: colors.border,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: textTheme.titleSmall?.copyWith(
                            color: colors.strong,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Wrap(
                          spacing: 4.w,
                          runSpacing: 4.h,
                          children: [
                            for (final type in suggestion.types)
                              _TypeChip(type: type),
                          ],
                        ),
                        for (final line in details)
                          Text(
                            line,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.muted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.add_circle_outline_rounded, color: colors.muted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
