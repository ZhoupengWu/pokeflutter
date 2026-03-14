import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../model/pokemon_list_item.dart';
import '../../model/pokemon.dart';
import '../../utils/pokemon_api.dart';
import '../../utils/pokemon_costants.dart';

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
            )
          ],
        ),
      ),
    );
  }
}