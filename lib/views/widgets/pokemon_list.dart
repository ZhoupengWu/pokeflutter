import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/pokemon_list_item.dart';
import '../../views/widgets/grid_item.dart';

class PokemonList extends StatelessWidget {
  final List<PokemonListItem> pokemonList;

  const PokemonList({super.key, required this.pokemonList});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: GridView.builder(
        clipBehavior: Clip.hardEdge,
        itemCount: pokemonList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
          mainAxisExtent: 100.h,
        ),
        itemBuilder: (BuildContext context, int index) {
          final pokemon = pokemonList[index];
          // The key ties each cell's loaded data to its Pokémon, so the cells
          // are not mixed up when search/filters change the list.
          return GridItem(key: ValueKey(pokemon.name), pokemon: pokemon);
        },
      ),
    );
  }
}
