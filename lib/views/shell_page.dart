import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/palette.dart';
import 'homepage.dart';
import 'compare_page.dart';
import 'quiz_page.dart';
import 'favourite_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _currentIndex = 0;

  // Pages are kept alive via IndexedStack — state is preserved on tab switch.
  final List<Widget> _pages = const [
    HomePage(),
    ComparePage(),
    QuizPage(),
    FavouritePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedLabelStyle: Theme.of(context).textTheme.labelMedium,
        unselectedLabelStyle: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: gray[300]),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 24.r),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows_rounded, size: 24.r),
            label: 'Compare',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_rounded, size: 24.r),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded, size: 24.r),
            label: 'Favourite',
          ),
        ],
      ),
    );
  }
}