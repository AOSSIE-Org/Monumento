import 'dart:io' as io; // Add this prefix

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:monumento/data/models/community_model.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/domain/entities/user_entity.dart';

class CommunityService {
  late Client client;
  late Databases databases;
  late Storage storage;
  late Account account;

  String databaseId = dotenv.env['APPWRITE_DATABASE_ID']!;
  String usersCollectionId = dotenv.env['APPWRITE_USER_ID']!;
  String imagesBucketId = dotenv.env['APPWRITE_BUCKET_ID']!;
  String communitiesCollectionId =
      dotenv.env['APPWRITE_COMMUNITIES_COLLECTION_ID']!;
  String postsCollectionId = dotenv.env['APPWRITE_POSTS_ID']!;

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

  // /// Create a new community
  // Future<Document> createCommunity({
  //   required String name,
  //   required String description,
  //   io.File? coverImage, // Use the prefix
  // }) async {
  //   try {
  //     final user = await account.get();
  //     final userId = user.$id;

  //     String? coverImageUrl;
  //     if (coverImage != null) {
  //       coverImageUrl = await _uploadCoverImage(coverImage);
  //     }

  //     final communityData = {
  //       'name': name,
  //       'description': description,
  //       'coverImageUrl': coverImageUrl,
  //       'createdByUserId': userId,
  //       'adminIds': [userId],
  //       'memberIds': [userId],
  //       'membersCount': 1,
  //       'createdAt': DateTime.now().toIso8601String(),
  //       'isActive': true,
  //     };

  //     final community = await databases.createDocument(
  //       databaseId: databaseId,
  //       collectionId: dotenv.env['APPWRITE_COMMUNITIES_COLLECTION_ID']!,
  //       documentId: ID.unique(),
  //       data: communityData,
  //     );

  //     await _updateUserCommunities(userId, community.$id);

