import 'package:flutter/material.dart';
import '../shared/pokemon_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/pokemon.dart';
import '../../theme/app_colors.dart';
import '../../model/pokemon_list_item.dart';
import '../../data/favourites_manager.dart';

/// Top of the detail page, on the type-coloured background: back button,
/// name, favourite toggle, Pokédex number, type chips and the artwork.
class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.pokemon,
    required this.favouriteItem,
    this.heroTag,
  });

  final Pokemon pokemon;

  /// The list entry that is added to / removed from the favourites.
  final PokemonListItem favouriteItem;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final favourites = context.read<FavouritesManager>();

    Widget artwork = PokemonImage(
      pokemon.urlImage,
      height: 180.r,
      width: 180.r,
      fit: BoxFit.contain,
      semanticLabel: context.pokemonName(pokemon.name),
      errorBuilder: (_, _, _) => Icon(
        Icons.image_not_supported_rounded,
        size: 120.r,
        color: Colors.white38,
      ),
    );
    if (heroTag != null) artwork = Hero(tag: heroTag!, child: artwork);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          child: Row(
            children: [
              IconButton(
                tooltip: l10n.back,
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                // After following evolutions the stack can be deep: this arrow
                // goes straight back to the tabs, while the system back button
                // still steps back one Pokémon at a time.
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
              Expanded(
                child: Text(
                  context.pokemonName(pokemon.name),
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: favourites.notifier,
                builder: (_, _, _) {
                  final isFav = favourites.isFavourite(favouriteItem.name);
                  return IconButton(
                    tooltip: isFav
                        ? l10n.removeFromFavourites
                        : l10n.addToFavourites,
                    // A red heart disappears on a red Pokémon: a favourite sits
                    // on a white disc, which reads on every type colour.
                    style: isFav
                        ? IconButton.styleFrom(backgroundColor: Colors.white)
                        : null,
                    icon: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav ? dangerRed : Colors.white,
                    ),
                    onPressed: () => favourites.toggle(favouriteItem),
                  );
                },
              ),
              Text(
                '#${pokemon.id.toString().padLeft(3, '0')}',
                style: textTheme.titleMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 32.w, bottom: 8.h),
          child: Row(
            children: [
              for (final type in pokemon.typesList) _TypeChip(type: type),
            ],
          ),
        ),
        Center(child: artwork),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        context.l10n.typeName(type),
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: Colors.white),
      ),
    );
  }
}
