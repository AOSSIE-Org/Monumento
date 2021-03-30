import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monumento/utils/bookmark_carousel.dart';

void main() {
  int _currentTab = 0;
  void changeScreen(int tabIndex) {
    _currentTab = tabIndex;
  }

  /// on tap of the See All button, [BookmarkScreen] should be displayed
  /// as currently there are no bookmarked monuments, "No bookmarks!"
  /// text should be displayed
  testWidgets('testing if tab changes on tap of See All button',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BookmarkCarousel(
          bookmarkedMonumentDocs: [],
          changeTab: changeScreen,
        ),
      ),
    ));

    // Get the GestureDetector (See All Button)
    var seeAllButton = find.byType(GestureDetector).first;
    await tester.tap(seeAllButton);
    await tester.pumpAndSettle();

    expect(find.text('No Bookmarks!'), findsOneWidget);
  });

}
