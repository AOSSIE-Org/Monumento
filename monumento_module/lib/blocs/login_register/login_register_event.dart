part of 'login_register_bloc.dart';

abstract class LoginRegisterEvent extends Equatable {
  const LoginRegisterEvent();
}

class LogOutEvent extends LoginRegisterEvent {
  @override
  String toString() => 'LoggedOut';

  @override
  List<Object> get props => [];
}

class LoginWithEmailPressed extends LoginRegisterEvent {
  final String email;
  final String password;

  LoginWithEmailPressed({@required this.email, @required this.password});

  @override
  List<Object> get props => [email, password];

  @override
  String toString() {
    return 'LoginWithCredentialsPressed { email: $email, password: $password }';
  }
}

class LoginWithGooglePressed extends LoginRegisterEvent {
  @override
  String toString() => 'LoginWithGooglePressed';

  @override
  List<Object> get props => [];
}

class SignUpWithEmailPressed extends LoginRegisterEvent {
  final String email;
  final String password;
  final String name;
  final String status;
  final String username;
  final File profilePictureFile;

  SignUpWithEmailPressed(
      {@required this.email,
      @required this.password,
      @required this.name,
      @required this.status,
      @required this.username,
      @required this.profilePictureFile});

  @override
  List<Object> get props => [email, password];

  @override
  String toString() {
    return 'SignUpWithEmailPressed { email: $email, password: $password }';
  }
}
