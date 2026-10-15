import 'package:flutter/material.dart';
import '../l10n/l10n_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import 'home/home_page.dart';
import 'compare/compare_page.dart';
import 'quiz/quiz_page.dart';
import 'favourites/favourite_page.dart';

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
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // IndexedStack keeps hidden tabs running; switch their tickers off
          // so animations (and the quiz countdown) wait until they are shown.
          for (var i = 0; i < _pages.length; i++)
            TickerMode(enabled: i == _currentIndex, child: _pages[i]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedLabelStyle: Theme.of(context).textTheme.labelMedium,
        unselectedLabelStyle: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: context.colors.subtle),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 24.r),
            label: context.l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows_rounded, size: 24.r),
            label: context.l10n.navCompare,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_rounded, size: 24.r),
            label: context.l10n.navQuiz,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded, size: 24.r),
            label: context.l10n.navFavourites,
          ),
        ],
      ),
    );
  }
}
