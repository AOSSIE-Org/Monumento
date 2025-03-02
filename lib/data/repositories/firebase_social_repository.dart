import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:monumento/data/models/comment_model.dart';
import 'package:monumento/data/models/notification_model.dart';
import 'package:monumento/data/models/post_model.dart';
import 'package:monumento/data/models/user_model.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/domain/repositories/authentication_repository.dart';
import 'package:monumento/domain/repositories/social_repository.dart';
import 'package:monumento/utils/enums.dart';
import 'package:uuid/uuid.dart';

class FirebaseSocialRepository implements SocialRepository {
  final FirebaseFirestore _database;
  final FirebaseStorage _storage;
  final AuthenticationRepository authenticationRepository;

  FirebaseSocialRepository(
      {required this.authenticationRepository,
      FirebaseFirestore? database,
      FirebaseStorage? storage})
      : _database = database ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadImageForUrl(
      {required File file, required String address}) async {
    String fileName = const Uuid().v4();
    UploadTask task =
        _storage.ref().child(address).child("$fileName.jpg").putFile(file);

    TaskSnapshot snapshot = await task.whenComplete(() => null);

    return snapshot.ref.getDownloadURL();
  }

  @override
  Future<String> uploadProfilePicForUrl({required Uint8List fileBytes}) async {
    String fileName = const Uuid().v4();

    UploadTask task = _storage
        .ref()
        .child("profilePictures")
        .child("$fileName.jpg")
        .putData(fileBytes);

    TaskSnapshot snapshot = await task.whenComplete(() => null);

    return snapshot.ref.getDownloadURL();
  }

  @override
  Future<void> updateUserProfile(
      {required Map<Object, dynamic> userInfo}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
    await _database.collection("users").doc(user!.uid).update(userInfo);
  }

  @override
  Future<List<UserModel>> searchPeople({required String searchQuery}) async {
    // TODO: implement dateJoined field.
    String query = searchQuery.toLowerCase().replaceAll(' ', '');
    QuerySnapshot snap = await _database
        .collection("users")
        .where("searchParams", arrayContains: query)
        .limit(10)
        .get();
    // .orderBy("dateJoined",descending: false)
    List<UserModel> users = snap.docs
        .map((e) => UserModel.fromJson(e.data() as Map<String, dynamic>))
        .toList();
    return users;
  }

  @override
  Future<List<UserModel>> getMoreSearchResults(
      {required String searchQuery, required String startAfterDocId}) async {
    DocumentSnapshot startAfterDoc =
        await _database.collection('users').doc(startAfterDocId).get();
    QuerySnapshot snap = await _database
        .collection("users")
        .where("searchParams", arrayContains: searchQuery)
        .orderBy("dateJoined", descending: false)
        .startAfterDocument(startAfterDoc)
        .limit(10)
        .get();
    List<UserModel> users = snap.docs
        .map((e) => UserModel.fromJson(e.data() as Map<String, dynamic>))
        .toList();
    return users;
  }

  @override
  Future<UserModel> getUserByUid({required String uid}) async {
    DocumentSnapshot snap = await _database.collection("users").doc(uid).get();

    UserModel user = UserModel.fromJson(snap.data() as Map<String, dynamic>);
    return user;
  }

  @override
  Future<bool> checkUserNameAvailability({required String username}) async {
    QuerySnapshot<Map<String, dynamic>> docs = await _database
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return docs.docs.isEmpty;
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
    QuerySnapshot snap = await _database
        .collection("posts")
        .where("postByUid", whereIn: followingUids)
        .orderBy("timeStamp", descending: true)
        .limit(5)
        .get();
    List<PostModel> posts = await Future.wait(snap.docs.map((e) async {
      var data = e.data() as Map<String, dynamic>;
      if (data['postId'] == null) {
        data['postId'] = e.id;
      }
      if (data['likesCount'] != null || data['likesCount'] != 0) {
        try {
          var likeDoc = await _database
              .collection('posts')
              .doc(e.id)
              .collection('likes')
              .doc(user.uid)
              .get();
          if (likeDoc.exists) {
            if (likeDoc.data()!['likedPost'] == true) {
              data['isPostLiked'] = true;
            } else {
              data['isPostLiked'] = false;
            }
          } else {
            data['isPostLiked'] = false;
          }
        } catch (e) {
          log("Like doc not found");
          data['isPostLiked'] = false;
        }
      }
      return PostModel.fromJson(data);
    }));
    return posts;
  }

