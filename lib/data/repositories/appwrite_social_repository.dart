import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:monumento/data/models/comment_model.dart';
import 'package:monumento/data/models/notification_model.dart';
import 'package:monumento/data/models/post_model.dart';
import 'package:monumento/data/models/story_model.dart';
import 'package:monumento/data/models/user_model.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/domain/repositories/authentication_repository.dart';
import 'package:monumento/domain/repositories/social_repository.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/enums.dart';
import 'package:uuid/uuid.dart';

class AppwriteSocialRepository implements SocialRepository {
  final Databases _database;
  final Storage _storage;
  final AuthenticationRepository authenticationRepository;

  // Bucket ID for Appwrite storage
  final String _endpoint =
      dotenv.env['APPWRITE_API_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1';
  final String _imagesBucketId = dotenv.env['APPWRITE_BUCKET_ID'] ?? 'default';
  final String _projectId = dotenv.env['APPWRITE_PROJECT_ID'] ?? 'defalut';
  final String _databaseId =
      dotenv.env['APPWRITE_DATABASE_ID'] ?? 'dbmonumento';

  AppwriteSocialRepository(
      {required this.authenticationRepository,
      Databases? database,
      Storage? storage})
      : _database = database ?? locator<Databases>(),
        _storage = storage ?? locator<Storage>();

  @override
  Future<String> uploadImageForUrl(
      {required File file, required String address}) async {
    String fileName = const Uuid().v4();
    String extension = file.path.split('.').last;
    String newFilename = "$fileName.$extension";
    try {
      // Set more specific file ID to improve traceability
      final fileId = ID.unique();

      final result = await _storage.createFile(
        bucketId: _imagesBucketId,
        fileId: fileId,
        file: InputFile.fromPath(
          path: file.path,
          filename: newFilename,
        ),
      );

      // Get file view URL using direct path construction
      return "$_endpoint/storage/buckets/$_imagesBucketId/files/${result.$id}/view?project=$_projectId&mode=admin";
    } on AppwriteException catch (e) {
      log('Error uploading image: ${e.message}',
          stackTrace: StackTrace.current);
      throw Exception('Failed to upload image: ${e.message}');
    } catch (e) {
      log('Unexpected error uploading image: $e',
          stackTrace: StackTrace.current);
      throw Exception('Failed to upload image: $e');
    }
  }

  @override
  Future<String> uploadProfilePicForUrl({required Uint8List fileBytes}) async {
    String fileName = const Uuid().v4();

    try {
      // Upload file bytes to Appwrite Storage
      print(_storage);
      final result = await _storage.createFile(
        bucketId: _imagesBucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: fileBytes,
          filename: '$fileName.jpg',
        ),
      );

      // Get file view URL
      String fileId = result.$id;

      return "$_endpoint/storage/buckets/$_imagesBucketId/files/$fileId/view?project=$_projectId&mode=admin";
    } catch (e) {
      log('Error uploading profile picture: $e');
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  @override
  Future<void> updateUserProfile(
      {required Map<Object, dynamic> userInfo}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
    print(userInfo);
    await _database.updateDocument(
      databaseId: _databaseId,
      collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
      documentId: user!.uid,
      data: userInfo,
    );
  }

  @override
  @override
  Future<List<UserModel>> searchPeople({required String searchQuery}) async {
    String query = searchQuery.toLowerCase().replaceAll(' ', '');
    print(query);
    try {
      // Using Appwrite's query syntax
      final documents = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
        queries: [Query.search('searchParams', query), Query.limit(10)],
      );

      List<UserModel> users = [];

      for (var doc in documents.documents) {
        try {
          // Create a mutable copy of the data
          Map<String, dynamic> userData = Map<String, dynamic>.from(doc.data);

          // Handle uid field - use document ID if uid is null
          userData['uid'] = userData['uid'] ?? doc.$id;

          // Handle posts field
          if (userData['posts'] == null) {
            userData['posts'] = <String>[];
          } else if (userData['posts'] is Map) {
            userData['posts'] = <String>[];
          } else if (userData['posts'] is List) {
            // Ensure all elements are strings
            userData['posts'] = List<String>.from(
                userData['posts'].map((item) => item.toString()));
          }

          users.add(UserModel.fromJson(userData));
        } catch (e) {
          print("Error processing user document: $e");
          // Continue to next document even if one fails
        }
      }

      return users;
    } catch (e) {
      print(e);
      log('Error searching people: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to search people: $e');
    }
  }

  @override
  Future<List<UserModel>> getMoreSearchResults(
      {required String searchQuery, required String startAfterDocId}) async {
    String query = searchQuery.toLowerCase().replaceAll(' ', '');

    try {
      // First get the document that serves as our cursor
      final startAfterDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
          documentId: startAfterDocId);

      // Then get documents after it
      // Appwrite doesn't have startAfter like Firebase, so we need to use cursor-based pagination
      // Get the date joined from the cursor document
      final dateJoined = startAfterDoc.data['dateJoined'] ?? 0;

      final documents = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
        queries: [
          Query.search('searchParams', query),
          Query.greaterThan('dateJoined', dateJoined),
          Query.orderAsc('dateJoined'),
          Query.limit(10)
        ],
      );

      // Convert documents to UserModel objects
      List<UserModel> users = documents.documents.map((doc) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(doc.data);
        // Use document ID as uid if uid is null
        userData['uid'] = userData['uid'] ?? doc.$id;

        // Handle posts field
        if (userData['posts'] == null) {
          userData['posts'] = <String>[];
        } else if (userData['posts'] is Map) {
          userData['posts'] = <String>[];
        } else if (userData['posts'] is List) {
          // Ensure all elements are strings
          userData['posts'] = List<String>.from(
              userData['posts'].map((item) => item.toString()));
        }

        return UserModel.fromJson(userData);
      }).toList();

