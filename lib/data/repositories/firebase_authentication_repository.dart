import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:monumento/data/models/user_model.dart';
import 'package:monumento/domain/repositories/authentication_repository.dart';

class FirebaseAuthenticationRepository implements AuthenticationRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _database;

  FirebaseAuthenticationRepository(
      {FirebaseAuth? firebaseAuth,
      GoogleSignIn? googleSignin,
      FirebaseFirestore? databaseInstance})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _database = databaseInstance ?? FirebaseFirestore.instance;

  @override
  Future<UserModel?> emailSignIn(
      {required String email, required String password}) async {
    UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);

    User? user = userCredential.user;
    if (user == null) {
      return null;
    }
    DocumentSnapshot userDocSnap =
        await _database.collection("users").doc(user.uid).get();
    return UserModel.fromJson(userDocSnap.data() as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> signInWithGoogle() async {
    GoogleSignIn googleSignIn;
    // check current platform and set the clientId accordingly
    if (kIsWeb) {
      googleSignIn =
          GoogleSignIn(clientId: dotenv.env['GOOGLE_SIGNIN_WEB_CLIENT_ID']);
    } else {
      if (Platform.isMacOS || Platform.isIOS) {
        googleSignIn =
            GoogleSignIn(clientId: dotenv.env['GOOGLE_SIGNIN_APPLE_CLIENT_ID']);
      } else if (Platform.isAndroid) {
        googleSignIn = GoogleSignIn(
            serverClientId: dotenv.env['SERVER_CLIENT_ID']);
      } else {
        googleSignIn = GoogleSignIn();
      }
    }

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount == null) {
      log("current null");
    }
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    var isNew = await checkUserDoc(userCredential.user!.uid);

    return {
      'isNewUser': isNew,
      'user': UserModel(
        email: userCredential.user!.email!,
        uid: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? "Monumento User",
      )
    };
  }

  @override
  Future<UserModel?> signUp(
      {required String email,
      required String password,
      required String name,
      required String status,
      required String username,
      required String profilePictureUrl}) async {
    final UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    final User? currentUser = userCredential.user;
    if (currentUser == null) {
      throw Exception("Failed to create user");
    }

    DocumentSnapshot userDocSnap = await getOrCreateUserDocForEmailSignup(
      status: status,
      name: name,
      username: username,
      email: email,
      profilePictureUrl: profilePictureUrl,
      uid: currentUser.uid,
    );

    return UserModel.fromJson(userDocSnap.data() as Map<String, dynamic>);
  }

  @override
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  @override
  Future<bool> isSignedIn() async {
    final currentUser = _firebaseAuth.currentUser;

    return currentUser != null;
  }

  @override
  Future<(bool, UserModel?)> getUser() async {
    User? currentUser = (_firebaseAuth.currentUser);
    if (currentUser == null) {
      return (false, null);
    }
    DocumentSnapshot userDocSnap =
        await _database.collection("users").doc(currentUser.uid).get();
    if (!userDocSnap.exists) {
      return (true, null);
    }
    return (
      true,
      UserModel.fromJson(userDocSnap.data() as Map<String, dynamic>)
    );
  }

  @override
  Future<void> updateEmailPassword(
      {required Map<Object, dynamic> emailPassword}) async {
    User? currentUser = (_firebaseAuth.currentUser);
    if (currentUser != null) {
      if (emailPassword.keys.first == 'email') {
        log("${emailPassword.keys.first}:${emailPassword.values.first}");
        await currentUser.verifyBeforeUpdateEmail(emailPassword.values.first);
        await _database
            .collection('users')
            .doc(currentUser.uid)
            .update({'email': emailPassword.values.first});
      }
      log("newPass: ${emailPassword.values.first}");
      await currentUser.updatePassword(emailPassword.values.first);
    }
  }

  Future<DocumentSnapshot> getOrCreateUserDocForEmailSignup({
    required String uid,
    required String name,
    String? status,
    required String username,
    required String email,
    String? profilePictureUrl,
  }) async {
    DocumentSnapshot userDocSnap =
        await _database.collection("users").doc(uid).get();
    if (userDocSnap.exists) {
      return userDocSnap;
    }
    List<String> searchParams = getSearchParams(name: name, userName: username);

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

  @override
  Future<UserModel> getOrCreateUserDocForGoogleSignIn(
      {required String email,
      required String uid,
      required String name,
      String? status,
      required String username,
      String? profilePictureUrl}) async {
    List<String> searchParams = getSearchParams(name: name, userName: username);

    await _database.collection("users").doc(uid).set({
      'name': name,
      'uid': uid,
      'profilePictureUrl': profilePictureUrl ?? "",
      'email': email,
      'status': status ?? "",
      'username': username,
      'searchParams': searchParams,
      'followers': [],
      'following': [],
    });
    DocumentSnapshot newUserDocSnap =
        await _database.collection("users").doc(uid).get();

    return UserModel.fromJson(newUserDocSnap.data() as Map<String, dynamic>);
  }

  List<String> getSearchParams(
      {required String userName, required String name}) {
    List<String> searchParams = [];
    for (int i = 0; i < userName.length; i++) {
      log(userName.substring(0, i + 1));
      searchParams
          .add(userName.toLowerCase().substring(0, i + 1).replaceAll(' ', ''));
    }
    for (int i = 0; i < name.trim().length; i++) {
      log(name.trim().substring(0, i + 1));
      searchParams.add(
          name.trim().toLowerCase().substring(0, i + 1).replaceAll(' ', ''));
    }
    return searchParams;
  }

  Future<bool> checkUserDoc(String uid) async {
    DocumentSnapshot snap = await _database.collection('users').doc(uid).get();
    return !snap.exists;
  }

  @override
  Future sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<String> getUid() async {
    return _firebaseAuth.currentUser!.uid;
  }

  @override
  Future<String> getEmail() async {
    return _firebaseAuth.currentUser!.email!;
  }
}
