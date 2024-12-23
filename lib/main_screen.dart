import 'package:flutter/material.dart';
import 'CategoriesScreen.dart';
import 'home_page.dart';
import 'main.dart';
import 'saved_posts_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomePage(),
    CategoriesScreen(),
    SavedPostsScreen(),
    Center(child: Text('Thông báo')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.black,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),  // Icon rỗng
              activeIcon: Icon(Icons.home),     // Icon đặc
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),  // Icon rỗng
              activeIcon: Icon(Icons.window_sharp),     // Icon đặc
              label: 'Chủ đề',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),     // Icon rỗng
              activeIcon: Icon(Icons.bookmark),       // Icon đặc
              label: 'Đã lưu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),  // Icon rỗng
              activeIcon: Icon(Icons.notifications),     // Icon đặc
              label: 'Thông báo',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}