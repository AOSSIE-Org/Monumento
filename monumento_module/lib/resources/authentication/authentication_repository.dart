import 'package:meta/meta.dart';
import 'package:monumento/resources/authentication/entities/user_entity.dart';

abstract class AuthenticationRepository {
  Future<UserEntity> emailSignIn(
      {@required String email, @required String password});

  Future<UserEntity> signInWithGoogle();

  Future<UserEntity> signUp({@required String email, @required String password, @required String name,@required String status });

  Future<void> signOut();

  Future<bool> isSignedIn();

  Future<UserEntity> getUser();
}