  //     return community;
  //   } catch (e) {
  //     throw Exception('Failed to create community: $e');
  //   }
  // }
  /// Create a new community
  Future<Document> createCommunity({
    required String name,
    required String description,
    io.File? coverImage,
  }) async {
    try {
      // Get current user
      final user = await account.get();
      final userId = user.$id;

      // Upload cover image if provided
      String? coverImageUrl;
      if (coverImage != null) {
        coverImageUrl = await _uploadCoverImage(coverImage);
      }

      // Create community document
      final communityData = {
        'name': name,
        'description': description,
        'coverImageUrl': coverImageUrl,
        'createdByUserId': userId,
        'adminIds': [userId],
        'memberIds': [userId], // Creator is the first member
        'membersCount': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'isActive': true,
      };

      final community = await databases.createDocument(
        databaseId: databaseId,
        collectionId: communitiesCollectionId,
        documentId: ID.unique(),
        data: communityData,
      );

      // Update user's myCommunities array
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
  Future<CommunityModel> getCommunityById(String communityId) async {
    try {
      final community = await databases.getDocument(
        databaseId: databaseId,
        collectionId: dotenv.env['APPWRITE_COMMUNITIES_COLLECTION_ID']!,
        documentId: communityId,
      );
      return CommunityModel.fromMap(community.data, community.$id);
    } catch (e) {
      throw Exception('Failed to get community: $e');
    }
  }

  // /// Join an existing community
  // Future<void> joinCommunity(String communityId) async {
  //   try {
  //     final user = await account.get();
  //     final userId = user.$id;

  //     final community = await databases.getDocument(
  //       databaseId: databaseId,
  //       collectionId: dotenv.env['APPWRITE_COMMUNITIES_COLLECTION_ID']!,
  //       documentId: communityId,
  //     );

  //     List<String> memberIds =
  //         List<String>.from(community.data['memberIds'] ?? []);
  //     if (memberIds.contains(userId)) {
  //       throw Exception('User is already a member of this community');
  //     }

  //     memberIds.add(userId);

  //     await databases.updateDocument(
  //       databaseId: databaseId,
  //       collectionId: dotenv.env['APPWRITE_COMMUNITIES_COLLECTION_ID']!,
  //       documentId: communityId,
  //       data: {
  //         'memberIds': memberIds,
  //         'membersCount': memberIds.length,
  //       },
  //     );

  //     await _updateUserJoinedCommunities(userId, communityId);
  //   } catch (e) {
  //     throw Exception('Failed to join community: $e');
  //   }
  // }
  /// Join a community
  Future<void> joinCommunity(String communityId) async {
    try {
      final user = await account.get();
      final userId = user.$id;

      // Get community document
      final community = await databases.getDocument(
        databaseId: databaseId,
        collectionId: communitiesCollectionId,
        documentId: communityId,
      );

      // Get current members
      List<String> memberIds = [];
      if (community.data['memberIds'] != null) {
        memberIds = List<String>.from(community.data['memberIds']);
      }

      // Check if user is already a member
      if (memberIds.contains(userId)) {
        throw Exception('User is already a member of this community');
      }

      // Add user to members
      memberIds.add(userId);

      // Update community
      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: communitiesCollectionId,
        documentId: communityId,
        data: {
          'memberIds': memberIds,
          'membersCount': memberIds.length,
        },
      );

      // Update user's joinedCommunities
      await _updateUserJoinedCommunities(userId, communityId);
    } catch (e) {
      throw Exception('Failed to join community: $e');
    }
  }

  // /// Update user's joinedCommunities list
  // Future<void> _updateUserJoinedCommunities(
  //     String userId, String communityId) async {
  //   try {
  //     final userDoc = await databases.getDocument(
  //       databaseId: databaseId,
  //       collectionId: usersCollectionId,
  //       documentId: userId,
  //     );

  //     List<String> joinedCommunities =
  //         List<String>.from(userDoc.data['joinedCommunities'] ?? []);
  //     if (!joinedCommunities.contains(communityId)) {
  //       joinedCommunities.add(communityId);
  //     }

  //     await databases.updateDocument(
  //       databaseId: databaseId,
  //       collectionId: usersCollectionId,
  //       documentId: userId,
  //       data: {
  //         'joinedCommunities': joinedCommunities,
  //       },
  //     );
  //   } catch (e) {
  //     throw Exception('Failed to update joined communities: $e');
  //   }
  // }

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

  /// Get communities where the current user has joined (member but not necessarily admin)
  Future<List<Document>> getUserCreatedCommunities() async {
    try {
      final user = await account.get();
      final userId = user.$id;

      // First get the user document to access their joinedCommunities list
      final userDoc = await databases.getDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
      );

      final createdCommunityIds =
          List<String>.from(userDoc.data['myCommunities'] ?? []);

      if (createdCommunityIds.isEmpty) {
        return [];
      }

      // Fetch all communities where ID is in the user's joinedCommunities list
      final communities = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: dotenv.env['APPWRITE_COMMUNITIES_COLLECTION_ID']!,
        queries: [
          Query.equal('\$id', createdCommunityIds),
          Query.orderDesc('createdAt'),
        ],
      );

      return communities.documents;
    } catch (e) {
      throw Exception('Failed to get user joined communities: $e');
    }
  }

  /// Increment community posts count
  Future<void> _incrementCommunityPostsCount(String communityId) async {
    try {
      final community = await databases.getDocument(
        databaseId: databaseId,
        collectionId: communitiesCollectionId,
        documentId: communityId,
      );

      final currentCount = community.data['postsCount'] ?? 0;

      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: communitiesCollectionId,
        documentId: communityId,
        data: {
          'postsCount': currentCount + 1,
        },
      );
    } catch (e) {
      throw Exception('Failed to update community posts count: $e');
    }
  }

  /// Upload post image
  Future<String> _uploadPostImage(io.File image) async {
    try {
      final file = await storage.createFile(
        bucketId: 'mediaBucket', // Using the unified media bucket
        fileId: ID.unique(),
        file: InputFile.fromPath(path: image.path),
      );

      // Return the file URL
      return 'https://cloud.appwrite.io/v1/storage/buckets/$imagesBucketId/files/${file.$id}/view?project=${dotenv.env['APPWRITE_PROJECT_ID']}';
    } catch (e) {
      throw Exception('Failed to upload post image: $e');
    }
  }

  /// Create community post
  Future<Document> createCommunityPost({
    required String communityId,
    required String title,
    String? location,
    io.File? image,
  }) async {
    try {
      final user = await account.get();
      final userId = user.$id;

      // Upload image if provided
      String? imageUrl;
      if (image != null) {
        imageUrl = await _uploadPostImage(image);
      }

      // Create post document
      final postData = {
        'title': title,
        'location': location,
        'imageUrl': imageUrl,
        'timeStamp': DateTime.now().toIso8601String(),
        'postType': 1, // Community post type
        'postByUid': userId,
        'likesCount': 0,
        'commentsCount': 0,
        'communityId': communityId,
        'author': {
          'uid': userId,
          'name': user.name,
          'email': user.email,
          'username': user.name,
        },
        'isFromCommunity': 1,
      };

      final post = await databases.createDocument(
        databaseId: databaseId,
        collectionId: postsCollectionId,
        documentId: ID.unique(),
        data: postData,
      );

      // Update community posts count
      await _incrementCommunityPostsCount(communityId);

      return post;
    } catch (e) {
      throw Exception('Failed to create community post: $e');
    }
  }

  /// Get community members
  Future<List<UserEntity>> getCommunityMembers(String communityId) async {
    try {
      final community = await databases.getDocument(
        databaseId: databaseId,
        collectionId: communitiesCollectionId,
        documentId: communityId,
      );

      final memberIds = List<String>.from(community.data['memberIds'] ?? []);
      List<UserEntity> members = [];

      for (String memberId in memberIds) {
        try {
          final userDoc = await databases.getDocument(
            databaseId: databaseId,
            collectionId: usersCollectionId,
            documentId: memberId,
          );
          members.add(UserEntity.fromDocument(userDoc));
        } catch (e) {
          // Skip if user not found
          continue;
        }
      }

      return members;
    } catch (e) {
      throw Exception('Failed to get community members: $e');
    }
  }

  /// Get community posts
  Future<List<PostEntity>> getCommunityPosts(String communityId) async {
    try {
      final posts = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: 'posts',
        queries: [
          Query.equal('communityId', communityId),
          Query.orderDesc('timeStamp'),
        ],
      );

      return posts.documents
          .map((doc) => PostEntity.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get community posts: $e');
    }
  }

  /// Check if user is member of community
  Future<bool> isUserMemberOfCommunity(String communityId) async {
    try {
      final user = await account.get();
      final userId = user.$id;

      final community = await databases.getDocument(
        databaseId: databaseId,
        collectionId: communitiesCollectionId,
        documentId: communityId,
      );

      final memberIds = List<String>.from(community.data['memberIds'] ?? []);
      return memberIds.contains(userId);
    } catch (e) {
      return false;
    }
  }

  /// Update user's joined communities list
  Future<void> _updateUserJoinedCommunities(
      String userId, String communityId) async {
    try {
      // Get current user document
      final userDoc = await databases.getDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
      );

      // Get current joinedCommunities array or create empty array
      List<String> joinedCommunities = [];
      if (userDoc.data['joinedCommunities'] != null) {
        joinedCommunities =
            List<String>.from(userDoc.data['joinedCommunities']);
      }

      // Add new community ID
      if (!joinedCommunities.contains(communityId)) {
        joinedCommunities.add(communityId);
      }

      // Update user document
      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
        data: {
          'joinedCommunities': joinedCommunities,
        },
      );
    } catch (e) {
      throw Exception('Failed to update user joined communities: $e');
    }
  }

  /// Get all communities
  Future<List<CommunityModel>> getAllCommunities() async {
    try {
      final communities = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: communitiesCollectionId,
        queries: [
          Query.orderDesc('createdAt'),
        ],
      );

      return communities.documents
          .map((doc) => CommunityModel.fromMap(doc.data, doc.$id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all communities: $e');
    }
  }
}
