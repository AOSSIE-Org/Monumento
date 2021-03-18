part of 'login_register_bloc.dart';

@immutable
abstract class LoginRegisterState extends Equatable {
  const LoginRegisterState();
}

class LoginRegisterInitial extends LoginRegisterState {
  @override
  String toString() => 'Login Initial';

  @override
  List<Object> get props => [];
}

class LoggingIn extends LoginRegisterState {
  @override
  List<Object> get props => [];
}

class LoginSuccess extends LoginRegisterState {
  final FirebaseUser user;

  LoginSuccess(this.user);

  @override
  String toString() => 'LogInSuccess { displayName: ${user.email} }';

  @override
  List<Object> get props => [user.email];
}
class LoginFailed extends LoginRegisterState {

  LoginFailed();

  @override
  String toString() => 'Login Failed';

  @override
  List<Object> get props => [];
}
class LogOutSuccess extends LoginRegisterState {

  LogOutSuccess();

  @override
  String toString() => 'Logged Out';

  @override
  List<Object> get props => [];
}
class SignUpSuccess extends LoginRegisterState {
  final FirebaseUser user;

  SignUpSuccess(this.user);

  @override
  String toString() => 'SignUpSuccess { displayName: ${user.email} }';

  @override
  List<Object> get props => [user.email];
}
class SignUpFailed extends LoginRegisterState {
  SignUpFailed();

  @override
  String toString() => 'SignUp Failed';

  @override
  List<Object> get props => [];
}