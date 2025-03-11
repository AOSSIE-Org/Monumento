import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  Future<List<UserModel>> searchPeople({required String searchQuery}) async {
    String query = searchQuery.toLowerCase().replaceAll(' ', '');

    try {
      // Using Appwrite's query syntax
      final documents = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: "users",
        queries: [Query.search('searchParams', query), Query.limit(10)],
      );

      // Convert documents to UserModel objects
      List<UserModel> users = documents.documents
          .map((doc) => UserModel.fromJson(doc.data))
          .toList();

      return users;
    } catch (e) {
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

      List<UserModel> users = documents.documents
          .map((doc) => UserModel.fromJson(doc.data))
          .toList();

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
          databaseId: _databaseId, collectionId: "users", documentId: "67cf30cd0021b2a2c14a");

      UserModel user = UserModel.fromJson(document.data);
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
      // Appwrite doesn't support whereIn directly
      // We need to fetch posts from each followed user and combine them
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
            final postData = doc.data;
            if (postData['postId'] == null) {
              postData['postId'] = doc.$id;
            }

            // Check if post is liked
            if (postData['likesCount'] != null && postData['likesCount'] != 0) {
              try {
                final likeDoc = await _database.getDocument(
                    databaseId: _databaseId,
                    collectionId: "post_likes",//fix
                    documentId: "${doc.$id}_${user.uid}");

                if (likeDoc.data['likedPost'] == true) {
                  postData['isPostLiked'] = true;
                } else {
                  postData['isPostLiked'] = false;
                }
              } catch (e) {
                postData['isPostLiked'] = false;
              }
            }

            allPosts.add(PostModel.fromJson(postData));
          } catch (e) {
            log('Error processing post: $e');
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

    try {
      // Get timestamp from the last post for pagination
      final startAfterDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: "posts",
          documentId: startAfterDocId);

      final timeStamp = startAfterDoc.data['timeStamp'] ?? 0;
      List<String> followingUids = user!.following;
      if (followingUids.isEmpty) {
        return [];
      }

      List<PostModel> allPosts = [];

      // Get posts for each following user
      for (String followingUid in followingUids) {
        final documents = await _database.listDocuments(
            databaseId: _databaseId,
            collectionId: "posts",
            queries: [
              Query.equal('postByUid', followingUid),
              Query.lessThan('timeStamp', timeStamp), // For pagination
              Query.orderDesc('timeStamp'),
              Query.limit(10)
            ]);

        for (var doc in documents.documents) {
          try {
            final postData = doc.data;
            if (postData['postId'] == null) {
              postData['postId'] = doc.$id;
            }

            // Check if post is liked
            if (postData['likesCount'] != null && postData['likesCount'] != 0) {
              try {
                final likeDoc = await _database.getDocument(
                    databaseId: _databaseId,
                    collectionId: "post_likes",//fix
                    documentId: "${doc.$id}_${user.uid}");

                if (likeDoc.data['likedPost'] == true) {
                  postData['isPostLiked'] = true;
                } else {
                  postData['isPostLiked'] = false;
                }
              } catch (e) {
                postData['isPostLiked'] = false;
              }
            }

            allPosts.add(PostModel.fromJson(postData));
          } catch (e) {
            log('Error processing post: $e');
          }
        }
      }

      // Sort by timestamp
      allPosts.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

      return allPosts.take(10).toList();
    } catch (e) {
      log('Error getting more posts: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to get more posts: $e');
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
                  collectionId: "post_likes",//fix
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
                  collectionId: "post_likes",//fix
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

  @override
  Future<void> likePost({required String postId}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    try {
      // Create like document
      await _database.createDocument(
          databaseId: _databaseId,
          collectionId: "post_likes",//fix
          documentId: "${postId}_${user!.uid}",
          data: {
            'author': {
              'uid': user.uid,
              'name': user.name,
              'profilePictureUrl': user.profilePictureUrl,
              'email': user.email,
              'username': user.username,
            },
            'timeStamp': DateTime.now().millisecondsSinceEpoch,
            'postInvoledId': postId,
            'likedPost': true,
          });

      // Increment likes count
      final postDoc = await _database.getDocument(
          databaseId: _databaseId, collectionId: "posts", documentId: postId);

      int currentLikes = postDoc.data['likesCount'] ?? 0;
      await _database.updateDocument(
          databaseId: _databaseId,
          collectionId: "posts",
          documentId: postId,
          data: {
            'likesCount': currentLikes + 1,
          });
    } catch (e) {
      log("Error liking post: $e", stackTrace: StackTrace.current);
      throw Exception("Failed to like post: $e");
    }
  }

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
          collectionId: "post_likes",//fix
          documentId: "${postId}_${user!.uid}",
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

      await _database.createDocument(
          databaseId: _databaseId,
          collectionId: "comments",//fix
          documentId: commentId,
          data: {
            "comment": comment,
            "timeStamp": timeStamp,
            "postInvolvedId": postDocId,
            "author": {
              "name": user?.name ?? "",
              "username": user?.username ?? "",
              "uid": user?.uid ?? "",
              "profilePictureUrl": user?.profilePictureUrl ?? "",
              "email": user?.email ?? "",
            }
          });

      // Get post author for notification
      final postDoc = await _database.getDocument(
          databaseId: _databaseId,
          collectionId: "posts",
          documentId: postDocId);

      Map<String, dynamic> authorData = postDoc.data['author'];
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

      return documents.documents.map((e) {
        Map<String, dynamic> data = e.data;
        data['commentDocId'] = e.$id;
        return CommentModel.fromJson(data);
      }).toList();
    } catch (e) {
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

      return documents.documents.map((e) {
        Map<String, dynamic> data = e.data;
        data['commentDocId'] = e.$id;
        return CommentModel.fromJson(data);
      }).toList();
    } catch (e) {
      log('Error getting more comments: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to get more comments: $e');
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
            collectionId: "users",
            documentId: followingUid);

        List<String> secondaryFollowingUids =
            List<String>.from(followingUserDoc.data['following'] ?? []);

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
              collectionId: "users",
              documentId: secondaryUid);

          recommendedUsers.add(UserModel.fromJson(userDoc.data));

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
              Query.notEqual("uid", currentUser.uid),
              Query.limit(10) // Get more to filter out already followed users
            ]);

        for (var doc in documents.documents) {
          final uid = doc.data['uid'];

          // Skip users the current user already follows
          if (followingUids.contains(uid)) continue;

          // Skip users already in our recommendations
          if (recommendedUsers.any((user) => user.uid == uid)) continue;

          recommendedUsers.add(UserModel.fromJson(doc.data));

          if (recommendedUsers.length == 5) break;
        }
      }

      return recommendedUsers;
    } catch (e) {
      log('Error getting recommended users: $e',
          stackTrace: StackTrace.current);
      throw Exception('Failed to get recommended users: $e');
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
            "imageUrl": imageUrl ?? "",
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
            Query.notEqual("author.uid", user!.uid),
            Query.orderDesc("timeStamp"),
            Query.limit(8)
          ]);

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
                  collectionId: "post_likes",
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
      log('Error getting discover posts: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to get discover posts: $e');
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
          databaseId: _databaseId, collectionId: "users", documentId: user.uid);

      List<String> following =
          List<String>.from(currentUserDoc.data['following'] ?? []);
      if (!following.contains(targetUser.uid)) {
        following.add(targetUser.uid);
        await _database.updateDocument(
            databaseId: _databaseId,
            collectionId: "users",
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
          databaseId: _databaseId, collectionId: "users", documentId: user.uid);

      List<String> following =
          List<String>.from(currentUserDoc.data['following'] ?? []);
      following.remove(targetUser.uid);

      await _database.updateDocument(
          databaseId: _databaseId,
          collectionId: "users",
          documentId: user.uid,
          data: {'following': following});
    } catch (e) {
      log("Error unfollowing user: $e", stackTrace: StackTrace.current);
      throw Exception("Failed to unfollow user: $e");
    }
  }

  @override
  Future<List<PostModel>> getInitialUserPosts({required String uid}) async {
    try {
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

      List<PostModel> posts = [];

      for (var doc in documents.documents) {
        try {
          final data = doc.data;
          if (data['postId'] == null) {
            data['postId'] = doc.$id;
          }

          // Check if post is liked
          if (userLoggedIn &&
              data['likesCount'] != null &&
              data['likesCount'] != 0) {
            try {
              final likeDoc = await _database.getDocument(
                  databaseId: _databaseId,
                  collectionId: "post_likes",
                  documentId: "${doc.$id}_$currentUid");

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
      log('Error getting user posts: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to get user posts: $e');
    }
  }

  @override
  Future<NotificationModel> addNewNotification(
      {required UserModel targetUser,
      required NotificationModel notification}) async {
    try {
      final result = await _database.createDocument(
          databaseId: _databaseId,
          collectionId: "notifications",
          documentId: ID.unique(),
          data: {
            'targetUserId': targetUser.uid,
            'notificationType': notification.notificationType.index,
            'timeStamp': notification.timeStamp,
            'userInvolved': {
              'uid': notification.userInvolved.uid,
              'name': notification.userInvolved.name,
              'username': notification.userInvolved.username,
              'profilePictureUrl': notification.userInvolved.profilePictureUrl,
              'email': notification.userInvolved.email,
            },
          });

      // Return the created notification
      return NotificationModel(
          notificationType: notification.notificationType,
          timeStamp: notification.timeStamp,
          userInvolved: notification.userInvolved,
          postInvolved: notification.postInvolved);
    } catch (e) {
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
          // Ensure notificationId is set
          if (!data.containsKey('notificationId')) {
            data['notificationId'] = doc.$id;
          }
          notifications.add(NotificationModel.fromJson(data));
        } catch (e) {
          log('Error processing notification: $e');
        }
      }

      return notifications;
    } catch (e) {
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
          // Ensure notificationId is set
          if (!data.containsKey('notificationId')) {
            data['notificationId'] = doc.$id;
          }
          notifications.add(NotificationModel.fromJson(data));
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
          collectionId: "monuments",
          documentId: monumentId);

      // Check if user already checked in
      final existingCheckIns = await _database.listDocuments(
          databaseId: _databaseId,
          collectionId: "check_ins",
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
          collectionId: "check_ins",
          documentId: checkInId,
          data: {
            "monumentId": monumentId,
            "userId": user.uid,
            "title": title ?? "",
            "timeStamp": timeStamp
          });

      // Create a post for the check-in
      final location =
          "${monument.data['city'] ?? ''}, ${monument.data['country'] ?? ''}";

      await _database.createDocument(
          databaseId: _databaseId,
          collectionId: "posts",
          documentId: ID.unique(),
          data: {
            "title": title ?? "",
            "location": location,
            "imageUrl": "",
            "author": {
              "name": user.name,
              "username": user.username,
              "uid": user.uid,
              "profilePictureUrl": user.profilePictureUrl,
              "email": user.email,
            },
            "timeStamp": timeStamp,
            "postType": 2, // Check-in post type
            "postByUid": user.uid,
            "likesCount": 0,
            "commentsCount": 0,
          });

      return true;
    } catch (e) {
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
          collectionId: "check_ins",
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

        users.add(UserModel.fromJson(document.data));
      } catch (e) {
        log('Error loading user $connection: $e',
            stackTrace: StackTrace.current);
        // Continue loading other users even if one fails
      }
    }

    return users;
  }
}