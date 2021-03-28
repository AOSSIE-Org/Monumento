import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:monumento/register_screen.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockSignUp extends Mock {
  int call(String params);
}

void main() {
  group('testing SignUpScreen:', () {
    final NavigatorObserver mockNavObserver = MockNavigatorObserver();

    testWidgets('all elements are displayed properly',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SignUpScreen(),
      ));

      // find the Name label
      expect(find.text('Name'), findsOneWidget);
      // find the Name text field
      expect(find.text('Enter your Name'), findsOneWidget);
      // find the Status label
      expect(find.text('Status'), findsOneWidget);
      // find the Status text field
      expect(find.text('Enter your current status'), findsOneWidget);
      // find the Email label
      expect(find.text('Email'), findsOneWidget);
      // find the Email text field
      expect(find.text('Enter your Email'), findsOneWidget);
      // find the Password label
      expect(find.text('Password'), findsOneWidget);
      // find the Password text field
      expect(find.text('Enter your Password'), findsOneWidget);
      // find the REGISTER button
      expect(find.text('REGISTER'), findsOneWidget);
    });

    testWidgets('REGISTER button works properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
          navigatorObservers: [mockNavObserver],
        ),
      );

      // get the register button
      var registerButton = find.byType(RaisedButton);
      // tap on the button
      await tester.tap(registerButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // navigates to the homeScreen after completing sign up
      verify(mockNavObserver.didPush(any, any));
    });
  });
}
