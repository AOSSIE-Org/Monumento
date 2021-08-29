import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:monumento/resources/authentication/authentication_repository.dart';
import 'package:monumento/resources/authentication/entities/user_entity.dart';
import 'package:monumento/resources/authentication/firebase_authentication_repository.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/social/entities/comment_entity.dart';
import 'package:monumento/resources/social/entities/notification_entity.dart';
import 'package:monumento/resources/social/entities/post_entity.dart';
import 'package:monumento/resources/social/models/comment_model.dart';
import 'package:monumento/resources/social/models/notification_model.dart';
import 'package:monumento/resources/social/models/post_model.dart';
import 'package:monumento/resources/social/social_repository.dart';
import 'package:uuid/uuid.dart';

class FirebaseSocialRepository implements SocialRepository {
  final FirebaseFirestore _database;
  final AuthenticationRepository _authRepository;
  final FirebaseStorage _storage;

  FirebaseSocialRepository(
      {FirebaseFirestore database,
      AuthenticationRepository authenticationRepository,
      FirebaseStorage storage})
      : _database = database ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _authRepository =
            authenticationRepository ?? FirebaseAuthenticationRepository();

  @override
  Future<List<PostModel>> getInitialFeedPosts() async {
    UserModel currentUser = await _authRepository.getUser();
    //TODO TODO TODO
    QuerySnapshot snap = await _database
        .collection("posts")
        // .where("postFor", arrayContains: currentUser.uid)
        .orderBy("timeStamp", descending: true)
        .limit(10)
        .get();

    List<PostModel> posts = snap.docs
        .map((e) => PostModel.fromEntity(
            entity: PostEntity.fromSnapshot(e), documentSnapshot: e))
        .toList();
    print("$posts");
    return posts;
  }

  @override
  Future<List<PostModel>> getMorePosts({DocumentSnapshot startAfterDoc}) async {
    UserModel currentUser = await _authRepository.getUser();

    QuerySnapshot snap = await _database
        .collection("posts")
        // .where("postFor", arrayContains: currentUser.uid)
        .orderBy("timeStamp", descending: true)
        .startAfterDocument(startAfterDoc)
        .limit(10)
        .get();

    List<PostModel> posts = snap.docs
        .map((e) => PostModel.fromEntity(
            entity: PostEntity.fromSnapshot(e), documentSnapshot: e))
        .toList();

    return posts;
  }

  @override
  Future<PostModel> uploadNewPost(
      {String title, String location, String imageUrl}) async {
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    UserModel user = await _authRepository.getUser();
    // TODO : postFor
    DocumentReference ref = await _database.collection("posts").add({
      "title": title,
      "location": location,
      "imageUrl": imageUrl,
      "timeStamp": timeStamp,
      "author": user.toEntity().toMap(),
      "postFor": user.followers,
      "postByUid": user.uid
    });
    DocumentSnapshot documentSnapshot = await ref.get();

    return PostModel(
        postByUid: user.uid,
        postId: ref.id,
        imageUrl: imageUrl,
        title: title,
        location: location,
        timeStamp: timeStamp,
        documentSnapshot: documentSnapshot,
        author: user);
  }

  @override
  Future<String> uploadImageForUrl({File file, String address}) async {
    String fileName = Uuid().v4();
    UploadTask task =
        _storage.ref().child(address).child("$fileName.jpg").putFile(file);

    TaskSnapshot snapshot = await task.whenComplete(() => null);

    return snapshot.ref.getDownloadURL();
  }

  @override
  Future<String> uploadProfilePicForUrl({File file}) async {
    String fileName = Uuid().v4();

    UploadTask task = _storage
        .ref()
        .child("profilePictures")
        .child("$fileName.jpg")
        .putFile(file);

    TaskSnapshot snapshot = await task.whenComplete(() => null);

    return snapshot.ref.getDownloadURL();
  }

  @override
  Future<List<UserModel>> searchPeople({String searchQuery}) async {
    // TODO: implement dateJoined field.
    String query = searchQuery.toLowerCase().replaceAll(' ', '');
    QuerySnapshot snap = await _database
        .collection("users")
        .where("searchParams", arrayContains: query)
        .limit(10)
        .get();
    // .orderBy("dateJoined",descending: false)
    List<UserModel> users = snap.docs
        .map((e) => UserModel.fromEntity(
            userEntity: UserEntity.fromSnapshot(e), snapshot: e))
        .toList();
    return users;
  }

