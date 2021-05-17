import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:monumento/resources/authentication/authentication_repository.dart';
import 'package:monumento/resources/authentication/entities/user_entity.dart';

class FirebaseAuthenticationRepository implements AuthenticationRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final Firestore _database;

  FirebaseAuthenticationRepository(
      {FirebaseAuth firebaseAuth,
      GoogleSignIn googleSignin,
      Firestore databaseInstance})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn(),
        _database = databaseInstance ?? Firestore.instance;

  Future<UserEntity> emailSignIn(
      {@required String email, @required String password}) async {
    AuthResult authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = authResult.user;
    DocumentSnapshot userDocSnap = await _database.collection("users").document(user.uid).get();
    return UserEntity.fromSnapshot(userDocSnap);
    // return user;
  }

  Future<UserEntity> signInWithGoogle() async {
    print('Google Sign In called');
    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    FirebaseUser currentUser = await _firebaseAuth.currentUser();
    
    DocumentSnapshot userDocSnap = await getOrCreateUserDoc(currentUser,false);

    return UserEntity.fromSnapshot(userDocSnap);
  }

  Future<UserEntity> signUp({@required String email, @required String password, @required String name,@required String status }) async {
    final AuthResult authResult = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    final FirebaseUser currentUser = await _firebaseAuth.currentUser();

    DocumentSnapshot userDocSnap = await getOrCreateUserDoc(currentUser,true,status: status,name: name);

    return UserEntity.fromSnapshot(userDocSnap);
  }

  Future<void> signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  Future<UserEntity> getUser() async {
    FirebaseUser currentUser =  (await _firebaseAuth.currentUser());
    DocumentSnapshot userDocSnap = await _database.collection("users").document(currentUser.uid).get();
    return UserEntity.fromSnapshot(userDocSnap);
  }

  Future<DocumentSnapshot> getOrCreateUserDoc(FirebaseUser currentUser, bool isEmailSignUp,
      {String name, String status}) async {
     DocumentSnapshot userDocSnap = await _database.collection("users").document(currentUser.uid).get();
    if(userDocSnap.exists){
      return userDocSnap;
    }
    await _database.collection("users").document(currentUser.uid).setData({
      'name': isEmailSignUp ? name : currentUser.displayName,
      'uid':currentUser.uid,
      'profilePictureUrl':'',
      'email':currentUser.email,
      'status': isEmailSignUp ? status : "" ,
    });
    DocumentSnapshot newUserDocSnap = await _database.collection("users").document(currentUser.uid).get();
    return newUserDocSnap;
  }
}
