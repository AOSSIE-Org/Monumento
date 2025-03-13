import 'dart:async';
import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:monumento/data/models/user_model.dart';
import 'package:monumento/domain/repositories/authentication_repository.dart';

class AppwriteAuthenticationRepository implements AuthenticationRepository {
  final Account _account;
  final Databases _database;

  AppwriteAuthenticationRepository({
    required Account account,
    required Databases database,
  })  : _account = account,
        _database = database;

  @override
  Future<String> getUid() async {
    final user = await _account.get();
    return user.$id;
  }

  @override
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String status,
    required String username,
    required String profilePictureUrl,
  }) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      final userDoc = await getOrCreateUserDocForEmailSignup(
        uid: user.$id,
        name: name,
        username: username,
        status: status,
        email: email,
        profilePictureUrl: profilePictureUrl,
      );

      return UserModel.fromJson(userDoc.data);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  @override
  Future<UserModel?> emailSignIn(
      {required String email, required String password}) async {
    await _account.createEmailPasswordSession(email: email, password: password);
    final user = await _account.get();
    final userDoc = await _database.getDocument(
      databaseId: dotenv.env['APPWRITE_DATABASE_ID'] ?? "",
      collectionId: dotenv.env['APPWRITE_USER_COLLECTION_ID'] ?? "",
      documentId: user.$id,
    );

    return UserModel.fromJson(userDoc.data);
  }

  @override
  Future<String> getEmail() async {
    final user = await _account.get();
    return user.email;
  }

  Future<Document> getOrCreateUserDocForEmailSignup({
    required String uid,
    required String name,
    String? status,
    required String username,
    required String email,
    String? profilePictureUrl,
  }) async {
    // Check if user already exists in the collection
    final existingUsers = await _database.listDocuments(
      databaseId: dotenv.env['APPWRITE_DATABASE_ID'] ?? "",
      collectionId: dotenv.env['APPWRITE_USER_COLLECTION_ID'] ?? "",
      queries: [
        Query.equal("uid", uid),
      ],
    );

    if (existingUsers.documents.isNotEmpty) {
      return existingUsers.documents.first;
    }

    List<String> searchParams = getSearchParams(name: name, userName: username);

    // Create a new user document
    final newUserDoc = await _database.createDocument(
      databaseId: dotenv.env['APPWRITE_DATABASE_ID'] ?? "",
      collectionId: dotenv.env['APPWRITE_USER_COLLECTION_ID'] ?? "",
      documentId: uid,
      data: {
        'name': name,
        'uid': uid,
        'profilePictureUrl': profilePictureUrl ?? "",
        'email': email,
        'status': status ?? "",
        'username': username,
        'searchParams': searchParams,
      },
    );

    return newUserDoc;
  }

  @override
  Future<UserModel> getOrCreateUserDocForGoogleSignIn({
    required String uid,
    required String email,
    required String name,
    String? status,
    required String username,
    String? profilePictureUrl,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<(bool, UserModel?)> getUser() async {
    try {
      // Get the currently authenticated user
      final user = await _account.get();

      // Retrieve user document from Appwrite database
      final userDoc = await _database.getDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID'] ?? "",
        collectionId: dotenv.env['APPWRITE_USER_COLLECTION_ID'] ?? "",
        documentId: user.$id, // Using the user ID from Appwrite auth
      );

      if (userDoc.data.isEmpty) {
        return (true, null);
      }

      return (true, UserModel.fromJson(userDoc.data));
    } catch (e) {
      return (false, null);
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      final user = await _account.get();
      return user.$id.isNotEmpty; // User is signed in if ID exists
    } on AppwriteException {
      return false; // No active session
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    await _account.deleteSession(sessionId: 'current');
  }

  Future<void> signOutFromAllDevices() async {
    await _account.deleteSessions();
  }

//TODO:check this later
  @override
  Future<void> updateEmailPassword(
      {required Map<Object, dynamic> emailPassword}) async {
    try {
      final user = await _account.get(); // Get the current authenticated user
      final userId = user.$id;

      if (emailPassword.keys.first == 'email') {
        final newEmail = emailPassword.values.first as String;
        log("Updating email: $newEmail");

        // Update email in Appwrite Authentication
        await _account.updateEmail(
          email: newEmail,
          password: user.password!,
        ); // Requires current password

        // Update email in Appwrite Database
        await _database.updateDocument(
          databaseId: "monument_db",
          collectionId: "users",
          documentId: userId,
          data: {
            'email': newEmail,
          },
        );
      } else if (emailPassword.keys.first == 'password') {
        final newPassword = emailPassword.values.first as String;
        log("Updating password: $newPassword");

        // Update password in Appwrite Authentication
        await _account.updatePassword(
          password: newPassword,
          oldPassword: user.password!,
        );
      }
    } catch (e) {
      throw Exception("Error updating email or password: $e");
    }
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
}
