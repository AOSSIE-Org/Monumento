import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class MonumentDataManager {
  static final MonumentDataManager _instance = MonumentDataManager._internal();

  // Private constructor for singleton
  MonumentDataManager._internal();

  // Factory constructor for singleton
  factory MonumentDataManager() => _instance;

  final CollectionReference _configCollection =
      FirebaseFirestore.instance.collection('appConfig');
  final CollectionReference _monumentsCollection =
      FirebaseFirestore.instance.collection('monuments');

  Future<bool> isMonumentDataAdded() async {
    try {
      DocumentSnapshot snapshot =
          await _configCollection.doc('monumentDataStatus').get();

      if (snapshot.exists) {
        return snapshot.get('isMonumentDataAdded') ?? false;
      } else {
        return false;
      }
    } catch (e) {
      log("Error checking monument data status: $e");
      return false;
    }
  }

  Future<void> setMonumentDataAddedFlag() async {
    try {
      await _configCollection.doc('monumentDataStatus').set({
        'isMonumentDataAdded': true,
      });
      log("Monument data status flag set to true.");
    } catch (e) {
      log("Error setting monument data status flag: $e");
    }
  }

  /// Populates monument data into Firestore
  Future<void> populateMonumentData() async {
    // Check if the data has already been added
    bool isDataAdded = await isMonumentDataAdded();

    if (isDataAdded) {
      log("Monument data already added. Skipping population.");
      return; // Exit if data is already added
    }

    try {
      for (var monument in monumentData) {
        DocumentReference docRef = await _monumentsCollection.add(monument);
        await docRef.update({"id": docRef.id});
        log("Added monument: ${monument['name']} with ID: ${docRef.id}");
      }

      await setMonumentDataAddedFlag();
      log("All monument data added successfully.");
    } catch (e) {
      log("Error adding monument data: $e");
    }
  }

// Sample monument data
  List<Map<String, dynamic>> monumentData = [
    {
      "city": "NA",
      "communityId": "8zDOMVBZHO38gGLODH1d",
      "coordinates": [43.8789472, -103.459825],
      "country": "South Dakota",
      "has3DModel": true,
      "image":
          "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/monuments%2FRushmore.png?alt=media&token=a33ee419-70ae-4c2c-bd20-091ff49f668f",
      "image_1x1_":
          "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/monuments%2FRushmore.png?alt=media&token=a33ee419-70ae-4c2c-bd20-091ff49f668f",
      "images": [
        "https://i0.wp.com/gregdisch.com/wp-content/uploads/2021/01/Mount-Rushmore-National-Memorial-20140915-_MG_7930.jpg?ssl=1",
        "https://www.nps.gov/moru/learn/historyculture/images/Hall-of-Records-2017-2_1.jpg?maxwidth=1300&maxheight=1300&autorotate=false",
        "https://regal-holidays.net/wp-content/uploads/2019/07/hawa-mahal-441563_1920.jpg",
        "https://regal-holidays.net/wp-content/uploads/2019/07/architecture-3187940_1920.jpg",
      ],
      "isPopular": true,
      "localExperts": [
        {
          "designation": "Local Guide",
          "expertId": "A98DB973KW",
          "imageUrl":
              "https://tse4.mm.bing.net/th?id=OIP.dv5bNWXzayD0yiL_-sKuuwHaHa&pid=Api",
          "name": "Thomas Baker",
          "phoneNumber": "+911234567890"
        },
        {
          "designation": "Freelance Photographer",
          "expertId": "NKCRKENUII",
          "imageUrl":
              "https://tse4.mm.bing.net/th?id=OIP.dv5bNWXzayD0yiL_-sKuuwHaHa&pid=Api",
          "name": "Andrew Harris",
          "phoneNumber": "+910987654321"
        }
      ],
      "modelLink":
          "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/3dModels%2Fmount_rushmore%2Fscene?alt=media&token=522ada26-b7ae-4ef0-b682-dc595d6bf732",
      "name": "Mount Rushmore National Memorial",
      "rating": 3.9,
      "wikiPageId": "185973",
      "wikipediaLink": "https://en.wikipedia.org/wiki/Mount_Rushmore"
    },
  ];
}
