
part of 'authentication_bloc.dart';
@immutable
abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();
}

class AppStarted extends AuthenticationEvent {
  @override
  String toString() => 'AppStarted';

  @override
  List<Object> get props => [];
}

class LoggedIn extends AuthenticationEvent {
  @override
  String toString() => 'LoggedIn';

  @override
  List<Object> get props => [];
}

class LogOutPressed extends AuthenticationEvent {
  @override
  String toString() => 'LoggedOut';

  @override
  List<Object> get props => [];
}

class LoggedOut extends AuthenticationEvent {
  @override
  String toString() => 'LoggedOut';

  @override
  List<Object> get props => [];
}
//
// class LoginWithEmailPressed extends AuthenticationEvent {
//   final String email;
//   final String password;
//
//   LoginWithEmailPressed({@required this.email, @required this.password});
//
//   @override
//   List<Object> get props => [email,password];
//
//   @override
//   String toString() {
//     return 'LoginWithCredentialsPressed { email: $email, password: $password }';
//   }
// }
//
// class LoginWithGooglePressed extends AuthenticationEvent {
//   @override
//   String toString() => 'LoginWithGooglePressed';
//
//   @override
//   List<Object> get props => [];
// }
//