  @override
  Future<List<UserModel>> getMoreSearchResults(
      {String searchQuery, DocumentSnapshot<Object> startAfterDoc}) async {
    QuerySnapshot snap = await _database
        .collection("users")
        .where("searchParams", arrayContains: searchQuery)
        .orderBy("dateJoined", descending: false)
        .startAfterDocument(startAfterDoc)
        .limit(10)
        .get();
    List<UserModel> users = snap.docs
        .map((e) => UserModel.fromEntity(
            userEntity: UserEntity.fromSnapshot(e), snapshot: e))
        .toList();
    return users;
  }

  @override
  Future<List<CommentModel>> getInitialComments(
      {DocumentReference postDocReference}) async {
    QuerySnapshot snap = await postDocReference
        .collection("comments")
        .orderBy("timeStamp", descending: true)
        .limit(20)
        .get();

    return snap.docs
        .map((e) => CommentModel.fromEntity(
            entity: CommentEntity.fromSnapshot(e), snapshot: e))
        .toList();
  }

  @override
  Future<List<NotificationModel>> getInitialNotifications() async {
    UserModel user = await _authRepository.getUser();

    QuerySnapshot snap = await user.documentSnapshot.reference
        .collection("notifications")
        .orderBy("timeStamp", descending: true)
        .limit(10)
        .get();

    return snap.docs
        .map((e) => NotificationModel.fromEntity(
            entity: NotificationEntity.fromSnapshot(e), documentSnapshot: e))
        .toList();
  }

  @override
  Future<List<CommentModel>> getMoreComments(
      {DocumentReference postDocReference,
      DocumentSnapshot startAfterDoc}) async {
    QuerySnapshot snap = await postDocReference
        .collection("comments")
        .orderBy("timeStamp", descending: true)
        .startAfterDocument(startAfterDoc)
        .limit(10)
        .get();

    return snap.docs
        .map((e) => CommentModel.fromEntity(
            entity: CommentEntity.fromSnapshot(e), snapshot: e))
        .toList();
  }

  @override
  Future<List<NotificationModel>> getMoreNotifications(
      {DocumentSnapshot startAfterDoc}) async {
    UserModel user = await _authRepository.getUser();
    QuerySnapshot snap = await user.documentSnapshot.reference
        .collection("notifications")
        .orderBy("timeStamp", descending: true)
        .startAfterDocument(startAfterDoc)
        .limit(10)
        .get();

    return snap.docs
        .map((e) => NotificationModel.fromEntity(
            entity: NotificationEntity.fromSnapshot(e), documentSnapshot: e))
        .toList();
  }

  @override
  Future<CommentModel> addNewComment(
      {DocumentReference postDocReference, String comment}) async {
    UserModel user = await _authRepository.getUser();
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    DocumentSnapshot postSnap = await postDocReference.get();
    PostModel post =
        PostModel.fromEntity(entity: PostEntity.fromSnapshot(postSnap));

    DocumentReference doc = await postDocReference.collection("comments").add({
      "comment": comment,
      "timeStamp": timeStamp,
      "postInvolvedId": postDocReference.id,
      "author": {
        "name": user.name,
        "username": user.username,
        "uid": user.uid,
        "profilePictureUrl": user.profilePictureUrl,
        "email": user.email
      }
    });
    var notification = NotificationModel(
        notificationType: NotificationType.commentNotification,
        timeStamp: timeStamp,
        userInvolved: user,
        postInvolved: post);

    await addNewNotification(
        targetUser: post.author, notification: notification);
    return CommentModel(
        comment: comment,
        postInvolvedId: postDocReference.id,
        author: user,
        timeStamp: timeStamp);
  }

  @override
  Future<List<PostModel>> getInitialDiscoverPosts() async {
    QuerySnapshot snap = await _database
        .collection("posts")
        .orderBy("timeStamp", descending: true)
        .limit(10)
        .get();

    List<PostModel> posts = snap.docs
        .map((e) => PostModel.fromEntity(
            entity: PostEntity.fromSnapshot(e), documentSnapshot: e))
        .toList();
    print("$posts");
    return posts;
  }

