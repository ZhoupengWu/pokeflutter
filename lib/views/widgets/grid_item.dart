import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../model/pokemon_list_item.dart';
import '../../model/pokemon.dart';
import '../../utils/pokemon_api.dart';
import '../../utils/pokemon_costants.dart';
import '../../utils/capitalize.dart';
import '../../utils/palette.dart';
import '../../views/widgets/styled_text.dart';
import '../../views/pokemon_detail_page.dart';

class GridItem extends StatefulWidget {
  final PokemonListItem pokemon;

  const GridItem({super.key, required this.pokemon});

  @override
  State<GridItem> createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  Pokemon? pokemon;
  bool _isLoading = true;
  Color? pokemonColor;

  @override
  void initState() {
    super.initState();
    _fetchPokemonData();
  }

  void _fetchPokemonData() async {
    try {
      final result = await PokemonApi.getPokemonDetails(widget.pokemon.name);
      final color = listPokemonTypeColor[result?.typesList[0].toLowerCase()];
      if (!mounted) return;
      setState(() {
        pokemon = result;
        pokemonColor = color;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _navigateToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PokemonDetailPage(pokemon: widget.pokemon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: gray[100],
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (pokemon == null) {
      return Container(
        decoration: BoxDecoration(
          color: gray[100],
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(child: Icon(Icons.error_outline, color: gray[300])),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: _navigateToDetail,
      child: Container(
        decoration: BoxDecoration(
          color: pokemonColor,
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
                    _header(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _typeList(pokemon!),
                        ),
                        SizedBox(
                          height: 48.r,
                          width: 48.r,
                          child: Image.network(
                            pokemon!.urlSprite,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.catching_pokemon,
                              size: 32.r,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _typeList(Pokemon pokemon) {
    final widgets = <Widget>[];
    for (var i = 0; i < pokemon.typesList.length; i++) {
      if (i >= 1) widgets.add(SizedBox(height: 4.h));
      widgets.add(
        Container(
          decoration: BoxDecoration(
            color: gray[500]?.withValues(alpha: 0.2),
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
                  'assets/typesIcons/Pokémon_${pokemon.typesList[i].capitalize()}_Type_Icon.png',
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
                text: pokemon.typesList[i].capitalize(),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  Row _header(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      StyledText(
        style: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(color: Colors.white),
        text: pokemon?.name.capitalize(),
        textHeight: 16.h,
      ),
      StyledText(
        style: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(color: Colors.white),
        text: '#${pokemon?.id.toString().padLeft(3, '0')}',
        textHeight: 16.h,
      ),
    ],
  );
}