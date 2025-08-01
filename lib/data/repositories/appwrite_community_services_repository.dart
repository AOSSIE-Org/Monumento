import 'dart:io' as io; // Add this prefix

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CommunityService {
  late Client client;
  late Databases databases;
  late Storage storage;
  late Account account;

  String databaseId = dotenv.env['APPWRITE_DATABASE_ID']!;
  String usersCollectionId = dotenv.env['APPWRITE_USER_ID']!;
  String imagesBucketId = dotenv.env['APPWRITE_BUCKET_ID']!;

  CommunityService() {
    client = Client();
    client
        .setEndpoint(dotenv.env['APPWRITE_API_ENDPOINT'] ??
            'https://cloud.appwrite.io/v1') // Replace with your Appwrite endpoint
        .setProject(
            dotenv.env['APPWRITE_PROJECT_ID']); // Replace with your project ID

    databases = Databases(client);
    storage = Storage(client);
    account = Account(client);
  }

  /// Create a new community
  Future<Document> createCommunity({
    required String name,
    required String description,
    io.File? coverImage, // Use the prefix
  }) async {
    try {
      final user = await account.get();
      final userId = user.$id;

      String? coverImageUrl;
      if (coverImage != null) {
        coverImageUrl = await _uploadCoverImage(coverImage);
      }

      final communityData = {
        'name': name,
        'description': description,
        'coverImageUrl': coverImageUrl,
        'createdByUserId': userId,
        'adminIds': [userId],
        'memberIds': [userId],
        'membersCount': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'isActive': true,
      };

      final community = await databases.createDocument(
        databaseId: databaseId,
        collectionId: dotenv.env['APPWRITE_COMMUNITIES_COLLECTION_ID']!,
        documentId: ID.unique(),
        data: communityData,
      );

      await _updateUserCommunities(userId, community.$id);

      return community;
    } catch (e) {
      throw Exception('Failed to create community: $e');
    }
  }

  /// Upload cover image and return its public view URL
  Future<String> _uploadCoverImage(io.File image) async {
    // Explicitly use io.File
    try {
      final file = await storage.createFile(
        bucketId: imagesBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(
          path: image.path, // Use path instead of name
          filename: image.path.split('/').last, // Extract filename from path
        ),
      );

      return 'https://cloud.appwrite.io/v1/storage/buckets/$imagesBucketId/files/${file.$id}/view?project=${dotenv.env['APPWRITE_PROJECT_ID']}'; // ! add project id here
    } catch (e) {
      throw Exception('Failed to upload cover image: $e');
    }
  }

  /// Update user's myCommunities list
  Future<void> _updateUserCommunities(String userId, String communityId) async {
    try {
      final userDoc = await databases.getDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
      );

      List<String> myCommunities =
          List<String>.from(userDoc.data['myCommunities'] ?? []);
      if (!myCommunities.contains(communityId)) {
        myCommunities.add(communityId);
      }

      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
        data: {
          'myCommunities': myCommunities,
        },
      );
    } catch (e) {
      throw Exception('Failed to update user communities: $e');
    }
  }

  /// Get communities where the current user is a member
  Future<List<Document>> getUserCommunities() async {
    try {
      final user = await account.get();
      final userId = user.$id;

      final communities = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: dotenv.env['APPWRITE_COMMUNITIES_COLLECTION_ID']!,
        queries: [
          Query.contains('memberIds', userId),
          Query.orderDesc('createdAt'),
        ],
      );

      return communities.documents;
    } catch (e) {
      throw Exception('Failed to get user communities: $e');
    }
  }

  /// Get community by ID
  Future<Document> getCommunityById(String communityId) async {
    try {
      return await databases.getDocument(
        databaseId: databaseId,
        collectionId: dotenv.env['APPWRITE_COMMUNITIES_COLLECTION_ID']!,
        documentId: communityId,
      );
    } catch (e) {
      throw Exception('Failed to get community: $e');
    }
  }

  /// Join an existing community
  Future<void> joinCommunity(String communityId) async {
    try {
      final user = await account.get();
      final userId = user.$id;

      final community = await databases.getDocument(
        databaseId: databaseId,
        collectionId: dotenv.env['APPWRITE_COMMUNITIES_COLLECTION_ID']!,
        documentId: communityId,
      );

      List<String> memberIds =
          List<String>.from(community.data['memberIds'] ?? []);
      if (memberIds.contains(userId)) {
        throw Exception('User is already a member of this community');
      }

      memberIds.add(userId);

      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: dotenv.env['APPWRITE_COMMUNITIES_COLLECTION_ID']!,
        documentId: communityId,
        data: {
          'memberIds': memberIds,
          'membersCount': memberIds.length,
        },
      );

      await _updateUserJoinedCommunities(userId, communityId);
    } catch (e) {
      throw Exception('Failed to join community: $e');
    }
  }

  /// Update user's joinedCommunities list
  Future<void> _updateUserJoinedCommunities(
      String userId, String communityId) async {
    try {
      final userDoc = await databases.getDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
      );

      List<String> joinedCommunities =
          List<String>.from(userDoc.data['joinedCommunities'] ?? []);
      if (!joinedCommunities.contains(communityId)) {
        joinedCommunities.add(communityId);
      }

      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
        data: {
          'joinedCommunities': joinedCommunities,
        },
      );
    } catch (e) {
      throw Exception('Failed to update joined communities: $e');
    }
  }

  /// Leave a community
  Future<void> leaveCommunity(String communityId) async {
    try {
      final user = await account.get();
      final userId = user.$id;

      final community = await databases.getDocument(
        databaseId: databaseId,
        collectionId: dotenv.env['APPWRITE_COMMUNITIES_COLLECTION_ID']!,
        documentId: communityId,
      );

      List<String> memberIds =
          List<String>.from(community.data['memberIds'] ?? []);
      memberIds.remove(userId);

      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: dotenv.env['APPWRITE_COMMUNITIES_COLLECTION_ID']!,
        documentId: communityId,
        data: {
          'memberIds': memberIds,
          'membersCount': memberIds.length,
        },
      );

      final userDoc = await databases.getDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
      );

      List<String> joinedCommunities =
          List<String>.from(userDoc.data['joinedCommunities'] ?? []);
      joinedCommunities.remove(communityId);

      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
        data: {
          'joinedCommunities': joinedCommunities,
        },
      );
    } catch (e) {
      throw Exception('Failed to leave community: $e');
    }
  }

  /// Delete a community (only allowed for admins)
  Future<void> deleteCommunity(String communityId) async {
    try {
      final user = await account.get();
      final userId = user.$id;

      final community = await databases.getDocument(
        databaseId: databaseId,
        collectionId: dotenv.env['APPWRITE_COMMUNITIES_COLLECTION_ID']!,
        documentId: communityId,
      );

      List<String> adminIds =
          List<String>.from(community.data['adminIds'] ?? []);
      if (!adminIds.contains(userId)) {
        throw Exception('Only admins can delete this community');
      }

      await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: dotenv.env['APPWRITE_COMMUNITIES_COLLECTION_ID']!,
        documentId: communityId,
      );

      // Optional: clean up user references to deleted community
    } catch (e) {
      throw Exception('Failed to delete community: $e');
    }
  }
}
