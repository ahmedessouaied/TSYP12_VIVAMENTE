import 'package:b_bot/screens/chatbot_page.dart';
import 'package:b_bot/screens/detailed_metrics_page.dart';
import 'package:b_bot/screens/games.dart';
import 'package:b_bot/screens/health_dashboard.dart';
import 'package:b_bot/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  static void switchToPage(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_HomePageState>();
    if (state != null) {
      state._onItemTapped(index);
    }
  }

  @override
  State<BottomNavbar> createState() => _HomePageState();
}

class _HomePageState extends State<BottomNavbar> {
  int _selectedIndex = 0;
  User? user;
  DateTime? lastPressed;

  late final List<Widget> _pages;
  late final List<Widget> _pageWidgets;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      for (int i = 0; i < _pageWidgets.length; i++) {
        _pageWidgets[i] = Offstage(
          offstage: _selectedIndex != i,
          child: TickerMode(
            enabled: _selectedIndex == i,
            child: _pages[i],
          ),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      const ChatBotPage(),
      const GamesPage(),
      const DetailedMetricsPage(),
      const HealthDashboardPage(),
      const ProfileScreen(),
    ];

    _pageWidgets = _pages.asMap().entries.map((entry) {
      return Offstage(
        offstage: _selectedIndex != entry.key,
        child: TickerMode(
          enabled: _selectedIndex == entry.key,
          child: entry.value,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        final now = DateTime.now();
        if (lastPressed == null ||
            now.difference(lastPressed!) > const Duration(seconds: 2)) {
          lastPressed = now;
          Fluttertoast.showToast(msg: 'Tap again to exit');
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Main content area
              Expanded(
                child: Stack(
                  children: _pageWidgets,
                ),
              ),
              // Navigation bar
              BottomNavigationBar(
                currentIndex: _selectedIndex,
                backgroundColor: theme.cardColor,
                onTap: _onItemTapped,
                selectedItemColor: theme.primaryColor,
                unselectedItemColor: theme.colorScheme.tertiary,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat, color: theme.colorScheme.tertiary),
                    activeIcon: Icon(Icons.chat, color: theme.primaryColor),
                    label: "ChatBot",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.games, color: theme.colorScheme.tertiary),
                    activeIcon: Icon(Icons.games, color: theme.primaryColor),
                    label: "Games",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.health_and_safety, color: theme.colorScheme.tertiary),
                    activeIcon: Icon(Icons.health_and_safety, color: theme.primaryColor),
                    label: "Health",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.developer_board, color: theme.colorScheme.tertiary),
                    activeIcon: Icon(Icons.developer_board, color: theme.primaryColor),
                    label: "DashBoard",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person, color: theme.colorScheme.tertiary),
                    activeIcon: Icon(Icons.person, color: theme.primaryColor),
                    label: "Profile",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}