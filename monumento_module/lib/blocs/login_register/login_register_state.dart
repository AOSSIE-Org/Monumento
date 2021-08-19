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
  final UserModel user;

  LoginSuccess(this.user);

  @override
  String toString() => 'LogInSuccess { displayName: ${user.email} }';

  @override
  List<Object> get props => [user.email];
}

class SigninWithGoogleSuccess extends LoginRegisterState {
  final UserModel user;
  final bool isNewUser;

  SigninWithGoogleSuccess({this.user, @required this.isNewUser});

  @override
  String toString() =>
      'SigninWithGoogleSuccess { displayName: ${user.email} , isUserCreate: $isNewUser }';

  @override
  List<Object> get props => [user.email];
}

class LoginFailed extends LoginRegisterState {
  final String message;

  @override
  List<Object> get props => [message];

  const LoginFailed({
    @required this.message,
  });
}

class LogOutSuccess extends LoginRegisterState {
  LogOutSuccess();

  @override
  String toString() => 'Logged Out';

  @override
  List<Object> get props => [];
}

class SignUpSuccess extends LoginRegisterState {
  final UserModel user;

  SignUpSuccess(this.user);

  @override
  String toString() => 'SignUpSuccess { displayName: ${user.email} }';

  @override
  List<Object> get props => [user.email];
}

class SignUpFailed extends LoginRegisterState {
  SignUpFailed({@required this.message});
  final String message;

  @override
  String toString() => 'SignUp Failed';

  @override
  List<Object> get props => [];
}

class LoginRegisterLoading extends LoginRegisterState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}
