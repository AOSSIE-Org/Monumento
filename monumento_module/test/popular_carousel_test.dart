import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:monumento/utils/popular_carousel.dart';
import 'package:network_image_mock/network_image_mock.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {
  final Map<String, dynamic> data;

  MockDocumentSnapshot(this.data);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('testing PopularCarousel:', () {
    int _currentTab = 0;
    String imageUrl = "https://example.com/image.png";
    Map<String, dynamic> data = {
      "name": "name",
      "image": imageUrl,
      "country": "country",
      "city": "city",
    };
    MockDocumentSnapshot mockDocumentSnapshot = MockDocumentSnapshot(data);
    List<MockDocumentSnapshot> mockPopMonumentDocs = [mockDocumentSnapshot];
    void _changeScreen(int tabIndex) {
      _currentTab = tabIndex;
    }

    testWidgets('testing if monument data is displayed',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PopularMonumentsCarousel(
                changeTab: _changeScreen,
                popMonumentDocs: mockPopMonumentDocs,
              ),
            ),
          ),
        );

        // name of the monument is displayed
        expect(find.text('name'), findsOneWidget);
        // the name of the country of the monument is displayed
        expect(find.text('country'), findsOneWidget);
        // the name of the city of the monument is displayed
        expect(find.text('city'), findsOneWidget);
        // the image of the monument is displayed
        expect(find.byType(Image), findsOneWidget);
      });
    });
  });
}