  @override
  Future<List<PostModel>> getMoreDiscoverPosts(
      {DocumentSnapshot startAfterDoc}) async {
    QuerySnapshot snap = await _database
        .collection("posts")
        .orderBy("timeStamp", descending: true)
        .startAfterDocument(startAfterDoc)
        .limit(10)
        .get();

    List<PostModel> posts = snap.docs
        .map((e) => PostModel.fromEntity(
            entity: PostEntity.fromSnapshot(e), documentSnapshot: e))
        .toList();

    return posts;
  }

  @override
  Future<List<PostModel>> getInitialProfilePosts({String uid}) async {
    QuerySnapshot snap = await _database
        .collection("posts")
        .where("postByUid", isEqualTo: uid)
        .orderBy("timeStamp", descending: true)
        .limit(10)
        .get();

    List<PostModel> posts = snap.docs
        .map((e) => PostModel.fromEntity(
            entity: PostEntity.fromSnapshot(e), documentSnapshot: e))
        .toList();

    return posts;
  }

  @override
  Future<List<PostModel>> getMoreProfilePosts(
      {DocumentSnapshot startAfterDoc, String uid}) async {
    QuerySnapshot snap = await _database
        .collection("posts")
        .where("postByUid", isEqualTo: uid)
        .orderBy("timeStamp", descending: true)
        .startAfterDocument(startAfterDoc)
        .limit(10)
        .get();

    List<PostModel> posts = snap.docs
        .map((e) => PostModel.fromEntity(
            entity: PostEntity.fromSnapshot(e), documentSnapshot: e))
        .toList();

    return posts;
  }

  @override
  Future<void> followUser({UserModel targetUser, UserModel currentUser}) async {
    await _database.collection('users').doc(targetUser.uid).update({
      'followers': FieldValue.arrayUnion([currentUser.uid])
    });

    await _database.collection('users').doc(currentUser.uid).update({
      'following': FieldValue.arrayUnion([targetUser.uid])
    });
    var notification = NotificationModel(
        notificationType: NotificationType.followedYou,
        timeStamp: DateTime.now().millisecondsSinceEpoch,
        userInvolved: currentUser);

    await addNewNotification(
        targetUser: targetUser, notification: notification);
  }

  @override
  Future<bool> getFollowStatus(
      {UserModel targetUser, UserModel currentUser}) async {
    DocumentSnapshot targetDoc =
        await _database.collection('users').doc(targetUser.uid).get();

    DocumentSnapshot currentDoc =
        await _database.collection('users').doc(currentUser.uid).get();

    UserModel targetUpdated =
        UserModel.fromEntity(userEntity: UserEntity.fromSnapshot(targetDoc));
    UserModel currentUpdated =
        UserModel.fromEntity(userEntity: UserEntity.fromSnapshot(currentDoc));
    if (targetUpdated.followers.contains(currentUpdated.uid) &&
        currentUpdated.following.contains(targetUpdated.uid)) {
      return true;
    }
    return false;
  }

  @override
  Future<void> unfollowUser(
      {UserModel targetUser, UserModel currentUser}) async {
    await _database.collection('users').doc(targetUser.uid).update({
      'followers': FieldValue.arrayRemove([currentUser.uid])
    });

    await _database.collection('users').doc(currentUser.uid).update({
      'following': FieldValue.arrayRemove([targetUser.uid])
    });
  }

  @override
  Future<NotificationModel> addNewNotification(
      {UserModel targetUser, NotificationModel notification}) async {
    assert(targetUser.uid != null);
    DocumentReference ref = await _database
        .collection('users')
        .doc(targetUser.uid)
        .collection('notifications')
        .add(notification.toEntity().toMap());
    DocumentSnapshot snap = await ref.get();
    NotificationModel addedNotification = NotificationModel.fromEntity(
        entity: NotificationEntity.fromSnapshot(snap), documentSnapshot: snap);
    return addedNotification;
  }

  Future<UserModel> getUserByUid(String uid) async {
    DocumentSnapshot snap = await _database.collection('user').doc(uid).get();

    UserModel user = UserModel.fromEntity(
        userEntity: UserEntity.fromSnapshot(snap), snapshot: snap);
    return user;
  }

  @override
  Future<bool> checkUserNameAvailability({String username}) async {
    QuerySnapshot<Map<String, dynamic>> docs = await _database
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return docs.docs.isEmpty;
  }
}