  @override
  Future<List<PostModel>> getMorePosts(
      {required String startAfterDocId}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
    DocumentSnapshot doc = await _database.doc('posts/$startAfterDocId').get();
    List<String> followingUids = user!.following;
    if (followingUids.isEmpty) {
      return [];
    }

    QuerySnapshot snap = await _database
        .collection("posts")
        .where("postByUid", whereIn: followingUids)
        .orderBy("timeStamp", descending: true)
        .startAfterDocument(doc)
        .limit(10)
        .get();

    List<PostModel> posts = snap.docs.map((e) {
      var data = e.data() as Map<String, dynamic>;
      if (data['postId'] == null) {
        data['postId'] = e.id;
      }
      if (data['likesCount'] != null || data['likesCount'] != 0) {
        _database
            .collection('posts')
            .doc(e.id)
            .collection('likes')
            .doc(user.uid)
            .get()
            .then((value) {
          if (value.exists) {
            if (value.data()!['likedPost'] == true) {
              data['isPostLiked'] = true;
            } else {
              data['isPostLiked'] = false;
            }
          } else {
            data['isPostLiked'] = false;
          }
        });
      }
      return PostModel.fromJson(data);
    }).toList();

    return posts;
  }

  @override
  Future<List<PostModel>> getInitialProfilePosts() async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
    String userId = user!.uid;
    List<String> postIds = [];

    QuerySnapshot snap = await _database
        .collection("posts")
        .where("postByUid", isEqualTo: userId)
        // .where("postType", isEqualTo: 0)
        .orderBy("timeStamp", descending: true)
        .limit(10)
        .get();

