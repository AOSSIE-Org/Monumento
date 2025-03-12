import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:monumento/data/models/comment_model.dart';
import 'package:monumento/data/models/notification_model.dart';
import 'package:monumento/data/models/post_model.dart';
import 'package:monumento/data/models/user_model.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/domain/repositories/authentication_repository.dart';
import 'package:monumento/domain/repositories/social_repository.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/constants.dart';
import 'package:monumento/utils/enums.dart';
import 'package:uuid/uuid.dart';

class FirebaseSocialRepository implements SocialRepository {
  final Databases _database;
  final Storage _storage;
  final AuthenticationRepository authenticationRepository;

  // Bucket ID for Appwrite storage
  final String _imagesBucketId = dotenv.env['APPWRITE_BUCKET_ID'] ?? 'default';
  final String _projectId = dotenv.env['APPWRITE_PROJECT_ID'] ?? 'defalut';
  final String _databaseId = "dbmonumento";

  FirebaseSocialRepository(
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
      final result = await _storage.createFile(
        bucketId: _imagesBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(
          path: file.path,
          filename: newFilename,
        ),
      );

      // Get file view URL
      String fileId = result.$id;

      return "https://cloud.appwrite.io/v1/storage/buckets/$_imagesBucketId/files/$fileId/view?project=$_projectId";
    } catch (e) {
      log('Error uploading image: $e', stackTrace: StackTrace.current);
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

      return "https://cloud.appwrite.io/v1/storage/buckets/$_imagesBucketId/files/$fileId/view?project=$_projectId";
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
      collectionId: "users",
      documentId: "67cf30cd0021b2a2c14a",
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
        collectionId: "users",
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
          collectionId: "users",
          documentId: startAfterDocId);

      // Then get documents after it
      // Appwrite doesn't have startAfter like Firebase, so we need to use cursor-based pagination
      // Get the date joined from the cursor document
      final dateJoined = startAfterDoc.data['dateJoined'] ?? 0;

