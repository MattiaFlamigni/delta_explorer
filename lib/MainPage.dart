import 'package:delta_explorer/diary/diary.dart';
import 'package:delta_explorer/profile/profile.dart';
import 'package:delta_explorer/standings/standings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home/home.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedTab = 0;

  final List<Widget> _pages = [ Home(), Profile(),];
  final List<String> _titles = ['Home', "Classifica",  "Diario", 'Profilo' ];

  void _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return Home();
      case 1:
        return Standings();

      case 2:
        return Diary();
      case 3:
        return Profile();
      default:
        return Home();

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedTab]),),
      body: _getPage(_selectedTab),

    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
        currentIndex: _selectedTab,
        onTap: _changeTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Classifica',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration_outlined),
            label: 'Diario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
      ),
    );
  }
}
