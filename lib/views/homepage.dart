import 'package:flutter/material.dart';
import 'package:pokeflutter/utils/palette.dart';
import 'widgets/random_floating_button.dart';
import 'widgets/bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context);

    return Scaffold(
      floatingActionButton: const RandomFloatingButton(),
      bottomNavigationBar: const BottomNavBar(),
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 76, left: 24, right: 24),
            child: Text("Pokédex", style: textTheme.textTheme.displaySmall,)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text("Use the advanced search to find Pokémon by type, weakness, ability and more!", style: textTheme.textTheme.bodyLarge?.copyWith(color: gray[400], height: 24/16)))
        ],
      ),
    );
  }
}