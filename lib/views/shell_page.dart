import 'package:flutter/material.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/responsive.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import 'home/home_page.dart';
import 'compare/compare_page.dart';
import 'quiz/quiz_page.dart';
import 'favourites/favourite_page.dart';
import 'team/team_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _currentIndex = 0;

  // Tabs are built the first time they are shown, then kept alive by the
  // IndexedStack so their state survives a tab switch. Quiz, Compare and
  // Favourites cost nothing until the user opens them.
  final Set<int> _visited = {0};

  final List<Widget> _pages = const [
    HomePage(),
    ComparePage(),
    QuizPage(),
    TeamPage(),
    FavouritePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ContentWidth(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // IndexedStack keeps hidden tabs running; switch their tickers off
            // so animations (and the quiz countdown) wait until they are shown.
            for (var i = 0; i < _pages.length; i++)
              if (_visited.contains(i))
                TickerMode(enabled: i == _currentIndex, child: _pages[i])
              else
                const SizedBox.shrink(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          _currentIndex = index;
          _visited.add(index);
        }),
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
            icon: Icon(Icons.groups_rounded, size: 24.r),
            label: context.l10n.navTeam,
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
