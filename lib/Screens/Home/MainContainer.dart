// screens/main_container_screen.dart
import 'package:flutter/material.dart';
import 'package:real_life_rpg/ArView/AR_Screen.dart';
import 'package:real_life_rpg/Screens/Home/homeScreen.dart';
import 'package:real_life_rpg/Screens/Quests/QuestList.dart';
import 'package:real_life_rpg/Screens/Social/LeaderboardScreen.dart';
import 'package:real_life_rpg/Screens/profile/ProfileScreen.dart';
import 'package:real_life_rpg/Widgets/BottomBar.dart';



class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({super.key});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    QuestListScreen(),
    ARCharacterScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Padding(
        padding:  EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: RPGBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index
            );
          },
        ),
      ),
    );
  }
}