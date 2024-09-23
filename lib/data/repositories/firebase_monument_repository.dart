import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:monumento/data/models/monument_model.dart';
import 'package:monumento/data/models/nearby_place_model.dart';
import 'package:monumento/data/models/user_model.dart';
import 'package:monumento/data/models/wiki_data_model.dart';
import 'package:monumento/domain/repositories/authentication_repository.dart';
import 'package:monumento/domain/repositories/monument_repository.dart';
import 'package:monumento/utils/enums.dart';
import 'package:wikipedia/wikipedia.dart';
import 'package:http/http.dart' as http;

class FirebaseMonumentRepository implements MonumentRepository {
  final AuthenticationRepository authenticationRepository;
  final FirebaseFirestore _database;

  FirebaseMonumentRepository(this.authenticationRepository,
      {FirebaseFirestore? database})
      : _database = database ?? FirebaseFirestore.instance;

  @override
  Future<List<MonumentModel>> getPopularMonuments() async {
    final docs = await _database.collection('monuments').get();
    final List<MonumentModel> popularMonumentsDocs =
        docs.docs.map((doc) => MonumentModel.fromJson(doc.data())).toList();
    return popularMonumentsDocs;
  }

  @override
  Future<List<MonumentModel>> getBookmarkedMonuments() async {
    try {
      var (userLoggedIn, user) = await authenticationRepository.getUser();
      if (!userLoggedIn) {
        throw Exception("User not logged in");
      }
      final snap = await _database
          .collection('bookmarks')
          .where('uid', isEqualTo: user?.uid)
          .get();
      final monumentIdsList =
          snap.docs.map((doc) => doc['monumentId']).toList();
      final List<MonumentModel> bookmarkedMonuments = [];
      for (var monumentId in monumentIdsList) {
        final monumentSnap =
            await _database.collection('monuments').doc(monumentId).get();
        if (monumentSnap.exists) {
          bookmarkedMonuments.add(MonumentModel.fromJson(monumentSnap.data()!));
        }
      }
      return bookmarkedMonuments;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<UserModel?> getProfileData(String userId) async {
    final snap = await _database.collection('users').doc(userId).get();
    if (snap.exists) {
      return UserModel.fromJson(snap.data()!);
    }
    return null;
  }

  @override
  Future<WikiDataModel> getMonumentWikiDetails(String wikiId) async {
    Wikipedia instance = Wikipedia();
    var res = await instance.searchSummaryWithPageId(pageId: int.parse(wikiId));
    return WikiDataModel(
      extract: res!.extract!,
      title: res.title!,
      description: res.description!,
      pageId: wikiId,
    );
  }

  @override
  Future<bool> bookmarkMonument(String monumentId) async {
    try {
      var (userLoggedIn, user) = await authenticationRepository.getUser();
      if (!userLoggedIn) {
        throw Exception("User not logged in");
      }
      await _database.collection('bookmarks').add({
        'uid': user?.uid,
        'monumentId': monumentId,
        'bookmarkedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> unbookmarkMonument(String monumentId) async {
    try {
      var (userLoggedIn, user) = await authenticationRepository.getUser();
      if (!userLoggedIn) {
        throw Exception("User not logged in");
      }
      final snap = await _database
          .collection('bookmarks')
          .where('uid', isEqualTo: user?.uid)
          .where('monumentId', isEqualTo: monumentId)
          .get();
      if (snap.docs.isNotEmpty) {
        await _database
            .collection('bookmarks')
            .doc(snap.docs.first.id)
            .delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isMonumentBookmarked(String monumentId) async {
    try {
      var (userLoggedIn, user) = await authenticationRepository.getUser();
      if (!userLoggedIn) {
        throw Exception("User not logged in");
      }
      final snap = await _database
          .collection('bookmarks')
          .where('uid', isEqualTo: user?.uid)
          .where('monumentId', isEqualTo: monumentId)
          .get();
      return snap.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<MonumentModel?> getMonumentModelByName(
      {required String monumentName}) async {
    try {
      QuerySnapshot snap = await _database
          .collection('monuments')
          .where('name', isEqualTo: monumentName)
          .get();
      List<MonumentModel> monument = snap.docs
          .map((e) => MonumentModel.fromJson(e.data() as Map<String, dynamic>))
          .toList();
      return monument[0];
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  @override
  Future<MonumentModel> getMonumentDetails(String monumentId) async {
    final snap = await _database.collection('monuments').doc(monumentId).get();
    if (snap.exists) {
      return MonumentModel.fromJson(snap.data()!);
    }
    throw Exception("Monument not found");
  }

  @override
  Future<List<NearbyPlaceModel>> getPlacesNearby(
      double latitude, double longitude) async {
    var key = dotenv.env['GEOAPIFY_API_KEY'];
    var url =
        "https://api.geoapify.com/v2/place-details?lat=$latitude&lon=$longitude&features=walk_15.restaurant,walk_15.toilet,walk_15.hotel,walk_15.atm,walk_15.supermarket,walk_15.restaurant&apiKey=$key";

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      List<NearbyPlaceModel> nearbyPlaces = [];
      for (var place in res['features']) {
        if (place['properties']['feature_type'] != null &&
            place['properties']['name'] != null) {
          if (FeatureType.values
              .contains(getFeatureType(place['properties']['feature_type']))) {
            nearbyPlaces.add(NearbyPlaceModel(
              name: place['properties']['name'],
              longitude: place['geometry']['coordinates'][0],
              latitude: place['geometry']['coordinates'][1],
              address: place['properties']['formatted'],
              featureType: getFeatureType(place['properties']['feature_type']),
            ));
          }
        }
      }
      return nearbyPlaces;
    } else {
      throw Exception("Failed to load places nearby");
    }
  }
}
