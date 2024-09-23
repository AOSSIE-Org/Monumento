import 'package:monumento/data/models/user_model.dart';

abstract interface class AuthenticationRepository {
  Future<UserModel?> emailSignIn(
      {required String email, required String password});

  Future<Map<String, dynamic>> signInWithGoogle();

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String status,
    required String username,
    required String profilePictureUrl,
  });

  Future<void> signOut();

  Future<bool> isSignedIn();

  Future<(bool, UserModel?)> getUser();

  Future<String> getUid();

  Future<String> getEmail();

  Future<UserModel> getOrCreateUserDocForGoogleSignIn({
    required String uid,
    required String email,
    required String name,
    String? status,
    required String username,
    String? profilePictureUrl,
  });

  Future sendPasswordResetEmail({required String email});
  
  Future<void> updateEmailPassword({required Map<Object,dynamic> emailPassword});
}