    List<PostModel> posts = await Future.wait(snap.docs.map((e) async {
      var data = e.data() as Map<String, dynamic>;
      if (data['postId'] == null) {
        data['postId'] = e.id;
      }
      if (data['likesCount'] != null || data['likesCount'] != 0) {
        try {
          var likeDoc = await _database
              .collection('posts')
              .doc(e.id)
              .collection('likes')
              .doc(user.uid)
              .get();
          if (likeDoc.exists) {
            if (likeDoc.data()!['likedPost'] == true) {
              data['isPostLiked'] = true;
            } else {
              data['isPostLiked'] = false;
            }
          } else {
            data['isPostLiked'] = false;
          }
        } catch (e) {
          log("Like doc not found");
          data['isPostLiked'] = false;
        }
      }
      return PostModel.fromJson(data);
    }));
    posts.map((e) => postIds.add(e.postId)).toList();
    await _database.collection("users").doc(userId).update({"posts": postIds});
    return posts;
  }

  @override
  Future<List<PostModel>> getMoreProfilePosts(
      {required String startAfterDocId}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
    DocumentSnapshot doc = await _database.doc('posts/$startAfterDocId').get();
    String userId = user!.uid;

    QuerySnapshot snap = await _database
        .collection("posts")
        .where("postByUid", isEqualTo: userId)
        .orderBy("timeStamp", descending: true)
        .startAfterDocument(doc)
        .limit(10)
        .get();

    List<PostModel> posts = snap.docs.map((e) {
      var data = e.data() as Map<String, dynamic>;
      if (data['postId'] == null) {
        data['postId'] = e.id;
      }
      if (data['likesCount'] != null || data['likesCount'] != 0) {
        _database
            .collection('posts')
            .doc(e.id)
            .collection('likes')
            .doc(user.uid)
            .get()
            .then((value) {
          if (value.exists) {
            if (value.data()!['likedPost'] == true) {
              data['isPostLiked'] = true;
            } else {
              data['isPostLiked'] = false;
            }
          } else {
            data['isPostLiked'] = false;
          }
        });
      }
      return PostModel.fromJson(data);
    }).toList();

    return posts;
  }

  @override
  Future<void> likePost({required String postId}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
    _database
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(user!.uid)
        .set({
      'author': {
        'uid': user.uid,
        'name': user.name,
        'profilePictureUrl': user.profilePictureUrl,
        'email': user.email,
        'username': user.username,
      },
      'timeStamp': FieldValue.serverTimestamp(),
      'postInvoledId': postId,
      'likedPost': true,
    });
    _database.collection('posts').doc(postId).update({
      'likesCount': FieldValue.increment(1),
    });
  }

  @override
  Future<void> unlikePost({required String postId}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
    if (user == null) {
      throw Exception("User not found");
    }

    _database
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(user.uid)
        .set({
      'author': {
        'uid': user.uid,
        'name': user.name,
        'profilePictureUrl': user.profilePictureUrl,
        'email': user.email,
        'username': user.username,
      },
      'timeStamp': FieldValue.serverTimestamp(),
      'postInvoledId': postId,
      'likedPost': false,
    });
    _database.collection('posts').doc(postId).update({
      'likesCount': FieldValue.increment(-1),
    });
  }

  @override
  Future<CommentModel> addNewComment(
      {required String postDocId, required String comment}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    var doc = await _database.collection("posts/$postDocId/comments").add({
      "comment": comment,
      "timeStamp": timeStamp,
      "postInvolvedId": postDocId,
      "author": {
        "name": user?.name,
        "username": user?.username,
        "uid": user?.uid,
        "profilePictureUrl": user?.profilePictureUrl,
        "email": user?.email,
      }
    });

    DocumentSnapshot postDoc =
        await _database.collection('posts').doc(postDocId).get();
    var postData = postDoc.data() as Map<String, dynamic>;
    UserModel postAuthor =
        UserModel.fromJson(postData['author'] as Map<String, dynamic>);

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
      commentDocId: doc.id,
    );
  }

  @override
  Future<List<CommentModel>> getInitialComments(
      {required String postDocId}) async {
    QuerySnapshot snap = await _database
        .collection("posts/$postDocId/comments")
        .orderBy("timeStamp", descending: true)
        .limit(20)
        .get();

    return snap.docs.map((e) {
      var data = e.data() as Map<String, dynamic>;
      data['commentDocId'] = e.id;
      return CommentModel.fromJson(data);
    }).toList();
  }

  @override
  Future<List<CommentModel>> getMoreComments(
      {required String postDocId, required String startAfterDocId}) async {
    DocumentSnapshot startAfterDoc =
        await _database.doc('posts/$postDocId/comments/$startAfterDocId').get();
    QuerySnapshot snap = await _database
        .collection("posts/$postDocId/comments")
        .orderBy("timeStamp", descending: true)
        .startAfterDocument(startAfterDoc)
        .limit(10)
        .get();

    return snap.docs
        .map((e) => CommentModel.fromJson(e.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<UserModel>> getRecommendedUsers() async {
    var (userLoggedIn, currentUser) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
    List<String> followingUids = currentUser!.following;
    // return five users who are not followed by the user, but are followed by the first five users followed by the user
    List<UserModel> users = [];
    for (String uid in followingUids) {
      DocumentSnapshot snap =
          await _database.collection('users').doc(uid).get();
      UserModel user = UserModel.fromJson(snap.data() as Map<String, dynamic>);
      List<String> followingUids = user.following;
      for (String uid in followingUids) {
        DocumentSnapshot snap =
            await _database.collection('users').doc(uid).get();
        UserModel user =
            UserModel.fromJson(snap.data() as Map<String, dynamic>);
        if (!user.followers.contains(user.uid)) {
          users.add(user);
        }
        if (users.contains(currentUser)) {
          users.remove(currentUser);
        }
        // stop when we have 5 users
        if (users.length == 5) {
          break;
        }
      }
    }
    // if we have 0 users, return 5 random users
    if (users.isEmpty) {
      QuerySnapshot snap = await _database
          .collection('users')
          .limit(5)
          .where('uid', isNotEqualTo: currentUser.uid)
          .get();
      users = snap.docs
          .map((e) => UserModel.fromJson(e.data() as Map<String, dynamic>))
          .toList();
    }
    return users;
  }

  @override
  Future<PostModel> uploadNewPost(
      {required String title,
      String? location,
      String? imageUrl,
      required int postType}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    DocumentReference doc = await _database.collection("posts").add({
      "title": title,
      "location": location,
      "imageUrl": imageUrl,
      "author": {
        "name": user?.name,
        "username": user?.username,
        "uid": user?.uid,
        "profilePictureUrl": user?.profilePictureUrl,
        "email": user?.email,
      },
      "timeStamp": timeStamp,
      "postType": postType,
      "postByUid": user?.uid,
      "likesCount": 0,
      "commentsCount": 0,
    });
    return PostModel(
      author: user!,
      postByUid: user.uid,
      title: title,
      location: location,
      imageUrl: imageUrl,
      timeStamp: timeStamp,
      postId: doc.id,
      postType: postType,
      likesCount: 0,
      commentsCount: 0,
    );
  }

  @override
  Future<List<PostModel>> getInitialDiscoverPosts() async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
/*
    Unnecessary check for empty followingUids 

    List<String> followingUids = user!.following;
    if (followingUids.isEmpty) {
    return [];
    }

*/

    QuerySnapshot snap = await _database
        .collection("posts")
        .where("postType", isEqualTo: 0)
        .limit(8)
        .get();
/*chetak's code*/

    // filtering out posts from users other than the current user
    final filteredDocs = snap.docs.where((doc) {
      return !(doc.get("author.uid") == user!.uid);
    }).toList();

    // for (var doc in filteredDocs) {
    //   print("Filtered Document: ${doc.data()}");
    // }
    // print(filteredDocs.length);

    List<PostModel> posts = await Future.wait(filteredDocs.map((e) async {
      var data = e.data() as Map<String, dynamic>;
      if (data['postId'] == null) {
        data['postId'] = e.id;
      }
      if (data['likesCount'] != null || data['likesCount'] != 0) {
        try {
          var likeDoc = await _database
              .collection('posts')
              .doc(e.id)
              .collection('likes')
              .doc(user!.uid)
              .get();
          if (likeDoc.exists) {
            if (likeDoc.data()!['likedPost'] == true) {
              data['isPostLiked'] = true;
            } else {
              data['isPostLiked'] = false;
            }
          } else {
            data['isPostLiked'] = false;
          }
        } catch (e) {
          log("Like doc not found");
          data['isPostLiked'] = false;
        }
      }
      return PostModel.fromJson(data);
    }));
    return posts;
  }

  @override
  Future<void> followUser({required UserEntity targetUser}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }

    if (user!.uid == targetUser.uid) {
      throw Exception("Can't follow urself!");

      // add a scaffoldMessenger for this :/
    }
    /*chetak's code ends */
    await _database.collection('users').doc(targetUser.uid).update({
      'followers': FieldValue.arrayUnion([user.uid])
    });

    await _database.collection('users').doc(user.uid).update({
      'following': FieldValue.arrayUnion([targetUser.uid])
    });
    var notification = NotificationModel(
      notificationType: NotificationType.followedYou,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      userInvolved: user,
    );

    await addNewNotification(
      targetUser: UserModel.fromEntity(targetUser),
      notification: notification,
    );
  }

  @override
  Future<bool> getFollowStatus({required UserEntity targetUser}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
    DocumentSnapshot targetDoc =
        await _database.collection('users').doc(targetUser.uid).get();

    DocumentSnapshot currentDoc =
        await _database.collection('users').doc(user!.uid).get();

    UserModel targetUpdated =
        UserModel.fromEntity(UserEntity.fromSnapshot(targetDoc));
    UserModel currentUpdated =
        UserModel.fromEntity(UserEntity.fromSnapshot(currentDoc));
    if (targetUpdated.followers.contains(currentUpdated.uid) &&
        currentUpdated.following.contains(targetUpdated.uid)) {
      return true;
    }
    return false;
  }

  @override
  Future<void> unfollowUser({required UserEntity targetUser}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
    await _database.collection('users').doc(targetUser.uid).update({
      'followers': FieldValue.arrayRemove([user!.uid])
    });

    await _database.collection('users').doc(user.uid).update({
      'following': FieldValue.arrayRemove([targetUser.uid])
    });
  }

  @override
  Future<List<PostModel>> getInitialUserPosts({required String uid}) async {
    QuerySnapshot snap = await _database
        .collection("posts")
        .where("postByUid", isEqualTo: uid)
        .orderBy("timeStamp", descending: true)
        .limit(10)
        .get();

    List<PostModel> posts = await Future.wait(snap.docs.map((e) async {
      var data = e.data() as Map<String, dynamic>;
      if (data['postId'] == null) {
        data['postId'] = e.id;
      }
      if (data['likesCount'] != null || data['likesCount'] != 0) {
        try {
          var likeDoc = await _database
              .collection('posts')
              .doc(e.id)
              .collection('likes')
              .doc(uid)
              .get();
          if (likeDoc.exists) {
            if (likeDoc.data()!['likedPost'] == true) {
              data['isPostLiked'] = true;
            } else {
              data['isPostLiked'] = false;
            }
          } else {
            data['isPostLiked'] = false;
          }
        } catch (e) {
          log("Like doc not found");
          data['isPostLiked'] = false;
        }
      }
      return PostModel.fromJson(data);
    }));
    return posts;
  }

  @override
  Future<NotificationModel> addNewNotification(
      {required UserModel targetUser,
      required NotificationModel notification}) async {
    DocumentReference ref = await _database
        .collection('users')
        .doc(targetUser.uid)
        .collection('notifications')
        .add(notification.toJson());
    DocumentSnapshot snap = await ref.get();
    NotificationModel addedNotification =
        NotificationModel.fromJson(snap.data() as Map<String, dynamic>);
    return addedNotification;
  }

  @override
  Future<List<NotificationModel>> getInitialNotifications() async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
    QuerySnapshot snap = await _database
        .collection('users')
        .doc(user!.uid)
        .collection('notifications')
        .orderBy('timeStamp', descending: true)
        .limit(10)
        .get();
    List<NotificationModel> notifications = snap.docs
        .map(
            (e) => NotificationModel.fromJson(e.data() as Map<String, dynamic>))
        .toList();
    return notifications;
  }

  @override
  Future<List<NotificationModel>> getMoreNotifications(
      {required String startAfterDocId}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
    DocumentSnapshot startAfterDoc = await _database
        .collection('users')
        .doc(user!.uid)
        .collection('notifications')
        .doc(startAfterDocId)
        .get();
    QuerySnapshot snap = await _database
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('timeStamp', descending: true)
        .startAfterDocument(startAfterDoc)
        .limit(10)
        .get();
    List<NotificationModel> notifications = snap.docs
        .map(
            (e) => NotificationModel.fromJson(e.data() as Map<String, dynamic>))
        .toList();
    return notifications;
  }

  @override
  Future<bool> monumentCheckIn(
      {required String monumentId, String? title}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
    // get monument details
    DocumentSnapshot monumentDoc =
        await _database.collection("monuments").doc(monumentId).get();

    // check if the user has already checked in
    QuerySnapshot snap = await _database
        .collection("users")
        .doc(user?.uid)
        .collection("checkIns")
        .where("monumentId", isEqualTo: monumentId)
        .get();

    if (snap.docs.isNotEmpty) {
      return false;
    }

    // add the check-in to the user's check-ins
    await _database
        .collection("users")
        .doc(user?.uid)
        .collection("checkIns")
        .add({
      "monumentId": monumentId,
      "title": title ?? "",
      "timeStamp": DateTime.now().millisecondsSinceEpoch,
    });

    // add the check-in as a post
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    DocumentReference doc = await _database.collection("posts").add({
      "title": title ?? "",
      "location": monumentDoc['city'] + ", " + monumentDoc['country'],
      "imageUrl": "",
      "author": {
        "name": user?.name,
        "username": user?.username,
        "uid": user?.uid,
        "profilePictureUrl": user?.profilePictureUrl,
        "email": user?.email,
      },
      "timeStamp": timeStamp,
      "postType": 2,
      "postByUid": user?.uid,
      "likesCount": 0,
      "commentsCount": 0,
    });

    return true;
  }

  @override
  Future<bool> checkInStatus({required String monumentId}) async {
    var (userLoggedIn, user) = await authenticationRepository.getUser();
    if (!userLoggedIn) {
      throw Exception("User not logged in");
    }
    QuerySnapshot snap = await _database
        .collection("users")
        .doc(user?.uid)
        .collection("checkIns")
        .where("monumentId", isEqualTo: monumentId)
        .get();
    return snap.docs.isNotEmpty;
  }

  @override
  Future<List<UserModel>> loadUser(List<String> userConnections) async {
    List<UserModel> users = [];
    for (String connection in userConnections) {
      DocumentSnapshot doc =
          await _database.collection("users").doc(connection).get();
      users.add(UserModel.fromJson(doc.data() as Map<String, dynamic>));
    }
    return users;
  }
}
