import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:monumento/resources/authentication/authentication_repository.dart';
import 'package:monumento/resources/authentication/entities/user_entity.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';

class FirebaseAuthenticationRepository implements AuthenticationRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _database;

  FirebaseAuthenticationRepository({FirebaseAuth firebaseAuth,
    GoogleSignIn googleSignin,
    FirebaseFirestore databaseInstance})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn(),
        _database = databaseInstance ?? FirebaseFirestore.instance;

  Future<UserModel> emailSignIn(
      {@required String email, @required String password}) async {
    UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);

    User user = userCredential.user;
    DocumentSnapshot userDocSnap =
    await _database.collection("users").doc(user.uid).get();
    return UserModel.fromEntity(userEntity:UserEntity.fromSnapshot(userDocSnap),snapshot: userDocSnap);
  }

  Future<UserModel> signInWithGoogle() async {
    print('Google Sign In called');
    final GoogleSignInAccount googleSignInAccount =
    await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    User currentUser = _firebaseAuth.currentUser;
    //TODO : Complete getOrCreateUserDocForGoogleSignIn. Once the user signIns using the Google Provider,
    // take him to the new form where he enters his username, chooses profile picture and reviews other info
    DocumentSnapshot userDocSnap = await getOrCreateUserDocForGoogleSignIn(
        profilePictureUrl: "",
        username: currentUser.email.split("@")[0],
        currentUser: currentUser,
        name: currentUser.displayName,
        status: "");

    return UserModel.fromEntity(userEntity:UserEntity.fromSnapshot(userDocSnap),snapshot: userDocSnap);
  }

  Future<UserModel> signUp({@required String email,
    @required String password,
    @required String name,
    @required String status, @required String username, @required String profilePictureUrl}) async {
    final UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    final User currentUser = _firebaseAuth.currentUser;

    DocumentSnapshot userDocSnap =
    await getOrCreateUserDocForEmailSignup(status: status,
        name: name,
        username: username,
        email: email,
        profilePictureUrl: profilePictureUrl,
        uid: currentUser.uid);

    return UserModel.fromEntity(userEntity:UserEntity.fromSnapshot(userDocSnap),snapshot: userDocSnap);
  }

  Future<void> signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = _firebaseAuth.currentUser;

    return currentUser != null;
  }

  Future<UserModel> getUser() async {
    User currentUser = (_firebaseAuth.currentUser);
    DocumentSnapshot userDocSnap =
    await _database.collection("users").doc(currentUser.uid).get();
    return UserModel.fromEntity(userEntity:UserEntity.fromSnapshot(userDocSnap),snapshot: userDocSnap);
  }

  Future<DocumentSnapshot> getOrCreateUserDocForEmailSignup(
      {String uid, String name, String status, String username, String email, String profilePictureUrl}) async {
    DocumentSnapshot userDocSnap =
    await _database.collection("users").doc(uid).get();
    if (userDocSnap.exists) {
      return userDocSnap;
    }
    List<String> searchParams = getSearchParams(name: name,userName: username);

    await _database.collection("users").doc(uid).set({
      'name': name,
      'uid': uid,
      'profilePictureUrl': profilePictureUrl ?? "",
      'email': email,
      'status': status ?? "",
      'username': username,
      'searchParams': searchParams
    });
    DocumentSnapshot newUserDocSnap =
    await _database.collection("users").doc(uid).get();
    return newUserDocSnap;
  }

  Future<DocumentSnapshot> getOrCreateUserDocForGoogleSignIn(
      {User currentUser, String name, String status, String username, String profilePictureUrl}) async {
    DocumentSnapshot userDocSnap =
    await _database.collection("users").doc(currentUser.uid).get();
    if (userDocSnap.exists) {
      return userDocSnap;
    }
    List<String> searchParams = getSearchParams(name: name,userName: username);


    await _database.collection("users").doc(currentUser.uid).set({
      'name': name,
      'uid': currentUser.uid,
      'profilePictureUrl': profilePictureUrl ?? "",
      'email': currentUser.email,
      'status': status ?? "",
      'username': username,
      'searchParams': searchParams
    });
    DocumentSnapshot newUserDocSnap =
    await _database.collection("users").doc(currentUser.uid).get();
    return newUserDocSnap;
  }

  List<String> getSearchParams({String userName, String name}) {
    List<String> searchParams = [];
    for (int i = 0; i < userName.length; i++) {
      print(userName.substring(0, i + 1));
      searchParams.add(userName.toLowerCase().substring(0, i + 1).replaceAll(' ', ''));
    }
    for (int i = 0; i < name.trim().length; i++) {
      print(name.trim().substring(0, i + 1));
      searchParams.add(name.trim().toLowerCase().substring(0, i + 1).replaceAll(' ', ''));
    }
    return searchParams;
  }
}
