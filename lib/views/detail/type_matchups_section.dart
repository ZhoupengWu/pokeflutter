import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/pokemon.dart';
import '../../theme/app_colors.dart';
import '../../core/pokemon_constants.dart';
import '../../core/type_chart.dart';
import '../types/type_chart_page.dart';
import 'about_sections.dart';
import '../../theme/shapes.dart';

/// How much damage each type of move deals to this Pokémon, grouped into
/// weaknesses, resistances and immunities. Computed from the static
/// [TypeChart], so it needs no network.
class TypeMatchupsSection extends StatelessWidget {
  const TypeMatchupsSection({
    super.key,
    required this.pokemon,
    required this.accent,
  });

  final Pokemon pokemon;
  final Color accent;

  /// Shown multipliers, most dangerous first, grouped by heading.
  static const _weak = [4.0, 2.0];
  static const _resists = [0.5, 0.25];
  static const _immune = [0.0];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = TypeChart.defensiveProfile(pokemon.typesList);

    List<_Matchup> matchups(List<double> values) => [
      for (final value in values)
        for (final type in TypeChart.typesWithMultiplier(profile, value))
          _Matchup(type, value),
    ];

    final groups = [
      (l10n.matchupsWeak, matchups(_weak)),
      (l10n.matchupsResists, matchups(_resists)),
      (l10n.matchupsImmune, matchups(_immune)),
    ].where((group) => group.$2.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(l10n.matchupsTitle, accent: accent),
        SizedBox(height: 2.h),
        Text(
          l10n.matchupsHint,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: context.colors.subtle),
        ),
        for (final (heading, items) in groups) ...[
          SizedBox(height: 12.h),
          Text(
            heading,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: context.colors.muted),
          ),
          SizedBox(height: 6.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [for (final item in items) _MatchupChip(matchup: item)],
          ),
        ],
        SizedBox(height: 8.h),
        TextButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const TypeChartPage()),
          ),
          style: TextButton.styleFrom(
            foregroundColor: accent,
            padding: EdgeInsets.zero,
          ),
          icon: const Icon(Icons.grid_on_rounded),
          label: Text(l10n.typeChartOpen),
        ),
      ],
    );
  }
}

class _Matchup {
  const _Matchup(this.type, this.multiplier);

  final String type;
  final double multiplier;

  /// "4×", "½×", "0×"…
  String get label => switch (multiplier) {
    4 => '4×',
    2 => '2×',
    0.5 => '½×',
    0.25 => '¼×',
    0 => '0×',
    _ => '$multiplier×',
  };
}

class _MatchupChip extends StatelessWidget {
  const _MatchupChip({required this.matchup});

  final _Matchup matchup;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = listPokemonTypeColor[matchup.type] ?? context.colors.muted;
    final textStyle = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(color: Colors.white);

    return Semantics(
      label: l10n.matchupSemantics(l10n.typeName(matchup.type), matchup.label),
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.typeName(matchup.type), style: textStyle),
            SizedBox(width: 6.w),
            Text(
              matchup.label,
              style: textStyle?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
