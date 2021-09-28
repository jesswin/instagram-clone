import 'package:flutter/material.dart';
import 'package:iinstagram/screens/activity_screen.dart';

import '../screens/profile_screen.dart';
import '../screens/search_screen.dart';
import '../widgets/posts.dart';

class Tabbarr extends StatefulWidget {
  static const routeName = "/tab";
  @override
  _TabbarrState createState() => _TabbarrState();
}

class _TabbarrState extends State<Tabbarr> {
  var userName;
  var displayName;
  var dpUrl;

  List<Map<String, Object>> pages;
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    pages = [
      {'page': Posts(), 'title': 'Home'},
      {'page': Search(), 'title': 'Post'},
      {'page': ActivityScreen(), 'title': 'Notification'},
      {'page': Profile(), 'title': 'Profile'},
    ];
    void _onItemTapped(int index) {
      setState(() {
        print(index);
        _selectedIndex = index;
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: pages[_selectedIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 0 ? Icons.home_filled : Icons.home,
                  size: 35),
              // ignore: deprecated_member_use
              title: Container(height: 0.0)),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 35),
            // ignore: deprecated_member_use
            title: Container(height: 0.0),
          ),
          BottomNavigationBarItem(
              icon: Icon(
                  _selectedIndex == 2 ? Icons.favorite : Icons.favorite_border,
                  size: 35),
              // ignore: deprecated_member_use
              title: Container(height: 0.0)),
          BottomNavigationBarItem(
              icon: Icon(
                  _selectedIndex == 3
                      ? Icons.account_circle
                      : Icons.account_circle_outlined,
                  size: 35),
              // ignore: deprecated_member_use
              title: Container(height: 0.0)),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
