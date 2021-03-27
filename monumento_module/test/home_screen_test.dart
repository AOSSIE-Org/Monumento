import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monumento/home_screen.dart';

void main() {
  
  // test for checking if BottomNavigationBar is working properly
  testWidgets('BottomNavigationBar is working properly', (WidgetTester tester) async {
    int _currentTab = 0;
    Widget bottomNavBar() {
      return BottomNavigationBar(
        selectedLabelStyle: TextStyle(color: Colors.amber),
        currentIndex: _currentTab,
        elevation: 10.0,
        selectedItemColor: Colors.amber,
        onTap: (int value) {
          _currentTab = value;
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30.0,
              color: Colors.grey,
            ),
            label: 'Home',
            activeIcon: Icon(
              Icons.home,
              size: 35.0,
              color: Colors.amber,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.apps,
              size: 30.0,
              color: Colors.grey,
            ),
            label: 'Popular',
            activeIcon: Icon(
              Icons.apps,
              size: 35.0,
              color: Colors.amber,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bookmark,
              size: 30.0,
              color: Colors.grey,
            ),
            label: 'Bookmarks',
            activeIcon: Icon(
              Icons.bookmark,
              size: 35.0,
              color: Colors.amber,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
              size: 30.0,
              color: Colors.grey,
            ),
            label: 'Profile',
            activeIcon: Icon(
              Icons.person_outline,
              size: 35.0,
              color: Colors.amber,
            ),
          ),
        ],
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: bottomNavBar(),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.apps));
    expect(_currentTab, 1);

    await tester.tap(find.byIcon(Icons.bookmark));
    expect(_currentTab, 2);

    await tester.tap(find.byIcon(Icons.person_outline));
    expect(_currentTab, 3);

    await tester.tap(find.byIcon(Icons.home)); 
    expect(_currentTab, 0); 
  });

  // 
}
