import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/pokemon_list_item.dart';
import '../../views/widgets/grid_item.dart';

class PokemonList extends StatelessWidget {
  final List<PokemonListItem> pokemonList;
  final Set<String> activeTypeFilters;

  const PokemonList({
    super.key,
    required this.pokemonList,
    this.activeTypeFilters = const {},
  });

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
          return GridItem(
            pokemon: pokemonList[index],
            activeTypeFilters: activeTypeFilters,
          );
        },
      ),
    );
  }
}