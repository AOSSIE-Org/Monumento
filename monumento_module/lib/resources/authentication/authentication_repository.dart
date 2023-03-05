import 'package:meta/meta.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';

abstract class AuthenticationRepository {
  Future<UserModel> emailSignIn(
      {@required String email, @required String password});

  Future<Map<String, dynamic>> signInWithGoogle();

  Future<UserModel> signUp(
      {@required String email,
      @required String password,
      @required String name,
      @required String status,
      @required String username,
      @required String profilePictureUrl});

  Future<void> signOut();

  Future<bool> isSignedIn();

  Future<UserModel> getUser();
  Future<UserModel> getOrCreateUserDocForGoogleSignIn(
      {String uid,
      String email,
      String name,
      String status,
      String username,
      String profilePictureUrl});
}
