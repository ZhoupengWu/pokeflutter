import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.compare_arrows_rounded), label: "Compare"),
      BottomNavigationBarItem(icon: Icon(Icons.quiz_rounded), label: "Quiz"),
      BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: "Favourite"),
    ]);
  }
}