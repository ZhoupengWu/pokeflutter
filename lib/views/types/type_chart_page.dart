import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/capitalize.dart';
import '../../core/type_chart.dart';
import '../../l10n/l10n_extensions.dart';
import '../../theme/app_colors.dart';
import '../../theme/responsive.dart';

/// The whole 18 × 18 type chart: rows are the attacking type, columns the
/// defending one. The grid is wider than a phone, so it pans and zooms.
class TypeChartPage extends StatelessWidget {
  const TypeChartPage({super.key});

  /// Colour of a cell for a multiplier (2, 0.5 or 0); neutral cells are blank.
  static Color? cellColor(double multiplier) => switch (multiplier) {
    2 => successGreen,
    0.5 => const Color(0xFFE8943A),
    0 => const Color(0xFF3A3F4B),
    _ => null,
  };

  static String cellLabel(double multiplier) => switch (multiplier) {
    2 => '2',
    0.5 => '½',
    0 => '0',
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.typeChartTitle)),
      body: SafeArea(
        child: ContentWidth(
          maxWidth: 1100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 8.h),
                child: Text(
                  l10n.typeChartHint,
                  style: textTheme.bodySmall?.copyWith(
                    color: context.colors.muted,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Wrap(
                  spacing: 16.w,
                  runSpacing: 4.h,
                  children: [
                    for (final value in const [2.0, 0.5, 0.0])
                      _LegendItem(
                        multiplier: value,
                        label: switch (value) {
                          2 => l10n.typeChartSuper,
                          0.5 => l10n.typeChartNotVery,
                          _ => l10n.typeChartNoEffect,
                        },
                      ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              const Expanded(child: _ChartTable()),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.multiplier, required this.label});

  final double multiplier;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 20.r,
        height: 20.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: TypeChartPage.cellColor(multiplier),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          TypeChartPage.cellLabel(multiplier),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
      SizedBox(width: 6.w),
      Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: context.colors.muted),
      ),
    ],
  );
}

class _ChartTable extends StatelessWidget {
  const _ChartTable();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cell = 30.r;
    const types = TypeChart.types;

    String cellLabel(double v) => TypeChartPage.cellLabel(v);

    Widget header(String type) => SizedBox(
      width: cell,
      height: cell,
      child: Padding(
        padding: EdgeInsets.all(3.r),
        child: Semantics(
          label: l10n.typeName(type),
          child: Image.asset(
            'assets/typesIcons/Pokémon_${type.capitalize()}_Type_Icon.png',
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );

    Widget body(String attacker, String defender) {
      final value = TypeChart.multiplier(attacker, defender);
      final color = TypeChartPage.cellColor(value);
      final box = Container(
        width: cell,
        height: cell,
        margin: EdgeInsets.all(1.r),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color ?? context.colors.fill,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          TypeChartPage.cellLabel(value),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      );
      // Blank cells are not announced one by one; the rest say what they are.
      if (color == null) return ExcludeSemantics(child: box);
      return Semantics(
        label: l10n.typeChartCellSemantics(
          l10n.typeName(attacker),
          l10n.typeName(defender),
          '${cellLabel(value)}×',
        ),
        excludeSemantics: true,
        child: box,
      );
    }

    return InteractiveViewer(
      constrained: false,
      minScale: 0.6,
      maxScale: 2.5,
      boundaryMargin: EdgeInsets.all(24.r),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: Table(
          defaultColumnWidth: FixedColumnWidth(cell + 2.r),
          children: [
            TableRow(
              children: [const SizedBox(), for (final t in types) header(t)],
            ),
            for (final attacker in types)
              TableRow(
                children: [
                  header(attacker),
                  for (final defender in types) body(attacker, defender),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
