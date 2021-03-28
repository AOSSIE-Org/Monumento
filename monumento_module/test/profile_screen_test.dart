import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:monumento/home_screen.dart';
import 'package:monumento/profile_screen.dart';

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {
  final String documentID;
  final Map<String, dynamic> data;

  MockDocumentSnapshot(this.documentID, this.data);
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('UserProfileScreen test:', () {
    final data = {"name": "name", "prof_pic": "", "status": "status"};
    final mockDocumentSnapshot = MockDocumentSnapshot("documentId", data);
    NavigatorObserver mockNavObserver;
    setUp(() {
      mockNavObserver = MockNavigatorObserver();
    });

    testWidgets('testing if profile data is displayed',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: UserProfilePage(
          profileSnapshot: mockDocumentSnapshot,
          bookmarkedMonuments: [],
        ),
      ));

      // check if full name is displayed
      expect(find.text('name'), findsOneWidget);
      // check if status is displayed
      expect(find.text('status'), findsOneWidget);
    });

    testWidgets('testing logout button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: UserProfilePage(
          profileSnapshot: mockDocumentSnapshot,
          bookmarkedMonuments: [],
        ),
        navigatorObservers: [mockNavObserver],
      ));

      // tap on LogOut button
      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      expect(find.text('Logging Out!'), findsOneWidget);

      // verifying if navigation was initiated
      verify(mockNavObserver.didPush(any, any));
    });
  });
}
