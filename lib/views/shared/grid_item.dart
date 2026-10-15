import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../model/pokemon_list_item.dart';
import '../../core/capitalize.dart';
import '../../theme/app_colors.dart';
import '../../core/pokemon_constants.dart';
import '../../data/pokemon_type_index.dart';
import '../detail/pokemon_detail_page.dart';
import 'styled_text.dart';

/// Card shown in the Pokédex and favourites grids.
///
/// Everything it displays comes from the bundled list (name, id, sprite URL)
/// and the [PokemonTypeIndex] (types, colour), so building a cell never
/// triggers a network call to the Pokémon API. Until the index is available
/// the cell is neutral grey, without type badges.
class GridItem extends StatelessWidget {
  final PokemonListItem pokemon;

  /// Names the screen the cell is on (`home`, `favourites`). When set, the
  /// sprite flies into the detail page; the scope keeps the tags unique
  /// because every tab stays alive and may show the same Pokémon.
  final String? heroScope;

  const GridItem({super.key, required this.pokemon, this.heroScope});

  Object? get _heroTag =>
      heroScope == null ? null : '$heroScope-${pokemon.name}';

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PokemonDetailPage(pokemon: pokemon, heroTag: _heroTag),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final index = context.read<PokemonTypeIndex>();
    return ListenableBuilder(
      listenable: index,
      builder: (context, _) {
        final types = index.typesOf(pokemon.name) ?? [];
        final color =
            listPokemonTypeColor[types.firstOrNull?.toLowerCase()] ??
            context.colors.subtle;
        return _card(context, types, color);
      },
    );
  }

  Widget _card(BuildContext context, List<String> types, Color color) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: types.isEmpty
          ? context.l10n.pokemonSemantics(pokemon.name.capitalize(), pokemon.id)
          : context.l10n.pokemonSemanticsTyped(
              pokemon.name.capitalize(),
              pokemon.id,
              context.l10n.typeList(types),
            ),
      excludeSemantics: true,
      onTap: () => _navigateToDetail(context),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => _navigateToDetail(context),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: -20.r,
                right: -11.r,
                child: SvgPicture.asset(
                  'assets/pokeball.svg',
                  height: 88.r,
                  width: 88.r,
                  colorFilter: const ColorFilter.mode(
                    Colors.white12,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(textTheme),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _typeList(context, types),
                          ),
                          SizedBox(height: 48.r, width: 48.r, child: _sprite()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sprite() {
    final image = Image.network(
      pokemon.spriteUrl,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) =>
          Icon(Icons.catching_pokemon, size: 32.r, color: Colors.white38),
    );
    final tag = _heroTag;
    return tag == null ? image : Hero(tag: tag, child: image);
  }

  List<Widget> _typeList(BuildContext context, List<String> types) {
    final widgets = <Widget>[];
    for (var i = 0; i < types.length; i++) {
      if (i >= 1) widgets.add(SizedBox(height: 4.h));
      widgets.add(
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24.r),
          ),
          padding: EdgeInsets.only(
            left: 2.w,
            top: 2.h,
            right: 8.w,
            bottom: 2.h,
          ),
          child: Row(
            children: [
              Image(
                image: AssetImage(
                  'assets/typesIcons/Pokémon_${types[i].capitalize()}_Type_Icon.png',
                ),
                height: 15.r,
                width: 15.r,
              ),
              SizedBox(width: 4.w),
              StyledText(
                style: Theme.of(
                  context,
                ).textTheme.labelSmall!.copyWith(color: Colors.white),
                textHeight: 16.h,
                text: context.l10n.typeName(types[i]),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  Row _header(TextTheme textTheme) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: StyledText(
          style: textTheme.bodySmall!.copyWith(color: Colors.white),
          text: pokemon.name.capitalize(),
          textHeight: 16.h,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      StyledText(
        style: textTheme.bodySmall!.copyWith(color: Colors.white),
        text: '#${pokemon.id.toString().padLeft(3, '0')}',
        textHeight: 16.h,
      ),
    ],
  );
}
