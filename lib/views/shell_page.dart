import 'package:flutter/material.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/responsive.dart';
import 'home/home_page.dart';
import 'compare/compare_page.dart';
import 'quiz/quiz_page.dart';
import 'favourites/favourite_page.dart';
import 'shared/floating_tab_bar.dart';
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
    final l10n = context.l10n;
    return Scaffold(
      // The tab bar floats over the content: the pages run underneath it and
      // read its height from MediaQuery.padding.bottom.
      extendBody: true,
      // The keyboard slides over the tab bar instead of pushing it up.
      resizeToAvoidBottomInset: false,
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
      bottomNavigationBar: FloatingTabBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          _currentIndex = index;
          _visited.add(index);
        }),
        items: [
          FloatingTabItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: l10n.navHome,
          ),
          FloatingTabItem(
            icon: Icons.compare_arrows_rounded,
            selectedIcon: Icons.compare_arrows_rounded,
            label: l10n.navCompare,
          ),
          FloatingTabItem(
            icon: Icons.quiz_outlined,
            selectedIcon: Icons.quiz_rounded,
            label: l10n.navQuiz,
          ),
          FloatingTabItem(
            icon: Icons.groups_outlined,
            selectedIcon: Icons.groups_rounded,
            label: l10n.navTeam,
          ),
          FloatingTabItem(
            icon: Icons.favorite_border_rounded,
            selectedIcon: Icons.favorite_rounded,
            label: l10n.navFavourites,
          ),
        ],
      ),
    );
  }
}
