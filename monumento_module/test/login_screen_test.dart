import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:monumento/login_screen.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('login page test: ', () {
    NavigatorObserver mockNavigatoObserver;

    setUp(() {
      mockNavigatoObserver = MockNavigatorObserver();
    });

    testWidgets('testing if all the elements are displayed',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(),
      ));

      // finds email textField
      expect(find.text('Enter your Email'), findsOneWidget);
      // finds password textField
      expect(find.text('Enter your Password'), findsOneWidget);
      // finds the login button
      expect(find.text('LOGIN'), findsOneWidget);
      // finds the google sign in button
      expect(find.text('Login with Google'), findsOneWidget);
      // finds the signup gestureDetector
      expect(find.byType(GestureDetector).first, findsOneWidget);
    });

    testWidgets('navigates to SignUpScreen when signUp is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(),
        navigatorObservers: [mockNavigatoObserver],
      ));

      // get the signUp GestureDetector
      var signUp = find.byType(GestureDetector).first;
      expect(find.byType(GestureDetector).first, findsOneWidget);


      await tester.tap(signUp);
      await tester.pumpAndSettle();

      // sign up page is displayed
      verify(mockNavigatoObserver.didPush(any, any));
    });
  });
}