      final documents = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: "users",
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
          databaseId: _databaseId, collectionId: "users", documentId: uid);

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
          collectionId: "users",
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
      var (userLoggedIn, user) = await authenticationRepository.getUser();
      if (!userLoggedIn) {
        throw Exception("User not logged in");
      }

      int timeStamp = DateTime.now().millisecondsSinceEpoch;

      print("Creating post with imageUrl: $imageUrl");
      print(title);
      print(timeStamp);
      print(user?.uid);

      final result = await _database.createDocument(
          databaseId: _databaseId,
          collectionId: "posts",
          documentId: ID.unique(),
          data: {
            "title": title,
            "location": location ?? "",
            "imageUrl": imageUrl ?? null,
            "author": "67cf30cd0021b2a2c14a",
            "timeStamp": timeStamp,
            "postType": postType,
            "postByUid": "67cf30cd0021b2a2c14a" ?? "",
            "likesCount": 0,
            "commentsCount": 0,
          });

      print("Post created successfully with ID: ${result.$id}");

      return PostModel(
        author: user!,
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
    } catch (e) {
      print(e);
      log("Error creating post: $e", stackTrace: StackTrace.current);
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
          collectionId: "posts",
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

            if (authorData['email'] == null) {
              authorData['email'] = '';
            }

            if (authorData['name'] == null) {
              authorData['name'] = 'Unknown User';
            }

            if (authorData['status'] == null) {
              authorData['status'] = '';
            }

            // Convert followers, following, posts to List<String> if they exist
            if (authorData.containsKey('followers')) {
              if (authorData['followers'] == null) {
                authorData['followers'] = <String>[];
              } else if (authorData['followers'] is! List) {
                authorData['followers'] = <String>[];
              }
            } else {
              authorData['followers'] = <String>[];
            }

            if (authorData.containsKey('following')) {
              if (authorData['following'] == null) {
                authorData['following'] = <String>[];
              } else if (authorData['following'] is! List) {
                authorData['following'] = <String>[];
              }
            } else {
              authorData['following'] = <String>[];
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
              timeStamp: data['timeStamp'] ?? 0,
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
          collectionId: "users",
          documentId: targetUser.uid);

      List<String> followers =
          List<String>.from(targetUserDoc.data['followers'] ?? []);
      if (!followers.contains(user.uid)) {
        followers.add(user.uid);
        await _database.updateDocument(
            databaseId: _databaseId,
            collectionId: "users",
            documentId: targetUser.uid,
            data: {'followers': followers});
      }

      // Add to current user's following
      final currentUserDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: "users",
          documentId: "67cf30cc001b068d3fb8");

      List<String> following =
          List<String>.from(currentUserDoc.data['following'] ?? []);
      if (!following.contains(targetUser.uid)) {
        following.add(targetUser.uid);
        await _database.updateDocument(
            databaseId: _databaseId,
            collectionId: "users",
            documentId: "67cf30cc001b068d3fb8",
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
          collectionId: "users",
          documentId: targetUser.uid);

      // Get current user document
      final currentDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: "users",
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
          collectionId: "users",
          documentId: targetUser.uid);

      List<String> followers =
          List<String>.from(targetUserDoc.data['followers'] ?? []);
      followers.remove(user!.uid);

      await _database.updateDocument(
          databaseId: _databaseId,
          collectionId: "users",
          documentId: targetUser.uid,
          data: {'followers': followers});

      // Remove from current user's following
      final currentUserDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: "users",
          documentId: "67cf30cc001b068d3fb8");

      List<String> following =
          List<String>.from(currentUserDoc.data['following'] ?? []);
      following.remove(targetUser.uid);

      await _database.updateDocument(
          databaseId: _databaseId,
          collectionId: "users",
          documentId: "67cf30cc001b068d3fb8",
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
    // monumentId = "67d0920700165b44a10d";
    try {
      // Get monument details
      final monument = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: "monuments",
          documentId: monumentId);

      // Check if user already checked in
      final existingCheckIns = await _database.listDocuments(
          databaseId: _databaseId,
          collectionId: "checkIn",
          queries: [
            Query.equal("monumentId", monumentId),
            Query.equal("userId", user!.uid)
          ]);

      if (existingCheckIns.documents.isNotEmpty) {
        return false; // Already checked in
      }

      // Create a check-in
      final checkInId = ID.unique();
      final timeStamp = DateTime.now().millisecondsSinceEpoch;

      await _database.createDocument(
          databaseId: _databaseId,
          collectionId: "checkIn",
          documentId: checkInId,
          data: {
            "monumentId": monumentId,
            "userId": user?.uid,
            "title": title ?? "",
            "timeStamp": timeStamp
          });

      // Create a post for the check-in
      final location =
          "${monument.data['city'] ?? ""}, ${monument.data['country'] ?? ""}";

      await _database.createDocument(
          databaseId: _databaseId,
          collectionId: "posts",
          documentId: ID.unique(),
          data: {
            "title": title ?? "",
            "location": location,
            "imageUrl": null,
            "author": user?.uid,
            "timeStamp": timeStamp,
            "postType": 2, // Check-in post type
            "postByUid": user?.uid,
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
          collectionId: "checkIn",
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
            collectionId: "users",
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
          collectionId: "posts",
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

            if (authorData['email'] == null) {
              authorData['email'] = '';
            }

            if (authorData['name'] == null) {
              authorData['name'] = 'Unknown User';
            }

            if (authorData['status'] == null) {
              authorData['status'] = '';
            }

            // Convert followers, following, posts to List<String> if they exist
            if (authorData.containsKey('followers')) {
              if (authorData['followers'] == null) {
                authorData['followers'] = <String>[];
              } else if (authorData['followers'] is! List) {
                authorData['followers'] = <String>[];
              }
            } else {
              authorData['followers'] = <String>[];
            }

            if (authorData.containsKey('following')) {
              if (authorData['following'] == null) {
                authorData['following'] = <String>[];
              } else if (authorData['following'] is! List) {
                authorData['following'] = <String>[];
              }
            } else {
              authorData['following'] = <String>[];
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
              timeStamp: data['timeStamp'] ?? 0,
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

//postsModel error see from above
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
            Query.equal("targetUserId", "67cf30cc001b068d3fb8"),
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
                collectionId: "users",
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
                  collectionId: "posts",
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
                collectionId: "users",
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
                  collectionId: "posts",
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
      List<String> followingUids = [currentUser!.uid];
      List<UserModel> recommendedUsers = [];

      // Get users followed by users the current user follows
      for (String followingUid in followingUids) {
        final followingUserDoc = await _database.getDocument(
            databaseId: _databaseId,
            collectionId: "users",
            documentId: followingUid);

        List<String> secondaryFollowingUids =
            List<String>.from(followingUserDoc.data['following'] ?? []);
        print(secondaryFollowingUids);
        for (String secondaryUid in secondaryFollowingUids) {
          // Skip if this is the current user
          if (secondaryUid == currentUser!.uid) continue;

          // Skip if the current user already follows this user
          if (followingUids.contains(secondaryUid)) continue;

          // Skip if we already added this user to recommendations
          if (recommendedUsers.any((user) => user.uid == secondaryUid))
            continue;

          final userDoc = await _database.getDocument(
              databaseId: _databaseId,
              collectionId: "users",
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
            collectionId: "users",
            queries: [
              Query.notEqual("\$id", currentUser!.uid),
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

////////////////////////////////////////notification and like///////////////////////
  @override
  Future<void> likePost({required String postId}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      // Create the unique document ID for this like
      String likeDocId = "${postId}_${user!.uid}".substring(0, 36);
      bool shouldIncrementCount = false;

      try {
        // Check if document already exists
        final existingLikeDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: "postLikes",
          documentId: likeDocId,
        );

        // Document exists - check if we need to update it
        if (existingLikeDoc.data['likedPost'] != true) {
          // Only update if it's not already liked
          await _database.updateDocument(
            databaseId: _databaseId,
            collectionId: "postLikes",
            documentId: likeDocId,
            data: {
              'likedPost': true,
              'timeStamp': DateTime.now().millisecondsSinceEpoch,
            }
          );
          shouldIncrementCount = true;
        }
      } catch (e) {
        // Document doesn't exist - create a new like document
        await _database.createDocument(
          databaseId: _databaseId,
          collectionId: "postLikes",
          documentId: likeDocId,
          data: {
            'author': user.uid,
            'timeStamp': DateTime.now().millisecondsSinceEpoch,
            'postInvolvedId': postId,  // Fixed typo from 'postInvoledId'
            'likedPost': true,
          }
        );
        shouldIncrementCount = true;
      }

      // Only increment count if we actually added a new like
      if (shouldIncrementCount) {
        final postDoc = await _database.getDocument(
          databaseId: _databaseId, 
          collectionId: "posts", 
          documentId: postId
        );

        int currentLikes = postDoc.data['likesCount'] ?? 0;
        await _database.updateDocument(
          databaseId: _databaseId,
          collectionId: "posts",
          documentId: postId,
          data: {
            'likesCount': currentLikes + 1,
          }
        );
      }
      
      // Add notification logic here if needed
      
    } catch (e) {
      log("Error liking post: $e", stackTrace: StackTrace.current);
      throw Exception("Failed to like post: $e");
    }
  }
//check here later 
  @override
  Future<void> unlikePost({required String postId}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      // Update like document to false
      await _database.updateDocument(
          databaseId: _databaseId,
          collectionId: "postLikes", // Original collection name
          documentId: "${postId}_${user!.uid}".substring(0, 36),
          data: {
            'likedPost': false,
          });

      // Decrement likes count
      final postDoc = await _database.getDocument(
          databaseId: _databaseId, collectionId: "posts", documentId: postId);

      int currentLikes = postDoc.data['likesCount'] ?? 0;
      await _database.updateDocument(
          databaseId: _databaseId,
          collectionId: "posts",
          documentId: postId,
          data: {
            'likesCount': currentLikes - 1 > 0 ? (currentLikes - 1) : 0,
          });
    } catch (e) {
      log("Error unliking post: $e", stackTrace: StackTrace.current);
      throw Exception("Failed to unlike post: $e");
    }
  }

  //pain///////////////////////////////////////////////////////////////////////
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

    try {
      List<PostModel> allPosts = [];

      // Get posts for each following user
      for (String followingUid in followingUids) {
        final documents = await _database.listDocuments(
            databaseId: _databaseId,
            collectionId: "posts",
            queries: [
              Query.equal('postByUid', followingUid),
              Query.orderDesc('timeStamp'),
              Query.limit(5)
            ]);

        for (var doc in documents.documents) {
          try {
            // Create a mutable copy of the data
            final data = Map<String, dynamic>.from(doc.data);

            // Ensure postId is set
            data['postId'] = doc.$id;
            print(data['postId']);
            // Check if post is liked
            if (data['likesCount'] != null && data['likesCount'] > 0) {
              try {
                final likeDoc = await _database.getDocument(
                    databaseId: _databaseId,
                    collectionId: "postLikes",
                    documentId: "${doc.$id}_${user.uid}".substring(0, 36));

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
                    collectionId: "users",
                    documentId: data['author']);

                Map<String, dynamic> authorData =
                    Map<String, dynamic>.from(authorDoc.data);
                authorData['uid'] = authorData['uid'] ?? authorDoc.$id;

                // Handle followers, following, posts fields
                if (authorData['followers'] == null) {
                  authorData['followers'] = <String>[];
                } else if (authorData['followers'] is Map) {
                  authorData['followers'] = <String>[];
                } else if (authorData['followers'] is List) {
                  authorData['followers'] = List<String>.from(
                      authorData['followers'].map((item) => item.toString()));
                }

                if (authorData['following'] == null) {
                  authorData['following'] = <String>[];
                } else if (authorData['following'] is Map) {
                  authorData['following'] = <String>[];
                } else if (authorData['following'] is List) {
                  authorData['following'] = List<String>.from(
                      authorData['following'].map((item) => item.toString()));
                }

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

              // Handle lists
              if (authorData['followers'] == null) {
                authorData['followers'] = <String>[];
              } else if (authorData['followers'] is Map) {
                authorData['followers'] = <String>[];
              } else if (authorData['followers'] is List) {
                authorData['followers'] = List<String>.from(
                    authorData['followers'].map((item) => item.toString()));
              }

              if (authorData['following'] == null) {
                authorData['following'] = <String>[];
              } else if (authorData['following'] is Map) {
                authorData['following'] = <String>[];
              } else if (authorData['following'] is List) {
                authorData['following'] = List<String>.from(
                    authorData['following'].map((item) => item.toString()));
              }

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
              timeStamp: data['timeStamp'] ?? 0,
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
          collectionId: "posts",
          documentId: startAfterDocId);
      final startTimestamp = startDoc.data['timeStamp'];

      List<PostModel> allPosts = [];

      // Get more posts for each following user
      for (String followingUid in followingUids) {
        final documents = await _database.listDocuments(
            databaseId: _databaseId,
            collectionId: "posts",
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
                final likeDoc = await _database.getDocument(
                    databaseId: _databaseId,
                    collectionId: "postLikes",
                    documentId: "${doc.$id}_${user.uid}".substring(0, 36));

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
                    collectionId: "users",
                    documentId: data['author']);

                Map<String, dynamic> authorData =
                    Map<String, dynamic>.from(authorDoc.data);
                authorData['uid'] = authorData['uid'] ?? authorDoc.$id;

                // Handle followers, following, posts fields
                if (authorData['followers'] == null) {
                  authorData['followers'] = <String>[];
                } else if (authorData['followers'] is Map) {
                  authorData['followers'] = <String>[];
                } else if (authorData['followers'] is List) {
                  authorData['followers'] = List<String>.from(
                      authorData['followers'].map((item) => item.toString()));
                }

                if (authorData['following'] == null) {
                  authorData['following'] = <String>[];
                } else if (authorData['following'] is Map) {
                  authorData['following'] = <String>[];
                } else if (authorData['following'] is List) {
                  authorData['following'] = List<String>.from(
                      authorData['following'].map((item) => item.toString()));
                }

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

              // Handle lists
              if (authorData['followers'] == null) {
                authorData['followers'] = <String>[];
              } else if (authorData['followers'] is Map) {
                authorData['followers'] = <String>[];
              } else if (authorData['followers'] is List) {
                authorData['followers'] = List<String>.from(
                    authorData['followers'].map((item) => item.toString()));
              }

              if (authorData['following'] == null) {
                authorData['following'] = <String>[];
              } else if (authorData['following'] is Map) {
                authorData['following'] = <String>[];
              } else if (authorData['following'] is List) {
                authorData['following'] = List<String>.from(
                    authorData['following'].map((item) => item.toString()));
              }

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
              timeStamp: data['timeStamp'] ?? 0,
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
        collectionId: "posts",
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
              final likeDoc = await _database.getDocument(
                  databaseId: _databaseId,
                  collectionId: "postLikes", //fix
                  documentId: "${doc.$id}_${user.uid}");

              if (likeDoc.data['likedPost'] == true) {
                data['isPostLiked'] = true;
              } else {
                data['isPostLiked'] = false;
              }
            } catch (e) {
              log("Like doc not found");
              data['isPostLiked'] = false;
            }
          }

          posts.add(PostModel.fromJson(data));
        } catch (e) {
          log('Error processing post: $e');
        }
      }

      // Update user's posts list
      await _database.updateDocument(
          databaseId: _databaseId,
          collectionId: "users",
          documentId: user.uid,
          data: {"posts": postIds});

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
          collectionId: "posts",
          documentId: startAfterDocId);

      final timeStamp = startAfterDoc.data['timeStamp'] ?? 0;

      final documents = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: "posts",
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
              final likeDoc = await _database.getDocument(
                  databaseId: _databaseId,
                  collectionId: "postLikes", //fix
                  documentId: "${doc.$id}_${user.uid}");

              if (likeDoc.data['likedPost'] == true) {
                data['isPostLiked'] = true;
              } else {
                data['isPostLiked'] = false;
              }
            } catch (e) {
              data['isPostLiked'] = false;
            }
          }

          posts.add(PostModel.fromJson(data));
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
/////////////////////////this part needs to be worked on//////////////////
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
          collectionId: "comments", //fix
          documentId: commentId,
          data: {
            "comment": comment ?? "",
            "timeStamp": timeStamp ?? 0,
            "postInvolvedId": postDocId,
            "author": "67cf30cd0021b2a2c14a" ?? "",
          });

      // Get post author for notification
      final postDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: "posts",
          documentId: postDocId);

      Map<String, dynamic> authorData = postDoc.data['author'];
      authorData['uid'] = authorData['uid'] ?? postDoc.$id;
      UserModel postAuthor = UserModel.fromJson(authorData);

      // Create notification
      var notification = NotificationModel(
        notificationType: NotificationType.commentNotification,
        timeStamp: DateTime.now().millisecondsSinceEpoch,
        userInvolved: user!,
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
          collectionId: "comments",
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
          collectionId: "comments",
          documentId: startAfterDocId);

      final timeStamp = startAfterDoc.data['timeStamp'] ?? 0;

      final documents = await _database.listDocuments(
          databaseId: _databaseId,
          collectionId: "comments",
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
}
