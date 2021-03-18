
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

abstract class AuthenticationRepository{
  Future<FirebaseUser> emailSignIn({@required String email,@required String password});
  Future<FirebaseUser> signInWithGoogle();
  Future<FirebaseUser> signUp(email, password);
  Future<void> signOut();
  Future<bool> isSignedIn();
  Future<FirebaseUser> getUser();

}