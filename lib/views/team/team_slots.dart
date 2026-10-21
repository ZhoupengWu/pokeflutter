import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/team_controller.dart';
import '../../core/pokemon_constants.dart';
import '../../data/team_manager.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/pokemon.dart';
import '../../model/pokemon_list_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/responsive.dart';
import '../detail/pokemon_detail_page.dart';
import '../shared/pokemon_image.dart';

/// The six slots of the team: a card per member, empty slots to add one.
class TeamSlots extends StatelessWidget {
  const TeamSlots({super.key, required this.controller, required this.onAdd});

  final TeamController controller;

  /// Opens the picker to fill an empty slot.
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final members = controller.members;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 0.8 / scaledByText(context, 1, share: 0.6),
        children: [
          for (var i = 0; i < TeamManager.maxSize; i++)
            if (i < members.length)
              _MemberCard(
                item: members[i],
                pokemon: controller.details[members[i].name],
                failed: controller.failed.contains(members[i].name),
                onRemove: () => controller.remove(members[i]),
              )
            else
              _EmptySlot(number: i + 1, onTap: onAdd),
        ],
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.number, required this.onTap});

  final int number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Semantics(
      button: true,
      label: l10n.teamSlotEmptySemantics(number),
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: colors.fill,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 28.r,
                  color: colors.subtle,
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.teamSlotEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: colors.subtle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.item,
    required this.pokemon,
    required this.failed,
    required this.onRemove,
  });

  final PokemonListItem item;

  /// Null until the details have loaded.
  final Pokemon? pokemon;
  final bool failed;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final name = context.pokemonName(item.name);
    final types = pokemon?.typesList ?? const <String>[];
    final color =
        listPokemonTypeColor[types.firstOrNull] ??
        (failed ? colors.border : colors.fill);

    void open() => Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => PokemonDetailPage(pokemon: item)),
    );

    return Semantics(
      button: true,
      label: types.isEmpty ? name : '$name, ${l10n.typeList(types)}',
      excludeSemantics: true,
      onTap: open,
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.teamRemove(name)): onRemove,
      },
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: open,
          child: Stack(
            children: [
              // Fills the card so the column is centred in it (a Stack would
              // otherwise put the narrow column at the top left).
              SizedBox.expand(
                child: Padding(
                  padding: EdgeInsets.all(8.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      PokemonImage(
                        item.spriteUrl,
                        width: 56.r,
                        height: 56.r,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.catching_pokemon,
                          size: 40.r,
                          color: Colors.white38,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        name,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: types.isEmpty
                                  ? colors.strong
                                  : Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: 2.h),
                      for (final type in types)
                        Text(
                          l10n.typeName(type),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.white70),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  tooltip: l10n.teamRemove(name),
                  visualDensity: VisualDensity.compact,
                  iconSize: 18.r,
                  color: types.isEmpty ? colors.muted : Colors.white,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onRemove,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
