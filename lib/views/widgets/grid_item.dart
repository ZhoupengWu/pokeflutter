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
    fetchPokemonData();
    super.initState();
  }

  void fetchPokemonData() async {
    pokemon = await PokemonApi.getPokemonDetails(widget.pokemon.name);
    pokemonColor = listPokemonTypeColor[pokemon?.typesList[0].toLowerCase()];

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? Center(
      child: CircularProgressIndicator(),
    ) : InkWell(
      onTap: () {
        // To implement
      },
      child: Container(
        decoration: BoxDecoration(
          color: pokemonColor,
          borderRadius: BorderRadius.circular(16.r)
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: -20.r,
              right: -11.r,
              child: SvgPicture.asset(
                "assets/pokeball.svg",
                height: 88.r,
                width: 88.r,
                colorFilter: ColorFilter.mode(Colors.white12, BlendMode.srcIn),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _header(context),
                  SizedBox(height: 4.h,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: typeList(pokemon!),
                  ),
                  Container(
                    height: 56.r,
                    width: 56.r,
                    child: Image.network(
                      pokemon!.urlSprite,
                      fit: BoxFit.cover,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> typeList(Pokemon pokemon) {
    List<Widget> typeList = [];

    for (var i = 0; i < pokemon.typesList.length; ++i) {
      if (i >= 1) {
        typeList.add(SizedBox(height: 4.h,));
      }

      typeList.add(Container(
        decoration: BoxDecoration(
          color: gray[500]?.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(24.r)
        ),
        padding: EdgeInsets.only(left: 2.w, top: 2.h, right: 8.w, bottom: 2.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("assets/typesIcons/Pokémon_${pokemon.typesList[i].capitalize()}_Type_Icon.png"),
              height: 15.r,
              width: 15.r,
            ),
            SizedBox(height: 4.w,),
            StyledText(
              style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white),
              textHeight: 16.h,
              text: pokemon.typesList[i].capitalize(),
            )
          ],
        ),
      ));
    }

    return typeList;
  }

  Row _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StyledText(
          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
          text: pokemon?.name.capitalize(),
          textHeight: 16.h,
        ),
        StyledText(
          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
          text: "#${pokemon?.id.toString().padLeft(3, "0")}",
          textHeight: 16.h,
        ),
      ],
    );
  }
}