      return users;
    } catch (e) {
      log('Error getting more search results: $e',
          stackTrace: StackTrace.current);
      throw Exception('Failed to get more search results: $e');
    }
  }

  @override
  Future<UserModel> getUserByUid({required String uid}) async {
    try {
      final document = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
          documentId: uid);

      // Copy the document data and ensure uid is not null
      Map<String, dynamic> userData = Map<String, dynamic>.from(document.data);
      // Use document ID as uid if uid is null
      userData['uid'] = userData['uid'] ?? document.$id;

      // Handle posts field
      if (userData['posts'] == null) {
        userData['posts'] = <String>[];
      } else if (userData['posts'] is Map) {
        userData['posts'] = <String>[];
      } else if (userData['posts'] is List) {
        // Ensure all elements are strings
        userData['posts'] =
            List<String>.from(userData['posts'].map((item) => item.toString()));
      }

      UserModel user = UserModel.fromJson(userData);
      return user;
    } catch (e) {
      log('Error getting user by uid: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to get user by uid: $e');
    }
  }

  @override
  Future<bool> checkUserNameAvailability({required String username}) async {
    try {
      final documents = await _database.listDocuments(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
          queries: [Query.equal('username', username)]);

      return documents.documents.isEmpty;
    } catch (e) {
      log('Error checking username availability: $e',
          stackTrace: StackTrace.current);
      throw Exception('Failed to check username availability: $e');
    }
  }

  @override
  Future<PostModel> uploadNewPost(
      {required String title,
      String? location,
      String? imageUrl,
      required int postType}) async {
    try {
      // Check authentication and get user in one step
      var (userLoggedIn, user) = await authenticationRepository.getUser();
      if (!userLoggedIn || user == null) {
        throw Exception("User not logged in");
      }

      // Get current timestamp
      final timeStamp = DateTime.now();
      final postId = ID.unique();

      // Prepare post data using a direct map to avoid multiple transformations
      final postData = {
        "title": title,
        "location": location ?? "",
        "imageUrl": imageUrl,
        "author": user.uid,
        "timeStamp": timeStamp.toIso8601String(),
        "postType": postType,
        "postByUid": user.uid,
        "likesCount": 0,
        "commentsCount": 0,
      };

      // Create document with optimized parameters
      final result = await _database.createDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
          documentId: postId,
          data: postData);

      // Return a properly constructed PostModel directly
      return PostModel(
        author: user,
        postByUid: user.uid,
        title: title,
        location: location,
        imageUrl: imageUrl,
        timeStamp: timeStamp,
        postId: result.$id,
        postType: postType,
        likesCount: 0,
        commentsCount: 0,
      );
    } on AppwriteException catch (e) {
      log("Error creating post: ${e.message}", stackTrace: StackTrace.current);
      throw Exception("Failed to create post: ${e.message}");
    } catch (e) {
      log("Unexpected error creating post: $e", stackTrace: StackTrace.current);
      throw Exception("Failed to create post: $e");
    }
  }

  @override
  Future<List<PostModel>> getInitialDiscoverPosts() async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      final documents = await _database.listDocuments(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
          queries: [
            Query.equal("postType", 0),
            Query.orderDesc("timeStamp"),
            Query.limit(8)
          ]);

      List<PostModel> posts = [];

      for (var doc in documents.documents) {
        try {
          // Create a mutable copy of the data
          final data = Map<String, dynamic>.from(doc.data);

          // Ensure postId is set
          data['postId'] = doc.$id;

          if (data['likesCount'] != null && data['likesCount'] > 0) {
            try {
              final postIdPart =
                  doc.$id.substring(0, 18); // First 18 chars of post ID
              final userIdPart =
                  user!.uid.substring(0, 17); // First 17 chars of user ID
              final likeDocId =
                  "${postIdPart}_$userIdPart"; // Total 36 chars (18+1+17)
              final likeDoc = await _database.getDocument(
                  databaseId: _databaseId,
                  collectionId: dotenv.env['APPWRITE_LIKES_ID'] ?? "postLikes",
                  documentId: likeDocId);

              data['isPostLiked'] = (likeDoc.data['likedPost'] == true);
            } catch (e) {
              print(e);
              data['isPostLiked'] = false;
            }
          } else {
            data['isPostLiked'] = false;
          }

          // Clean and prepare the author data
          if (data.containsKey('author') &&
              data['author'] is Map<String, dynamic>) {
            final authorData = Map<String, dynamic>.from(data['author']);

            // Ensure required fields exist and are not null
            if (authorData['uid'] == null) {
              authorData['uid'] = authorData['\$id'] ?? '';
            }

            // Create UserModel manually instead of using fromJson
            final author = UserModel(
              uid: authorData['uid'] ?? authorData['\$id'] ?? '',
              email: authorData['email'] ?? '',
              name: authorData['name'] ?? 'Unknown User',
              profilePictureUrl: authorData['profilePictureUrl'],
              status: authorData['status'] ?? '',
              username: authorData['username'],
              followers: List<String>.from(authorData['followers'] ?? []),
              following: List<String>.from(authorData['following'] ?? []),
              posts: List<String>.from(authorData['posts'] ?? []),
            );

            // Replace the author data with our manually created object
            final postModel = PostModel(
              postId: data['postId'],
              imageUrl: data['imageUrl'],
              title: data['title'] ?? '',
              location: data['location'],
              timeStamp: DateTime.parse(data['timeStamp']),
              author: author,
              postByUid: data['postByUid'] ?? '',
              likesCount: data['likesCount'] ?? 0,
              postType: data['postType'] ?? 0,
              commentsCount: data['commentsCount'] ?? 0,
              isPostLiked: data['isPostLiked'] ?? false,
            );

            posts.add(postModel);
          }
        } catch (e) {
          print("Error creating PostModel: $e");
        }
      }

      print("Total posts found: ${posts.length}");
      return posts;
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  @override
  Future<void> followUser({required UserEntity targetUser}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    if (user!.uid == targetUser.uid) {
      throw Exception("Can't follow yourself!");
    }

    try {
      // Add to target user's followers
      final targetUserDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
          documentId: targetUser.uid);

      List<String> followers =
          List<String>.from(targetUserDoc.data['followers'] ?? []);
      if (!followers.contains(user.uid)) {
        followers.add(user.uid);
        await _database.updateDocument(
            databaseId: _databaseId,
            collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
            documentId: targetUser.uid,
            data: {'followers': followers});
      }

      // Add to current user's following
      final currentUserDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
          documentId: user.uid);

      List<String> following =
          List<String>.from(currentUserDoc.data['following'] ?? []);
      if (!following.contains(targetUser.uid)) {
        following.add(targetUser.uid);
        await _database.updateDocument(
            databaseId: _databaseId,
            collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
            documentId: user.uid,
            data: {'following': following});
      }

      // Create notification
      var notification = NotificationModel(
        notificationType: NotificationType.followedYou,
        timeStamp: DateTime.now().millisecondsSinceEpoch,
        userInvolved: user,
      );

      await addNewNotification(
        targetUser: UserModel.fromEntity(targetUser),
        notification: notification,
      );
    } catch (e) {
      log("Error following user: $e", stackTrace: StackTrace.current);
      throw Exception("Failed to follow user: $e");
    }
  }

  @override
  Future<bool> getFollowStatus({required UserEntity targetUser}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      // Get target user document
      final targetDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
          documentId: targetUser.uid);

      // Get current user document
      final currentDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
          documentId: user!.uid);

      List<String> targetFollowers =
          List<String>.from(targetDoc.data['followers'] ?? []);
      List<String> currentFollowing =
          List<String>.from(currentDoc.data['following'] ?? []);

      return targetFollowers.contains(user.uid) &&
          currentFollowing.contains(targetUser.uid);
    } catch (e) {
      log("Error checking follow status: $e", stackTrace: StackTrace.current);
      throw Exception("Failed to check follow status: $e");
    }
  }

  @override
  Future<void> unfollowUser({required UserEntity targetUser}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      // Remove from target user's followers
      final targetUserDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
          documentId: targetUser.uid);

      List<String> followers =
          List<String>.from(targetUserDoc.data['followers'] ?? []);
      followers.remove(user!.uid);

      await _database.updateDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
          documentId: targetUser.uid,
          data: {'followers': followers});

      // Remove from current user's following
      final currentUserDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
          documentId: user.uid);

      List<String> following =
          List<String>.from(currentUserDoc.data['following'] ?? []);
      following.remove(targetUser.uid);

      await _database.updateDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
          documentId: user.uid,
          data: {'following': following});
    } catch (e) {
      log("Error unfollowing user: $e", stackTrace: StackTrace.current);
      throw Exception("Failed to unfollow user: $e");
    }
  }

  @override
  Future<bool> monumentCheckIn(
      {required String monumentId, String? title}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      // Get monument details
      final monument = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_MONUMENTS_ID'] ?? "monuments",
          documentId: monumentId);

      // Check if user already checked in
      final existingCheckIns = await _database.listDocuments(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_CHECKIN_ID'] ?? "checkIns",
          queries: [
            Query.equal("monumentId", monumentId),
            Query.equal("userId", user!.uid)
          ]);

      if (existingCheckIns.documents.isNotEmpty) {
        return false; // Already checked in
      }

      // Create a check-in
      final checkInId = ID.unique();
      final timeStamp = DateTime.now().toIso8601String();

      await _database.createDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_CHECKIN_ID'] ?? "checkIns",
          documentId: checkInId,
          data: {
            "monumentId": monumentId,
            "userId": user.uid,
            "title": title ?? "",
            "timeStamp": timeStamp
          });

      // Create a post for the check-in
      final location =
          "${monument.data['city'] ?? ""}, ${monument.data['country'] ?? ""}";

      await _database.createDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
          documentId: ID.unique(),
          data: {
            "title": title ?? "",
            "location": location,
            "imageUrl": null,
            "author": user.uid,
            "timeStamp": timeStamp,
            "postType": 2, // Check-in post type
            "postByUid": user.uid,
            "likesCount": 0,
            "commentsCount": 0,
          });

      return true;
    } catch (e) {
      print(e);
      log('Error checking in to monument: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to check in to monument: $e');
    }
  }

  @override
  Future<bool> checkInStatus({required String monumentId}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      final documents = await _database.listDocuments(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_CHECKIN_ID'] ?? "checkIns",
          queries: [
            Query.equal("monumentId", monumentId),
            Query.equal("userId", user!.uid)
          ]);

      return documents.documents.isNotEmpty;
    } catch (e) {
      log('Error checking check-in status: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to check check-in status: $e');
    }
  }

  @override
  Future<List<UserModel>> loadUser(List<String> userConnections) async {
    List<UserModel> users = [];

    for (String connection in userConnections) {
      try {
        final document = await _database.getDocument(
            databaseId: _databaseId,
            collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
            documentId: connection);

        Map<String, dynamic> userData =
            Map<String, dynamic>.from(document.data);
        // Use document ID as uid if uid is null
        userData['uid'] = userData['uid'] ?? document.$id;
        // Handle posts field
        if (userData['posts'] == null) {
          userData['posts'] = <String>[];
        } else if (userData['posts'] is Map) {
          userData['posts'] = <String>[];
        } else if (userData['posts'] is List) {
          // Ensure all elements are strings
          userData['posts'] = List<String>.from(
              userData['posts'].map((item) => item.toString()));
        }

        users.add(UserModel.fromJson(userData));
      } catch (e) {
        log('Error loading user $connection: $e',
            stackTrace: StackTrace.current);
        // Continue loading other users even if one fails
      }
    }

    return users;
  }

  @override
  Future<List<PostModel>> getInitialUserPosts({required String uid}) async {
    try {
      print("enter");
      final documents = await _database.listDocuments(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
          queries: [
            Query.equal("postByUid", uid),
            Query.orderDesc("timeStamp"),
            Query.limit(10)
          ]);

      var (userLoggedIn, currentUser) =
          await authenticationRepository.getUser();
      String currentUid = userLoggedIn ? currentUser!.uid : "";
      print(documents.documents);

      List<PostModel> posts = [];

      for (var doc in documents.documents) {
        try {
          // Create a mutable copy of the data
          final data = Map<String, dynamic>.from(doc.data);

          // Ensure postId is set
          data['postId'] = doc.$id;

          // Check if we need to add isPostLiked
          if (!data.containsKey('isPostLiked')) {
            data['isPostLiked'] = false;
          }

          // Clean and prepare the author data
          if (data.containsKey('author') &&
              data['author'] is Map<String, dynamic>) {
            final authorData = Map<String, dynamic>.from(data['author']);

            // Ensure required fields exist and are not null
            if (authorData['uid'] == null) {
              authorData['uid'] = authorData['\$id'] ?? '';
            }

            // Create UserModel manually instead of using fromJson
            final author = UserModel(
              uid: authorData['uid'] ?? authorData['\$id'] ?? '',
              email: authorData['email'] ?? '',
              name: authorData['name'] ?? 'Unknown User',
              profilePictureUrl: authorData['profilePictureUrl'],
              status: authorData['status'] ?? '',
              username: authorData['username'],
              followers: List<String>.from(authorData['followers'] ?? []),
              following: List<String>.from(authorData['following'] ?? []),
              posts: List<String>.from(authorData['posts'] ?? []),
            );

            // Replace the author data with our manually created object
            final postModel = PostModel(
              postId: data['postId'],
              imageUrl: data['imageUrl'],
              title: data['title'] ?? '',
              location: data['location'],
              timeStamp: DateTime.parse(data['timeStamp']),
              author: author,
              postByUid: data['postByUid'] ?? '',
              likesCount: data['likesCount'] ?? 0,
              postType: data['postType'] ?? 0,
              commentsCount: data['commentsCount'] ?? 0,
              isPostLiked: data['isPostLiked'] ?? false,
            );

            posts.add(postModel);
          }
        } catch (e) {
          print("Error creating PostModel: $e");
        }
      }

      print("Total posts found: ${posts.length}");
      return posts;
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  @override
  Future<NotificationModel> addNewNotification(
      {required UserModel targetUser,
      required NotificationModel notification}) async {
    try {
      // Convert NotificationType enum to string value
      String notificationTypeString =
          notification.notificationType.toString().split('.').last;

      // Prepare the data object for Appwrite
      Map<String, dynamic> notificationData = {
        'targetUserId': targetUser.uid,
        'notificationType': notificationTypeString,
        'timeStamp': notification.timeStamp,
        'userInvolved': notification
            .userInvolved.uid, // Store just the user ID for relationship
      };

      // Add post relationship if there's a post involved
      if (notification.postInvolved != null) {
        notificationData['postInvolved'] = notification.postInvolved!.postId;
      }

      final result = await _database.createDocument(
          databaseId: _databaseId,
          collectionId: "notifications",
          documentId: ID.unique(),
          data: notificationData);

      // Return the created notification
      return notification;
    } catch (e) {
      print(e);
      log('Error adding notification: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to add notification: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getInitialNotifications() async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      final documents = await _database.listDocuments(
          databaseId: _databaseId,
          collectionId: "notifications",
          queries: [
            Query.equal("targetUserId", user!.uid),
            Query.orderDesc("timeStamp"),
            Query.limit(10)
          ]);

      List<NotificationModel> notifications = [];

      for (var doc in documents.documents) {
        try {
          final data = doc.data;
          // 1. Convert notification type string to enum
          NotificationType notificationType;
          if (data['notificationType'] is String) {
            notificationType = NotificationType.values.firstWhere(
                (e) =>
                    e.toString() ==
                    'NotificationType.${data['notificationType']}',
                orElse: () => NotificationType.followedYou // Default value
                );
          } else {
            notificationType = NotificationType.followedYou; // Default
          }

          // 2. Get the full user object for userInvolved
          UserModel userInvolved;
          if (data['userInvolved'] is String) {
            // Fetch the user document
            final userDoc = await _database.getDocument(
                databaseId: _databaseId,
                collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
                documentId: data['userInvolved']);
            Map<String, dynamic> userData =
                Map<String, dynamic>.from(userDoc.data);
            // Use document ID as uid if uid is null
            userData['uid'] = userData['uid'] ?? userDoc.$id;
            // Handle posts field
            if (userData['posts'] == null) {
              userData['posts'] = <String>[];
            } else if (userData['posts'] is Map) {
              userData['posts'] = <String>[];
            } else if (userData['posts'] is List) {
              // Ensure all elements are strings
              userData['posts'] = List<String>.from(
                  userData['posts'].map((item) => item.toString()));
            }

            userInvolved = UserModel.fromJson(userData);
          } else {
            userInvolved = UserModel.fromJson(data['userInvolved']);
          }

          // 3. Get the post if it exists
          PostModel? postInvolved;
          if (data['postInvolved'] != null) {
            try {
              final postDoc = await _database.getDocument(
                  databaseId: _databaseId,
                  collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
                  documentId: data['postInvolved']);

              postInvolved = PostModel.fromJson(postDoc.data);
            } catch (e) {
              print(e);
              log('Error fetching post for notification: $e');
              // Continue without the post
            }
          }

          // 4. Create the notification model
          notifications.add(NotificationModel(
            notificationType: notificationType,
            userInvolved: userInvolved,
            postInvolved: postInvolved,
            timeStamp: data['timeStamp'] ?? 0,
          ));
        } catch (e) {
          log('Error processing notification: $e');
        }
      }
      print(notifications);
      return notifications;
    } catch (e) {
      print(e);
      log('Error getting notifications: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to get notifications: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getMoreNotifications(
      {required String startAfterDocId}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      // Get the timestamp of the last notification
      final startAfterDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: "notifications",
          documentId: startAfterDocId);

      final timeStamp = startAfterDoc.data['timeStamp'] ?? 0;

      final documents = await _database.listDocuments(
          databaseId: _databaseId,
          collectionId: "notifications",
          queries: [
            Query.equal("targetUserId", user!.uid),
            Query.lessThan("timeStamp", timeStamp),
            Query.orderDesc("timeStamp"),
            Query.limit(10)
          ]);

      List<NotificationModel> notifications = [];

      for (var doc in documents.documents) {
        try {
          final data = doc.data;
          print(data);
          // 1. Convert notification type string to enum
          NotificationType notificationType;
          if (data['notificationType'] is String) {
            notificationType = NotificationType.values.firstWhere(
                (e) =>
                    e.toString() ==
                    'NotificationType.${data['notificationType']}',
                orElse: () => NotificationType.followedYou // Default value
                );
          } else {
            notificationType = NotificationType.followedYou; // Default
          }

          // 2. Get the full user object for userInvolved
          UserModel userInvolved;
          if (data['userInvolved'] is String) {
            // Fetch the user document
            final userDoc = await _database.getDocument(
                databaseId: _databaseId,
                collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
                documentId: data['userInvolved']);
            Map<String, dynamic> userData =
                Map<String, dynamic>.from(userDoc.data);
            // Use document ID as uid if uid is null
            userData['uid'] = userData['uid'] ?? userDoc.$id;
            // Handle posts field
            if (userData['posts'] == null) {
              userData['posts'] = <String>[];
            } else if (userData['posts'] is Map) {
              userData['posts'] = <String>[];
            } else if (userData['posts'] is List) {
              // Ensure all elements are strings
              userData['posts'] = List<String>.from(
                  userData['posts'].map((item) => item.toString()));
            }

            userInvolved = UserModel.fromJson(userData);
          } else {
            userInvolved = UserModel.fromJson(data['userInvolved']);
          }

          // 3. Get the post if it exists
          PostModel? postInvolved;
          if (data['postInvolved'] != null) {
            try {
              final postDoc = await _database.getDocument(
                  databaseId: _databaseId,
                  collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
                  documentId: data['postInvolved']);

              postInvolved = PostModel.fromJson(postDoc.data);
            } catch (e) {
              print(e);
              log('Error fetching post for notification: $e');
              // Continue without the post
            }
          }

          // 4. Create the notification model
          notifications.add(NotificationModel(
            notificationType: notificationType,
            userInvolved: userInvolved,
            postInvolved: postInvolved,
            timeStamp: data['timeStamp'] ?? 0,
          ));
        } catch (e) {
          log('Error processing notification: $e');
        }
      }

      return notifications;
    } catch (e) {
      log('Error getting more notifications: $e',
          stackTrace: StackTrace.current);
      throw Exception('Failed to get more notifications: $e');
    }
  }

  @override
  Future<List<UserModel>> getRecommendedUsers() async {
    var (userLoggedIn, currentUser) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      List<String> followingUids = currentUser!.following;
      List<UserModel> recommendedUsers = [];

      // Get users followed by users the current user follows
      for (String followingUid in followingUids) {
        final followingUserDoc = await _database.getDocument(
            databaseId: _databaseId,
            collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
            documentId: followingUid);

        List<String> secondaryFollowingUids =
            List<String>.from(followingUserDoc.data['following'] ?? []);
        print(secondaryFollowingUids);
        for (String secondaryUid in secondaryFollowingUids) {
          // Skip if this is the current user
          if (secondaryUid == currentUser.uid) continue;

          // Skip if the current user already follows this user
          if (followingUids.contains(secondaryUid)) continue;

          // Skip if we already added this user to recommendations
          if (recommendedUsers.any((user) => user.uid == secondaryUid))
            continue;

          final userDoc = await _database.getDocument(
              databaseId: _databaseId,
              collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
              documentId: secondaryUid);

          Map<String, dynamic> userData =
              Map<String, dynamic>.from(userDoc.data);
          // Use document ID as uid if uid is null
          userData['uid'] = userData['uid'] ?? userDoc.$id;
          // Handle posts field
          if (userData['posts'] == null) {
            userData['posts'] = <String>[];
          } else if (userData['posts'] is Map) {
            userData['posts'] = <String>[];
          } else if (userData['posts'] is List) {
            // Ensure all elements are strings
            userData['posts'] = List<String>.from(
                userData['posts'].map((item) => item.toString()));
          }

          recommendedUsers.add(UserModel.fromJson(userData));

          // Stop once we have 5 recommendations
          if (recommendedUsers.length == 5) break;
        }

        if (recommendedUsers.length == 5) break;
      }
      // If we didn't get enough recommendations, add random users

      if (recommendedUsers.length < 5) {
        final documents = await _database.listDocuments(
            databaseId: _databaseId,
            collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
            queries: [
              Query.notEqual("\$id", currentUser.uid),
              Query.limit(10) // Get more to filter out already followed users
            ]);

        for (var doc in documents.documents) {
          final uid = doc.data['uid'];

          // Skip users the current user already follows
          if (followingUids.contains(uid)) continue;

          // Skip users already in our recommendations
          if (recommendedUsers.any((user) => user.uid == uid)) continue;

          Map<String, dynamic> userData = Map<String, dynamic>.from(doc.data);
          // Use document ID as uid if uid is null
          userData['uid'] = userData['uid'] ?? doc.$id;
          // Handle posts field
          if (userData['posts'] == null) {
            userData['posts'] = <String>[];
          } else if (userData['posts'] is Map) {
            userData['posts'] = <String>[];
          } else if (userData['posts'] is List) {
            // Ensure all elements are strings
            userData['posts'] = List<String>.from(
                userData['posts'].map((item) => item.toString()));
          }

          recommendedUsers.add(UserModel.fromJson(userData));

          if (recommendedUsers.length == 5) break;
        }
      }

      return recommendedUsers;
    } catch (e) {
      print(e);
      log('Error getting recommended users: $e',
          stackTrace: StackTrace.current);
      throw Exception('Failed to get recommended users: $e');
    }
  }

  @override
  Future<String> likePost({required String postId}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      // Check if like already exists
      final existingLikes = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_LIKES_ID'] ?? "postLikes",
        queries: [
          Query.equal('userId', user!.uid),
          Query.equal('postId', postId),
        ],
      );

      if (existingLikes.documents.isNotEmpty) {
        // Update existing like
        final existingLike = existingLikes.documents.first;
        if (existingLike.data['liked'] == true) {
          return postId; // Already liked
        }

        await _database.updateDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_LIKES_ID'] ?? "postLikes",
          documentId: existingLike.$id,
          data: {
            'liked': true,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } else {
        // Create new like
        await _database.createDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_LIKES_ID'] ?? "postLikes",
          documentId: ID.unique(),
          data: {
            'userId': user.uid,
            'postId': postId,
            'liked': true,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }

      // Increment likes count
      final postDoc = await _database.getDocument(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
        documentId: postId,
      );

      int currentLikes = postDoc.data['likesCount'] ?? 0;
      await _database.updateDocument(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
        documentId: postId,
        data: {
          'likesCount': currentLikes + 1,
        },
      );

      return postId;
    } catch (e) {
      print(e);
      log("Error liking post: $e", stackTrace: StackTrace.current);
      throw Exception("Failed to like post: $e");
    }
  }

  @override
  Future<String> unlikePost({required String postId}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      // Find the like document
      final existingLikes = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_LIKES_ID'] ?? "postLikes",
        queries: [
          Query.equal('userId', user!.uid),
          Query.equal('postId', postId),
        ],
      );

      if (existingLikes.documents.isEmpty) {
        return postId; // No like to unlike
      }

      final existingLike = existingLikes.documents.first;
      await _database.updateDocument(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_LIKES_ID'] ?? "postLikes",
        documentId: existingLike.$id,
        data: {
          'liked': false,
        },
      );

      // Decrement likes count
      final postDoc = await _database.getDocument(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
        documentId: postId,
      );

      int currentLikes = postDoc.data['likesCount'] ?? 0;
      await _database.updateDocument(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
        documentId: postId,
        data: {
          'likesCount': (currentLikes - 1) > 0 ? (currentLikes - 1) : 0,
        },
      );

      return postId;
    } catch (e) {
      log("Error unliking post: $e", stackTrace: StackTrace.current);
      throw Exception("Failed to unlike post: $e");
    }
  }

  @override
  Future<List<PostModel>> getInitialFeedPosts() async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    List<String> followingUids = user!.following;
    if (followingUids.isEmpty) {
      return [];
    }
    print(followingUids);
    try {
      List<PostModel> allPosts = [];

      // Get posts for each following user
      for (String followingUid in followingUids) {
        final documents = await _database.listDocuments(
            databaseId: _databaseId,
            collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
            queries: [
              Query.equal('postByUid', followingUid),
              Query.orderDesc('timeStamp'),
              Query.limit(5)
            ]);
        // for (var doc in documents.documents){
        //   print(doc.data);
        // }
        for (var doc in documents.documents) {
          try {
            // Create a mutable copy of the data
            final data = Map<String, dynamic>.from(doc.data);

            // Ensure postId is set
            data['postId'] = doc.$id;
            print(data['postId']);
            print(data['likesCount']);
            // Check if post is liked
            if (data['likesCount'] != null && data['likesCount'] > 0) {
              try {
                // Create a more unique identifier by using parts of both IDs
                // This avoids collisions when truncating to 36 chars
                final postIdPart =
                    doc.$id.substring(0, 18); // First 18 chars of post ID
                final userIdPart =
                    user.uid.substring(0, 17); // First 17 chars of user ID
                final likeDocId =
                    "${postIdPart}_${userIdPart}"; // Total 36 chars (18+1+17)

                final likeDoc = await _database.getDocument(
                    databaseId: _databaseId,
                    collectionId:
                        dotenv.env['APPWRITE_LIKES_ID'] ?? "postLikes",
                    documentId: likeDocId);

                data['isPostLiked'] = (likeDoc.data['likedPost'] == true);
              } catch (e) {
                print("Like check failed for post ${doc.$id}: $e");
                data['isPostLiked'] = false;
              }
            } else {
              data['isPostLiked'] = false;
            }

            // Handle the author field - it could be a string ID or a map
            UserModel author;
            if (data['author'] is String) {
              // Author is a user ID, fetch the user
              try {
                final authorDoc = await _database.getDocument(
                    databaseId: _databaseId,
                    collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
                    documentId: data['author']);

                Map<String, dynamic> authorData =
                    Map<String, dynamic>.from(authorDoc.data);
                authorData['uid'] = authorData['uid'] ?? authorDoc.$id;

                if (authorData['posts'] == null) {
                  authorData['posts'] = <String>[];
                } else if (authorData['posts'] is Map) {
                  authorData['posts'] = <String>[];
                } else if (authorData['posts'] is List) {
                  authorData['posts'] = List<String>.from(
                      authorData['posts'].map((item) => item.toString()));
                }

                author = UserModel.fromJson(authorData);
              } catch (e) {
                print("Error fetching author: $e");
                // Create a minimal author with the ID
                author = UserModel(
                  uid: data['author'],
                  email: '',
                  name: 'Unknown User',
                  followers: [],
                  following: [],
                  posts: [],
                );
              }
            } else if (data['author'] is Map<String, dynamic>) {
              // Author data is embedded in the post
              final authorData = Map<String, dynamic>.from(data['author']);

              // Ensure required fields exist
              authorData['uid'] = authorData['uid'] ?? authorData['\$id'] ?? '';
              authorData['email'] = authorData['email'] ?? '';
              authorData['name'] = authorData['name'] ?? 'Unknown User';
              authorData['status'] = authorData['status'] ?? '';

              List<String> mappedPosts = authorData['posts'] != null
                  ? (data['posts'] as List).map<String>((e) => e).toList()
                  : [];

              author = UserModel(
                uid: authorData['uid'],
                email: authorData['email'],
                name: authorData['name'],
                profilePictureUrl: authorData['profilePictureUrl'],
                status: authorData['status'] ?? '',
                username: authorData['username'],
                followers: List<String>.from(authorData['followers'] ?? []),
                following: List<String>.from(authorData['following'] ?? []),
                posts: List<String>.from(authorData['posts'] ?? []),
              );
            } else {
              // Missing author, create minimal placeholder
              author = UserModel(
                uid: data['postByUid'] ?? '',
                email: '',
                name: 'Unknown User',
                followers: [],
                following: [],
                posts: [],
              );
            }

            // Create post model
            final postModel = PostModel(
              postId: data['postId'],
              imageUrl: data['imageUrl'],
              title: data['title'] ?? '',
              location: data['location'],
              timeStamp: DateTime.parse(data['timeStamp']),
              author: author,
              postByUid: data['postByUid'] ?? '',
              likesCount: data['likesCount'] ?? 0,
              postType: data['postType'] ?? 0,
              commentsCount: data['commentsCount'] ?? 0,
              isPostLiked: data['isPostLiked'] ?? false,
            );

            allPosts.add(postModel);
          } catch (e) {
            print("Error processing post: $e");
          }
        }
      }
      print(allPosts);
      // Sort by timestamp
      allPosts.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

      // Take only the first 5
      return allPosts.take(5).toList();
    } catch (e) {
      log('Error getting initial feed posts: $e',
          stackTrace: StackTrace.current);
      throw Exception('Failed to get initial feed posts: $e');
    }
  }

  @override
  Future<List<PostModel>> getMorePosts(
      {required String startAfterDocId}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    List<String> followingUids = user!.following;
    if (followingUids.isEmpty) {
      return [];
    }

    try {
      // First, we need to get the timestamp of the starting post to use it as a cursor
      final startDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
          documentId: startAfterDocId);
      final startTimestamp = startDoc.data['timeStamp'];

      List<PostModel> allPosts = [];

      // Get more posts for each following user
      for (String followingUid in followingUids) {
        final documents = await _database.listDocuments(
            databaseId: _databaseId,
            collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
            queries: [
              Query.equal('postByUid', followingUid),
              Query.lessThan('timeStamp',
                  startTimestamp), // Get posts older than the start document
              Query.orderDesc('timeStamp'),
              Query.limit(10)
            ]);

        for (var doc in documents.documents) {
          try {
            // Create a mutable copy of the data
            final data = Map<String, dynamic>.from(doc.data);

            // Ensure postId is set
            data['postId'] = doc.$id;

            // Check if post is liked
            if (data['likesCount'] != null && data['likesCount'] > 0) {
              try {
                final postIdPart =
                    doc.$id.substring(0, 18); // First 18 chars of post ID
                final userIdPart =
                    user.uid.substring(0, 17); // First 17 chars of user ID
                final likeDocId =
                    "${postIdPart}_${userIdPart}"; // Total 36 chars (18+1+17)
                final likeDoc = await _database.getDocument(
                    databaseId: _databaseId,
                    collectionId:
                        dotenv.env['APPWRITE_LIKES_ID'] ?? "postLikes",
                    documentId: likeDocId);

                data['isPostLiked'] = likeDoc.data['likedPost'] == true;
              } catch (e) {
                data['isPostLiked'] = false;
              }
            } else {
              data['isPostLiked'] = false;
            }

            // Handle the author field - it could be a string ID or a map
            UserModel author;
            if (data['author'] is String) {
              // Author is a user ID, fetch the user
              try {
                final authorDoc = await _database.getDocument(
                    databaseId: _databaseId,
                    collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
                    documentId: data['author']);

                Map<String, dynamic> authorData =
                    Map<String, dynamic>.from(authorDoc.data);
                authorData['uid'] = authorData['uid'] ?? authorDoc.$id;

                if (authorData['posts'] == null) {
                  authorData['posts'] = <String>[];
                } else if (authorData['posts'] is Map) {
                  authorData['posts'] = <String>[];
                } else if (authorData['posts'] is List) {
                  authorData['posts'] = List<String>.from(
                      authorData['posts'].map((item) => item.toString()));
                }

                author = UserModel.fromJson(authorData);
              } catch (e) {
                print("Error fetching author: $e");
                // Create a minimal author with the ID
                author = UserModel(
                  uid: data['author'],
                  email: '',
                  name: 'Unknown User',
                  followers: [],
                  following: [],
                  posts: [],
                );
              }
            } else if (data['author'] is Map) {
              // Author data is embedded in the post
              final authorData =
                  Map<String, dynamic>.from(data['author'] as Map);

              // Ensure required fields exist
              authorData['uid'] = authorData['uid'] ?? authorData['\$id'] ?? '';
              authorData['email'] = authorData['email'] ?? '';
              authorData['name'] = authorData['name'] ?? 'Unknown User';
              authorData['status'] = authorData['status'] ?? '';

              if (authorData['posts'] == null) {
                authorData['posts'] = <String>[];
              } else if (authorData['posts'] is Map) {
                authorData['posts'] = <String>[];
              } else if (authorData['posts'] is List) {
                authorData['posts'] = List<String>.from(
                    authorData['posts'].map((item) => item.toString()));
              }

              author = UserModel(
                uid: authorData['uid'],
                email: authorData['email'],
                name: authorData['name'],
                profilePictureUrl: authorData['profilePictureUrl'],
                status: authorData['status'] ?? '',
                username: authorData['username'],
                followers: List<String>.from(authorData['followers'] ?? []),
                following: List<String>.from(authorData['following'] ?? []),
                posts: List<String>.from(authorData['posts'] ?? []),
              );
            } else {
              // Missing author, create minimal placeholder
              author = UserModel(
                uid: data['postByUid'] ?? '',
                email: '',
                name: 'Unknown User',
                followers: [],
                following: [],
                posts: [],
              );
            }

            // Create post model
            final postModel = PostModel(
              postId: data['postId'],
              imageUrl: data['imageUrl'],
              title: data['title'] ?? '',
              location: data['location'],
              timeStamp: DateTime.parse(data['timeStamp']),
              author: author,
              postByUid: data['postByUid'] ?? '',
              likesCount: data['likesCount'] ?? 0,
              postType: data['postType'] ?? 0,
              commentsCount: data['commentsCount'] ?? 0,
              isPostLiked: data['isPostLiked'] ?? false,
            );

            allPosts.add(postModel);
          } catch (e) {
            print("Error processing post: $e");
          }
        }
      }

      // Sort by timestamp
      allPosts.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

      // Take only the first 10
      return allPosts.take(10).toList();
    } catch (e) {
      log('Error getting more feed posts: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to get more feed posts: $e');
    }
  }

  @override
  Future<List<PostModel>> getInitialProfilePosts() async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      final documents = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
        queries: [
          Query.equal("postByUid", user!.uid),
          Query.orderDesc("timeStamp"),
          Query.limit(10)
        ],
      );

      List<PostModel> posts = [];
      List<String> postIds = [];

      for (var doc in documents.documents) {
        try {
          final data = doc.data;
          if (data['postId'] == null) {
            data['postId'] = doc.$id;
          }

          postIds.add(doc.$id);

          // Check if post is liked
          if (data['likesCount'] != null && data['likesCount'] != 0) {
            try {
              final postIdPart =
                  doc.$id.substring(0, 18); // First 18 chars of post ID
              final userIdPart =
                  user.uid.substring(0, 17); // First 17 chars of user ID
              final likeDocId =
                  "${postIdPart}_${userIdPart}"; // Total 36 chars (18+1+17)
              final likeDoc = await _database.getDocument(
                  databaseId: _databaseId,
                  collectionId:
                      dotenv.env['APPWRITE_LIKES_ID'] ?? "postLikes", //fix
                  documentId: likeDocId);

              if (likeDoc.data['likedPost'] == true) {
                data['isPostLiked'] = true;
              } else {
                data['isPostLiked'] = false;
              }
            } catch (e) {
              print(e);
              log("Like doc not found");
              data['isPostLiked'] = false;
            }
          }

          // Clean and prepare the author data
          if (data.containsKey('author') &&
              data['author'] is Map<String, dynamic>) {
            final authorData = Map<String, dynamic>.from(data['author']);

            // Ensure required fields exist and are not null
            if (authorData['uid'] == null) {
              authorData['uid'] = authorData['\$id'] ?? '';
            }

            if (authorData.containsKey('posts')) {
              if (authorData['posts'] == null) {
                authorData['posts'] = <String>[];
              } else if (authorData['posts'] is! List) {
                authorData['posts'] = <String>[];
              }
            } else {
              authorData['posts'] = <String>[];
            }

            // Create UserModel manually instead of using fromJson
            final author = UserModel(
              uid: authorData['uid'] ?? authorData['\$id'] ?? '',
              email: authorData['email'] ?? '',
              name: authorData['name'] ?? 'Unknown User',
              profilePictureUrl: authorData['profilePictureUrl'],
              status: authorData['status'] ?? '',
              username: authorData['username'],
              followers: List<String>.from(authorData['followers'] ?? []),
              following: List<String>.from(authorData['following'] ?? []),
              posts: List<String>.from(authorData['posts'] ?? []),
            );

            // Replace the author data with our manually created object
            final postModel = PostModel(
              postId: data['postId'],
              imageUrl: data['imageUrl'],
              title: data['title'] ?? '',
              location: data['location'],
              timeStamp: DateTime.parse(data['timeStamp']),
              author: author,
              postByUid: data['postByUid'] ?? '',
              likesCount: data['likesCount'] ?? 0,
              postType: data['postType'] ?? 0,
              commentsCount: data['commentsCount'] ?? 0,
              isPostLiked: data['isPostLiked'] ?? false,
            );

            posts.add(postModel);
          }
        } catch (e) {
          log('Error processing post: $e');
        }
      }

      return posts;
    } catch (e) {
      log('Error getting profile posts: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to get profile posts: $e');
    }
  }

  @override
  Future<List<PostModel>> getMoreProfilePosts(
      {required String startAfterDocId}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      // Get timestamp from the last post for pagination
      final startAfterDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
          documentId: startAfterDocId);

      final timeStamp = startAfterDoc.data['timeStamp'] ?? 0;

      final documents = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
        queries: [
          Query.equal("postByUid", user!.uid),
          Query.lessThan("timeStamp", timeStamp),
          Query.orderDesc("timeStamp"),
          Query.limit(10)
        ],
      );

      List<PostModel> posts = [];

      for (var doc in documents.documents) {
        try {
          final data = doc.data;
          if (data['postId'] == null) {
            data['postId'] = doc.$id;
          }

          // Check if post is liked
          if (data['likesCount'] != null && data['likesCount'] != 0) {
            try {
              final postIdPart =
                  doc.$id.substring(0, 18); // First 18 chars of post ID
              final userIdPart =
                  user.uid.substring(0, 17); // First 17 chars of user ID
              final likeDocId =
                  "${postIdPart}_${userIdPart}"; // Total 36 chars (18+1+17)
              final likeDoc = await _database.getDocument(
                  databaseId: _databaseId,
                  collectionId:
                      dotenv.env['APPWRITE_LIKES_ID'] ?? "postLikes", //fix
                  documentId: likeDocId);

              if (likeDoc.data['likedPost'] == true) {
                data['isPostLiked'] = true;
              } else {
                data['isPostLiked'] = false;
              }
            } catch (e) {
              data['isPostLiked'] = false;
            }
          }

          // Clean and prepare the author data
          if (data.containsKey('author') &&
              data['author'] is Map<String, dynamic>) {
            final authorData = Map<String, dynamic>.from(data['author']);

            // Ensure required fields exist and are not null
            if (authorData['uid'] == null) {
              authorData['uid'] = authorData['\$id'] ?? '';
            }

            if (authorData.containsKey('posts')) {
              if (authorData['posts'] == null) {
                authorData['posts'] = <String>[];
              } else if (authorData['posts'] is! List) {
                authorData['posts'] = <String>[];
              }
            } else {
              authorData['posts'] = <String>[];
            }

            // Create UserModel manually instead of using fromJson
            final author = UserModel(
              uid: authorData['uid'] ?? authorData['\$id'] ?? '',
              email: authorData['email'] ?? '',
              name: authorData['name'] ?? 'Unknown User',
              profilePictureUrl: authorData['profilePictureUrl'],
              status: authorData['status'] ?? '',
              username: authorData['username'],
              followers: List<String>.from(authorData['followers'] ?? []),
              following: List<String>.from(authorData['following'] ?? []),
              posts: List<String>.from(authorData['posts'] ?? []),
            );

            // Replace the author data with our manually created object
            final postModel = PostModel(
              postId: data['postId'],
              imageUrl: data['imageUrl'],
              title: data['title'] ?? '',
              location: data['location'],
              timeStamp: DateTime.parse(data['timeStamp']),
              author: author,
              postByUid: data['postByUid'] ?? '',
              likesCount: data['likesCount'] ?? 0,
              postType: data['postType'] ?? 0,
              commentsCount: data['commentsCount'] ?? 0,
              isPostLiked: data['isPostLiked'] ?? false,
            );

            posts.add(postModel);
          }
        } catch (e) {
          log('Error processing post: $e');
        }
      }

      return posts;
    } catch (e) {
      log('Error getting more profile posts: $e',
          stackTrace: StackTrace.current);
      throw Exception('Failed to get more profile posts: $e');
    }
  }

  @override
  Future<CommentModel> addNewComment(
      {required String postDocId, required String comment}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      int timeStamp = DateTime.now().millisecondsSinceEpoch;
      String commentId = ID.unique();
      print(user?.uid);
      print(comment);
      print(postDocId);
      await _database.createDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_COMMENTS_ID'] ?? "comments",
          documentId: commentId,
          data: {
            "comment": comment ?? "",
            "timeStamp": timeStamp ?? 0,
            "postInvolvedId": postDocId,
            "author": user!.uid ?? "",
          });

      // Get post author for notification
      final postDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_POSTS_ID'] ?? "posts",
          documentId: postDocId);

      Map<String, dynamic> authorData = postDoc.data['author'];
      authorData['uid'] = authorData['uid'] ?? postDoc.$id;
      UserModel postAuthor = UserModel.fromJson(authorData);

      // Create notification
      var notification = NotificationModel(
        notificationType: NotificationType.commentNotification,
        timeStamp: DateTime.now().millisecondsSinceEpoch,
        userInvolved: user,
      );

      await addNewNotification(
        targetUser: postAuthor,
        notification: notification,
      );

      return CommentModel(
        comment: comment,
        postInvolvedId: postDocId,
        author: user,
        timeStamp: timeStamp,
        commentDocId: commentId,
      );
    } catch (e) {
      print(e);
      log("Error adding comment: $e", stackTrace: StackTrace.current);
      throw Exception("Failed to add comment: $e");
    }
  }

  @override
  Future<List<CommentModel>> getInitialComments(
      {required String postDocId}) async {
    try {
      final documents = await _database.listDocuments(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_COMMENTS_ID'] ?? "comments",
          queries: [
            Query.equal("postInvolvedId", postDocId),
            Query.orderDesc("timeStamp"),
            Query.limit(20)
          ]);

      List<CommentModel> comments = documents.documents.map((e) {
        Map<String, dynamic> data = e.data;
        data['commentDocId'] = e.$id;
        print(data['author']['\$id']);
        data['author']['uid'] = data['author']['\$id'];
        if (data['author']['posts'] == null) {
          data['author']['posts'] = <String>[];
        } else if (data['author']['posts'] is Map) {
          data['author']['posts'] = <String>[];
        } else if (data['author']['posts'] is List) {
          // Ensure all elements are strings
          data['author']['posts'] = List<String>.from(
              data['author']['posts'].map((item) => item.toString()));
        }
        return CommentModel.fromJson(data);
      }).toList();

      return comments;
    } catch (e) {
      print(e);
      log("Error getting comments: $e", stackTrace: StackTrace.current);
      throw Exception("Failed to get comments: $e");
    }
  }

  @override
  Future<List<CommentModel>> getMoreComments(
      {required String postDocId, required String startAfterDocId}) async {
    try {
      // Get timestamp from the last comment for pagination
      final startAfterDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_COMMENTS_ID'] ?? "comments",
          documentId: startAfterDocId);

      final timeStamp = startAfterDoc.data['timeStamp'] ?? 0;

      final documents = await _database.listDocuments(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_COMMENTS_ID'] ?? "comments",
          queries: [
            Query.equal("postInvolvedId", postDocId),
            Query.lessThan("timeStamp", timeStamp),
            Query.orderDesc("timeStamp"),
            Query.limit(10)
          ]);

      List<CommentModel> comments = documents.documents.map((e) {
        Map<String, dynamic> data = e.data;
        data['commentDocId'] = e.$id;
        print(data['author']['\$id']);
        data['author']['uid'] = data['author']['\$id'];
        if (data['author']['posts'] == null) {
          data['author']['posts'] = <String>[];
        } else if (data['author']['posts'] is Map) {
          data['author']['posts'] = <String>[];
        } else if (data['author']['posts'] is List) {
          // Ensure all elements are strings
          data['author']['posts'] = List<String>.from(
              data['author']['posts'].map((item) => item.toString()));
        }
        return CommentModel.fromJson(data);
      }).toList();

      return comments;
    } catch (e) {
      log('Error getting more comments: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to get more comments: $e');
    }
  }
  // Add these methods to AppwriteSocialRepository class

  @override
  Future<StoryModel> addStory({
    required File imageFile,
    String? caption,
  }) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn || user == null) {
      throw Exception("User not logged in");
    }

    try {
      // Upload image to storage
      String fileName = const Uuid().v4();
      String newFilename = "$fileName.jpg";

      final fileResult = await _storage.createFile(
        bucketId: _imagesBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(
          path: imageFile.path,
          filename: newFilename,
        ),
      );

      // Construct media URL
      String mediaUrl =
          "$_endpoint/storage/buckets/$_imagesBucketId/files/${fileResult.$id}/view?project=$_projectId&mode=admin";

      // Calculate expiry time (24 hours from now)
      final now = DateTime.now();
      final expiryDateTime = now.add(const Duration(hours: 24));
      final expiryTime = expiryDateTime.millisecondsSinceEpoch;

      // Create story document
      final storyId = ID.unique();
      final uploadTimestamp = now.millisecondsSinceEpoch;

      final storyData = {
        'userId': user.uid,
        'mediaUrl': mediaUrl,
        'caption': caption ?? '',
        'mediaType': 'image',
        'expiryTime': expiryTime,
        'uploadTimestamp': uploadTimestamp,
        'views': 0,
        'viewedBy': <String>[],
      };

      final result = await _database.createDocument(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_STORIES_ID'] ?? 'stories',
        documentId: storyId,
        data: storyData,
      );

      return StoryModel.fromJson({
        ...storyData,
        '\$id': result.$id,
      });
    } on AppwriteException catch (e) {
      log('Error adding story: ${e.message}', stackTrace: StackTrace.current);
      throw Exception('Failed to add story: ${e.message}');
    } catch (e) {
      log('Unexpected error adding story: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to add story: $e');
    }
  }

  @override
  Future<List<StoryModel>> fetchStories() async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Fetch all stories
      final documents = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_STORIES_ID'] ?? 'stories',
        queries: [
          Query.orderDesc('uploadTimestamp'),
          Query.limit(100),
        ],
      );

      List<StoryModel> stories = [];

      for (var doc in documents.documents) {
        try {
          final storyData = Map<String, dynamic>.from(doc.data);
          storyData['\$id'] = doc.$id;

          final story = StoryModel.fromJson(storyData);

          // Filter out expired stories (simple approach - no background deletion)
          if (!story.isExpired) {
            // Fetch author data
            try {
              final authorDoc = await _database.getDocument(
                databaseId: _databaseId,
                collectionId: dotenv.env['APPWRITE_USER_ID'] ?? 'users',
                documentId: story.userId,
              );

              Map<String, dynamic> authorData =
                  Map<String, dynamic>.from(authorDoc.data);
              authorData['uid'] = authorData['uid'] ?? authorDoc.$id;

              // Handle posts field for author
              if (authorData['posts'] == null) {
                authorData['posts'] = <String>[];
              } else if (authorData['posts'] is Map) {
                authorData['posts'] = <String>[];
              } else if (authorData['posts'] is List) {
                authorData['posts'] = List<String>.from(
                    authorData['posts'].map((item) => item.toString()));
              }

              stories.add(story.copyWith(author: authorData));
            } catch (e) {
              log('Error fetching story author: $e');
              stories.add(story);
            }
          }
        } catch (e) {
          log('Error processing story: $e');
          continue;
        }
      }

      return stories;
    } on AppwriteException catch (e) {
      log('Error fetching stories: ${e.message}',
          stackTrace: StackTrace.current);
      throw Exception('Failed to fetch stories: ${e.message}');
    } catch (e) {
      log('Unexpected error fetching stories: $e',
          stackTrace: StackTrace.current);
      throw Exception('Failed to fetch stories: $e');
    }
  }

  @override
  Future<void> addStoryView({
    required String storyId,
    required String userId,
  }) async {
    try {
      final storyDoc = await _database.getDocument(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_STORIES_ID'] ?? 'stories',
        documentId: storyId,
      );

      List<String> viewedBy =
          List<String>.from(storyDoc.data['viewedBy'] ?? []);
      int viewCount = storyDoc.data['views'] ?? 0;

      // Check if user already viewed
      if (!viewedBy.contains(userId)) {
        viewedBy.add(userId);
        viewCount += 1;

        await _database.updateDocument(
          databaseId: _databaseId,
          collectionId: dotenv.env['APPWRITE_STORIES_ID'] ?? 'stories',
          documentId: storyId,
          data: {
            'viewedBy': viewedBy,
            'views': viewCount,
          },
        );
      }
    } on AppwriteException catch (e) {
      log('Error adding story view: ${e.message}',
          stackTrace: StackTrace.current);
      throw Exception('Failed to add story view: ${e.message}');
    } catch (e) {
      log('Unexpected error adding story view: $e',
          stackTrace: StackTrace.current);
      throw Exception('Failed to add story view: $e');
    }
  }

  @override
  Future<void> deleteStory({required String storyId}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      final storyDoc = await _database.getDocument(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_STORIES_ID'] ?? 'stories',
        documentId: storyId,
      );

      // Verify user owns the story
      if (storyDoc.data['userId'] != user!.uid) {
        throw Exception("Unauthorized: You can only delete your own stories");
      }

      await _database.deleteDocument(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_STORIES_ID'] ?? 'stories',
        documentId: storyId,
      );
    } on AppwriteException catch (e) {
      log('Error deleting story: ${e.message}', stackTrace: StackTrace.current);
      throw Exception('Failed to delete story: ${e.message}');
    } catch (e) {
      log('Unexpected error deleting story: $e',
          stackTrace: StackTrace.current);
      throw Exception('Failed to delete story: $e');
    }
  }

  @override
  Future<List<StoryModel>> getUserStories({required String userId}) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      final documents = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: dotenv.env['APPWRITE_STORIES_ID'] ?? 'stories',
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('uploadTimestamp'),
        ],
      );

      List<StoryModel> stories = [];

      for (var doc in documents.documents) {
        try {
          final storyData = Map<String, dynamic>.from(doc.data);
          storyData['\$id'] = doc.$id;

          final story = StoryModel.fromJson(storyData);

          // Only include non-expired stories
          if (!story.isExpired) {
            stories.add(story);
          }
        } catch (e) {
          log('Error processing story: $e');
          continue;
        }
      }

      return stories;
    } catch (e) {
      log('Error fetching user stories: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to fetch user stories: $e');
    }
  }
}
