import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/pokemon.dart';
import '../../model/pokemon_move.dart';
import '../../theme/app_colors.dart';
import '../../theme/shapes.dart';
import 'about_sections.dart';

/// The moves a Pokémon learns, by way of learning (level up, TM/HM, egg,
/// tutor), from the newest games it appears in. Move names are PokéAPI's.
class MovesSection extends StatefulWidget {
  const MovesSection({super.key, required this.pokemon, required this.accent});

  final Pokemon pokemon;
  final Color accent;

  /// Moves shown before "Show all".
  static const collapsedCount = 18;

  @override
  State<MovesSection> createState() => _MovesSectionState();
}

class _MovesSectionState extends State<MovesSection> {
  MoveMethod? _selected;
  bool _showAll = false;

  List<PokemonMove> _of(MoveMethod method) {
    final moves = [
      for (final m in widget.pokemon.moves ?? const <PokemonMove>[])
        if (m.method == method) m,
    ];
    moves.sort((a, b) {
      final byLevel = a.level.compareTo(b.level);
      return byLevel != 0 ? byLevel : a.name.compareTo(b.name);
    });
    return moves;
  }

  String _label(MoveMethod method) {
    final l10n = context.l10n;
    return switch (method) {
      MoveMethod.levelUp => l10n.movesLevelUp,
      MoveMethod.machine => l10n.movesMachine,
      MoveMethod.egg => l10n.movesEgg,
      MoveMethod.tutor => l10n.movesTutor,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final available = [
      for (final method in MoveMethod.values)
        if (_of(method).isNotEmpty) method,
    ];
    if (available.isEmpty) return const SizedBox.shrink();
    final selected = available.contains(_selected)
        ? _selected!
        : available.first;
    final moves = _of(selected);
    final shown = _showAll || moves.length <= MovesSection.collapsedCount
        ? moves
        : moves.take(MovesSection.collapsedCount).toList();
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(l10n.movesTitle, accent: widget.accent),
        SizedBox(height: 2.h),
        Text(
          l10n.movesHint,
          style: textTheme.bodySmall?.copyWith(color: context.colors.subtle),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 6.h,
          children: [
            for (final method in available)
              _MethodChip(
                label: '${_label(method)} · ${_of(method).length}',
                selected: method == selected,
                accent: widget.accent,
                onTap: () => setState(() {
                  _selected = method;
                  _showAll = false;
                }),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: [for (final move in shown) _MoveChip(move: move)],
        ),
        if (moves.length > shown.length)
          TextButton(
            onPressed: () => setState(() => _showAll = true),
            style: TextButton.styleFrom(
              foregroundColor: widget.accent,
              padding: EdgeInsets.zero,
            ),
            child: Text(l10n.movesShowAll(moves.length)),
          ),
      ],
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radiusPill);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: selected ? accent : accent.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: shape,
          side: BorderSide(color: accent.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          borderRadius: shape,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected ? context.colors.surface : accent,
                fontWeight: selected ? FontWeight.w700 : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoveChip extends StatelessWidget {
  const _MoveChip({required this.move});

  final PokemonMove move;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final name = titleCaseId(move.name);
    final level = move.method == MoveMethod.levelUp
        ? context.l10n.evolutionLevel(move.level)
        : null;
    return Semantics(
      label: level == null ? name : '$level, $name',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: colors.fill,
          borderRadius: BorderRadius.circular(radiusControl.r),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              if (level != null)
                TextSpan(
                  text: '$level  ',
                  style: TextStyle(
                    color: colors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              TextSpan(text: name),
            ],
          ),
          style: textTheme.bodySmall?.copyWith(color: colors.strong),
        ),
      ),
    );
  }
}
