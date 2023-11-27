import 'package:flutter/material.dart';
import 'package:twitch_clone/utilities/colors.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = '/homeScreen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;

  pageChange(int p) {
    setState(() {
      _page = p;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_page],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: buttonColor,
        unselectedItemColor: primaryColor,
        unselectedFontSize: 12,
        currentIndex: _page,
        iconSize: 25,
        onTap: pageChange,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
              ),
              label: 'Following'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.add_rounded,
              ),
              label: 'Go Live'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.copy,
              ),
              label: 'Browse')
        ],
      ),
    );
  }
}
