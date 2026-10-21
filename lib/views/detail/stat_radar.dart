import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/pokemon.dart';
import '../../theme/app_colors.dart';

/// The base stats as a radar (spider) chart: one axis per stat, the filled
/// shape is the Pokémon. The outer ring is the highest stat, but never less
/// than [minScale], so weak Pokémon do not look maxed out.
class StatRadar extends StatelessWidget {
  const StatRadar({super.key, required this.stats, required this.accent});

  final List<PokemonStat> stats;
  final Color accent;

  /// Smallest value the outer ring stands for.
  static const minScale = 120.0;

  /// The value of the outer ring for [stats]: the highest stat, rounded up to
  /// the next 10, and at least [minScale].
  static double scaleFor(List<PokemonStat> stats) {
    final highest = stats.fold<int>(0, (m, s) => math.max(m, s.value));
    return math.max(minScale, (highest / 10).ceil() * 10.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final labels = [for (final s in stats) l10n.statLabel(s.name)];
    final summary = [
      for (final s in stats) '${l10n.statLabel(s.name)}: ${s.value}',
    ].join(', ');

    return Semantics(
      label: summary,
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 1.25,
        child: CustomPaint(
          painter: _RadarPainter(
            values: [for (final s in stats) s.value.toDouble()],
            labels: labels,
            scale: scaleFor(stats),
            accent: accent,
            gridColor: colors.border,
            labelStyle: textTheme.bodySmall!.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
            ),
            valueStyle: textTheme.bodySmall!.copyWith(
              color: colors.strong,
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.values,
    required this.labels,
    required this.scale,
    required this.accent,
    required this.gridColor,
    required this.labelStyle,
    required this.valueStyle,
  });

  final List<double> values;
  final List<String> labels;
  final double scale;
  final Color accent;
  final Color gridColor;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  /// The point of axis [i] at [fraction] of the radius, starting at the top
  /// and going clockwise.
  Offset _point(Offset centre, double radius, int i, double fraction) {
    final angle = -math.pi / 2 + 2 * math.pi * i / values.length;
    return centre +
        Offset(math.cos(angle), math.sin(angle)) * radius * fraction;
  }

  Path _polygon(Offset centre, double radius, double Function(int) fraction) {
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final p = _point(centre, radius, i, fraction(i));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 3) return;
    final centre = size.center(Offset.zero);
    // Leave room around the shape for the labels.
    final radius = math.min(size.width * 0.30, size.height * 0.36);

    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = gridColor;
    for (final ring in [0.25, 0.5, 0.75, 1.0]) {
      canvas.drawPath(_polygon(centre, radius, (_) => ring), grid);
    }
    for (var i = 0; i < values.length; i++) {
      canvas.drawLine(centre, _point(centre, radius, i, 1), grid);
    }

    double fractionOf(int i) => (values[i] / scale).clamp(0.0, 1.0);
    final shape = _polygon(centre, radius, fractionOf);
    canvas.drawPath(shape, Paint()..color = accent.withValues(alpha: 0.28));
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = accent,
    );
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(
        _point(centre, radius, i, fractionOf(i)),
        3,
        Paint()..color = accent,
      );
    }

    // Name and value beside each tip.
    for (var i = 0; i < values.length; i++) {
      final text = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(text: '${labels[i]}\n', style: labelStyle),
            TextSpan(text: values[i].round().toString(), style: valueStyle),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      final tip = _point(centre, radius, i, 1.0);
      final away = (tip - centre) / radius;
      final anchor =
          tip +
          Offset(
            away.dx * (text.width / 2 + 6),
            away.dy * (text.height / 2 + 4),
          );
      text.paint(canvas, anchor - Offset(text.width / 2, text.height / 2));
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.values != values ||
      old.scale != scale ||
      old.accent != accent ||
      old.gridColor != gridColor ||
      old.labelStyle != labelStyle;
}
