import 'dart:convert';
import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:wikipedia/wikipedia.dart' as wiki;

import '../../domain/repositories/authentication_repository.dart';
import '../../domain/repositories/monument_repository.dart';
import '../../service_locator.dart';
import '../../utils/enums.dart';
import '../models/monument_model.dart';
import '../models/nearby_place_model.dart';
import '../models/user_model.dart';
import '../models/wiki_data_model.dart';

class AppwriteMonumentRepository implements MonumentRepository {
  final AuthenticationRepository _authRepository;
  final Databases _database;

  AppwriteMonumentRepository({
    Databases? database,
    AuthenticationRepository? authenticationRepository,
  })  : _database = database ?? locator<Databases>(),
        _authRepository =
            authenticationRepository ?? locator<AuthenticationRepository>();

  final databaseId = dotenv.env['APPWRITE_DATABSE_ID'] ?? 'dbmonumento';
  final userCollectionId = dotenv.env['APPWRITE_USER_COLLECTION_ID'] ?? 'users';
  final monumentsCollectionId = dotenv.env['APPWRITE_MONUMENTS_COLLECTION_ID'] ?? 'monuments';
  final postsCollectionId = dotenv.env['APPWRITE_POSTS_COLLECTION_ID'] ?? 'posts';
  final localExpertsCollectionId = dotenv.env['APPWRITE_LOCALEXPERTS_COLLECTION_ID'] ?? 'localExperts';

  @override
  Future<List<MonumentModel>> getPopularMonuments() async {
    final response = await _database.listDocuments(
      databaseId: databaseId,
      collectionId: monumentsCollectionId,
    );

    return response.documents
        .map((doc) => MonumentModel.fromJson(doc.data))
        .toList();
  }

  @override
  Future<List<MonumentModel>> getBookmarkedMonuments() async {
    try {
      final (userLoggedIn, user) = await _authRepository.getUser();
      if (!userLoggedIn || user == null) {
        throw Exception("User not logged in");
      }

      final document = await _database.getDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: user.uid,
      );

      final savedMonuments = document.data['savedMonuments'] as List;
      return savedMonuments
          .map((monument) =>
              MonumentModel.fromJson(monument as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error fetching bookmarked monuments: ${e.toString()}');
      return [];
    }
  }

  @override
  Future<UserModel?> getProfileData(String userId) async {
    final response = await _database.listDocuments(
      databaseId: databaseId,
      collectionId: userCollectionId,
      queries: [Query.equal('\$id', userId)],
    );

    return response.documents.isNotEmpty
        ? UserModel.fromJson(response.documents.first.data)
        : null;
  }

  @override
  Future<WikiDataModel> getMonumentWikiDetails(String wikiId) async {
    final instance = wiki.Wikipedia();
    final pageId = int.parse(wikiId);
    final wikiResponse = await instance.searchSummaryWithPageId(pageId: pageId);

    if (wikiResponse == null) {
      throw Exception('Failed to fetch wiki details');
    }

    return WikiDataModel(
      extract: wikiResponse.extract!,
      title: wikiResponse.title!,
      description: wikiResponse.description!,
      pageId: wikiId,
    );
  }

  @override
  Future<bool> bookmarkMonument(String monumentId) async {
    try {
      final (userLoggedIn, user) = await _authRepository.getUser();
      if (!userLoggedIn || user == null) {
        return false;
      }

      final userDoc = await _database.getDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: user.uid,
      );

      final currentSavedMonuments =
          List<String>.from(userDoc.data['savedMonuments'] ?? []);

      if (!currentSavedMonuments.contains(monumentId)) {
        currentSavedMonuments.add(monumentId);
      }

      await _database.updateDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: user.uid,
        data: {
          'savedMonuments': currentSavedMonuments,
        },
      );

      return true;
    } catch (e) {
      log('Error bookmarking monument: ${e.toString()}');
      return false;
    }
  }

  @override
  Future<bool> unbookmarkMonument(String monumentId) async {
    try {
      final (userLoggedIn, user) = await _authRepository.getUser();
      if (!userLoggedIn || user == null) {
        return false;
      }

      final userDoc = await _database.getDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: user.uid,
      );

      final currentSavedMonuments =
          List<String>.from(userDoc.data['savedMonuments'] ?? []);

      currentSavedMonuments.remove(monumentId);

      await _database.updateDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: user.uid,
        data: {
          'savedMonuments': currentSavedMonuments,
        },
      );

      return true;
    } catch (e) {
      log('Error unbookmarking monument: ${e.toString()}');
      return false;
    }
  }

  @override
  Future<bool> isMonumentBookmarked(String monumentId) async {
    try {
      final (userLoggedIn, user) = await _authRepository.getUser();
      if (!userLoggedIn || user == null) {
        return false;
      }

      final userDoc = await _database.getDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: user.uid,
      );

      final savedMonuments =
          List<String>.from(userDoc.data['savedMonuments'] ?? []);

      return savedMonuments.contains(monumentId);
    } catch (e) {
      log('Error checking if monument is bookmarked: ${e.toString()}');
      return false;
    }
  }

  @override
  Future<MonumentModel?> getMonumentModelByName(
      {required String monumentName}) async {
    try {
      final response = await _database.listDocuments(
        databaseId: databaseId,
        collectionId: monumentsCollectionId,
        queries: [Query.contains('name', monumentName)],
      );

      if (response.documents.isEmpty) {
        return null;
      }

      return MonumentModel.fromJson(response.documents.first.data);
    } catch (e) {
      log('Error fetching monument by name: ${e.toString()}');
      return null;
    }
  }

  @override
  Future<MonumentModel> getMonumentDetails(String monumentId) async {
    try {
      final document = await _database.getDocument(
        databaseId: databaseId,
        collectionId: monumentsCollectionId,
        documentId: monumentId,
      );

      return MonumentModel.fromJson(document.data);
    } catch (e) {
      log('Error fetching monument details: ${e.toString()}');
      throw Exception("Monument not found");
    }
  }

  @override
  Future<List<NearbyPlaceModel>> getPlacesNearby(
      double latitude, double longitude) async {
    final apiKey = dotenv.env['GEOAPIFY_API_KEY'];
    final url =
        "https://api.geoapify.com/v2/place-details?lat=$latitude&lon=$longitude&features=walk_15.restaurant,walk_15.toilet,walk_15.hotel,walk_15.atm,walk_15.supermarket,walk_15.restaurant&apiKey=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception("API returned status code ${response.statusCode}");
      }

      final jsonResponse = jsonDecode(response.body);
      final List<NearbyPlaceModel> nearbyPlaces = [];

      for (var place in jsonResponse['features']) {
        final properties = place['properties'];
        final featureType = properties['feature_type'];
        final name = properties['name'];

        if (featureType != null &&
            name != null &&
            FeatureType.values.contains(getFeatureType(featureType))) {
          nearbyPlaces.add(NearbyPlaceModel(
            name: name,
            longitude: place['geometry']['coordinates'][0],
            latitude: place['geometry']['coordinates'][1],
            address: properties['formatted'],
            featureType: getFeatureType(featureType),
          ));
        }
      }

      return nearbyPlaces;
    } catch (e) {
      log('Error fetching nearby places: ${e.toString()}');
      throw Exception("Failed to load places nearby: ${e.toString()}");
    }
  }
}
