import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/pokemon.dart';
import '../../utils/app_colors.dart';
import '../../utils/capitalize.dart';
import '../../utils/contrast.dart';
import '../../utils/pokemon_constants.dart';

/// Base stats of two Pokémon side by side: A's bar grows leftwards, B's
/// rightwards, and the higher value of each pair is highlighted.
class StatsComparison extends StatelessWidget {
  const StatsComparison({super.key, required this.a, required this.b});

  final Pokemon a;
  final Pokemon b;

  /// Highest base stat, the full-bar value.
  static const _maxStat = 255.0;

  /// Highest possible total used to scale the Total row (Eternatus-like).
  static const _maxTotal = 1125.0;

  /// Green for the winner of a pair, red for the loser; ties are both green.
  static Color _resultColor(int mine, int other) =>
      mine >= other ? successGreen : Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    Color nameColor(Pokemon p) => ensureContrast(
      listPokemonTypeColor[p.typesList.first.toLowerCase()] ?? colors.muted,
      colors.surface,
    );

    final rows = <_Row>[
      for (final statA in a.stats)
        _Row(
          label: l10n.statLabel(statA.name),
          a: statA.value,
          b: b.stats
              .firstWhere(
                (s) => s.name == statA.name,
                orElse: () => PokemonStat(name: statA.name, value: 0),
              )
              .value,
          max: _maxStat,
        ),
      _Row(
        label: l10n.compareTotal,
        a: a.stats.fold(0, (sum, s) => sum + s.value),
        b: b.stats.fold(0, (sum, s) => sum + s.value),
        max: _maxTotal,
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                a.name.capitalize(),
                style: textTheme.labelMedium?.copyWith(
                  color: nameColor(a),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 48.w),
            Expanded(
              child: Text(
                b.name.capitalize(),
                style: textTheme.labelMedium?.copyWith(
                  color: nameColor(b),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        for (final row in rows) _StatRow(row: row, isTotal: row == rows.last),
        SizedBox(height: 24.h),
      ],
    );
  }
}

class _Row {
  const _Row({
    required this.label,
    required this.a,
    required this.b,
    required this.max,
  });

  final String label;
  final int a;
  final int b;
  final double max;
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.row, required this.isTotal});

  final _Row row;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;
    final colorA = StatsComparison._resultColor(row.a, row.b);
    final colorB = StatsComparison._resultColor(row.b, row.a);
    final valueStyle = (isTotal ? textTheme.bodyMedium : textTheme.bodySmall)
        ?.copyWith(fontWeight: isTotal ? FontWeight.w700 : null);

    Widget bar(int value, Color color) => ClipRRect(
      borderRadius: BorderRadius.circular(4.r),
      child: LinearProgressIndicator(
        value: value / row.max,
        minHeight: 8.h,
        backgroundColor: colors.fill,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );

    return Semantics(
      label: context.l10n.compareStatSemantics(row.label, row.a, row.b),
      excludeSemantics: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.h, top: isTotal ? 6.h : 0),
        child: Row(
          children: [
            // Bar A (grows right-to-left)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    row.a.toString(),
                    style: valueStyle?.copyWith(color: colorA),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: 2,
                      child: bar(row.a, colorA),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              width: 48.w,
              child: Text(
                row.label,
                style: textTheme.labelSmall?.copyWith(
                  color: colors.muted,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Bar B (grows left-to-right)
            Expanded(
              child: Row(
                children: [
                  Expanded(child: bar(row.b, colorB)),
                  SizedBox(width: 4.w),
                  Text(
                    row.b.toString(),
                    style: valueStyle?.copyWith(color: colorB),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
