import 'package:flutter/material.dart';
import '../shared/pokemon_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/pokemon_detail_controller.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/evolution.dart';
import '../../model/pokemon_list_item.dart';
import '../../theme/app_colors.dart';
import '../../core/capitalize.dart';
import 'about_sections.dart';
import 'pokemon_detail_page.dart';

/// The evolution family of the Pokémon: stages grouped in columns from the
/// first form to the last, branches stacked, each stage tappable.
class EvolutionSection extends StatelessWidget {
  const EvolutionSection({
    super.key,
    required this.controller,
    required this.accent,
  });

  final PokemonDetailController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final textStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: colors.subtle);

    final Widget body;
    switch (controller.evolutionStatus) {
      case LoadStatus.loading:
        body = Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Center(
            child: SizedBox.square(
              dimension: 24.r,
              child: CircularProgressIndicator(strokeWidth: 2, color: accent),
            ),
          ),
        );
      case LoadStatus.failed:
        body = Row(
          children: [
            Expanded(child: Text(l10n.evolutionLoadFailed, style: textStyle)),
            TextButton(
              onPressed: controller.loadEvolution,
              child: Text(l10n.retry),
            ),
          ],
        );
      case LoadStatus.loaded:
        final chain = controller.evolution!;
        body = chain.isSingleStage
            ? Text(l10n.evolutionNone, style: textStyle)
            : _EvolutionChainView(
                chain: chain,
                currentSpecies: controller.pokemon!.speciesName,
                accent: accent,
                itemFor: controller.itemForSpecies,
              );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(l10n.evolutionTitle, accent: accent),
        SizedBox(height: 8.h),
        body,
      ],
    );
  }
}

class _EvolutionChainView extends StatelessWidget {
  const _EvolutionChainView({
    required this.chain,
    required this.currentSpecies,
    required this.accent,
    required this.itemFor,
  });

  final EvolutionChain chain;
  final String currentSpecies;
  final Color accent;
  final PokemonListItem? Function(int speciesId) itemFor;

  @override
  Widget build(BuildContext context) {
    final levels = chain.levels;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < levels.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ExcludeSemantics(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18.r,
                    color: context.colors.subtle,
                  ),
                ),
              ),
            // Many branches (Eevee) would make a very tall column: wrap them.
            if (levels[i].length > 3)
              SizedBox(
                width: 3 * 84.w,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [for (final s in levels[i]) _tile(context, s)],
                ),
              )
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [for (final s in levels[i]) _tile(context, s)],
              ),
          ],
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, EvolutionStage stage) => _StageTile(
    stage: stage,
    isCurrent: stage.name == currentSpecies,
    accent: accent,
    target: itemFor(stage.id),
  );
}

class _StageTile extends StatelessWidget {
  const _StageTile({
    required this.stage,
    required this.isCurrent,
    required this.accent,
    required this.target,
  });

  final EvolutionStage stage;
  final bool isCurrent;
  final Color accent;

  /// Where tapping leads; null when the Pokémon is not in the bundled list.
  final PokemonListItem? target;

  void _open(BuildContext context) {
    final item = target;
    if (item == null || isCurrent) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => PokemonDetailPage(pokemon: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final requirement = l10n.evolutionRequirementLabel(stage.requirement);
    final name = stage.name.capitalize();

    var semantics = requirement.isEmpty
        ? l10n.evolutionStageSemantics(name, stage.id)
        : l10n.evolutionStageSemanticsWith(name, stage.id, requirement);
    if (isCurrent) semantics = '$semantics, ${l10n.evolutionCurrent}';
    final tappable = target != null && !isCurrent;

    return Semantics(
      button: tappable,
      selected: isCurrent,
      label: semantics,
      excludeSemantics: true,
      onTap: tappable ? () => _open(context) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: tappable ? () => _open(context) : null,
        child: Container(
          width: 80.w,
          margin: EdgeInsets.all(2.r),
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: isCurrent ? accent.withValues(alpha: 0.12) : null,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isCurrent ? accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PokemonImage(
                PokemonListItem.spriteUrlFor(stage.id),
                width: 56.r,
                height: 56.r,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.catching_pokemon,
                  size: 40.r,
                  color: colors.border,
                ),
              ),
              Text(
                name,
                style: textTheme.labelMedium?.copyWith(
                  color: colors.strong,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (requirement.isNotEmpty)
                Text(
                  requirement,
                  style: textTheme.labelSmall?.copyWith(color: colors.muted),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
