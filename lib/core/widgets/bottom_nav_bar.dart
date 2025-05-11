import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/state/storybook_state.dart';
import '/core/mixins/sound_mixin.dart';
import '../../views/screens/home/home_screen.dart';
import '../../views/screens/animation/animation_screen.dart';
import '../../views/screens/storybook/storybook_screen.dart';
import '../../views/screens/settings/settings_screen.dart';



class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with SoundMixin {
  int _page = 0;
  List<Widget> _navBarItems = [];
  late final PageController _pageController = PageController(initialPage: 0);

  List<Widget> _getNavBarItems(bool isEnabled) {
    return [
      Icon(Icons.home,
          size: 30,
          color: _page == 0 ? const Color(0xFFFACB3C) : Colors.white),
      Icon(Icons.movie,
          size: 30,
          color: _page == 1 ? const Color(0xFFFACB3C) : Colors.white),
      if (isEnabled)
        Icon(Icons.menu_book_rounded,
            size: 30,
            color: _page == 2 ? const Color(0xFFFACB3C) : Colors.white),
      Icon(Icons.settings,
          size: 30,
          color: _page == (isEnabled ? 3 : 2) ? const Color(0xFFFACB3C) : Colors.white),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StorybookState>(builder: (context, storybookState, child) {
      final isEnabled = storybookState.isEnabled;
      _navBarItems = _getNavBarItems(isEnabled);

      // Create a list of screens based on the enabled state
      final screens = [
        const HomeScreen(),
        const AnimationScreen(),
        if (isEnabled) const StorybookScreen(),
        const SettingsScreen(),
      ];

      // Ensure _page is within bounds after state change
      if (_page >= screens.length) {
        _page = screens.length - 1;
      }

      return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          index: _page,
          items: _navBarItems,
          color: Colors.green,
          buttonBackgroundColor: Colors.green,
          backgroundColor: const Color(0xFFA8D97F),
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 600),
          onTap: (index) {
            // Play navigation sound
            playNavigationSound(context);
            
            setState(() {
              _page = index;
            });
          },
          letIndexChange: (index) => index < screens.length,
        ),
        body: IndexedStack(
          index: _page,
          children: screens,
        ),
      );
    });
  }
}