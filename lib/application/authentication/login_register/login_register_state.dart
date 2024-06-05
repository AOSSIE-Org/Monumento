part of 'login_register_bloc.dart';

sealed class LoginRegisterState extends Equatable {
  const LoginRegisterState();

  @override
  List<Object> get props => [];
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

  const LoginSuccess(this.user);

  @override
  String toString() => 'LogInSuccess { displayName: ${user.email} }';

  @override
  List<Object> get props => [user.email];
}

class SigninWithGoogleSuccess extends LoginRegisterState {
  final UserModel user;
  final bool isNewUser;

  const SigninWithGoogleSuccess({required this.user, required this.isNewUser});

  @override
  String toString() =>
      'SigninWithGoogleSuccess { displayName: ${user.email} , isUserCreate: $isNewUser }';

  @override
  List<Object> get props => [user.email];
}

class SigninWithGoogleFailed extends LoginRegisterState {
  final String message;

  @override
  List<Object> get props => [message];

  const SigninWithGoogleFailed({
    required this.message,
  });
}

class LoginFailed extends LoginRegisterState {
  final String message;

  @override
  List<Object> get props => [message];

  const LoginFailed({
    required this.message,
  });
}

class LogOutSuccess extends LoginRegisterState {
  const LogOutSuccess();

  @override
  String toString() => 'Logged Out';

  @override
  List<Object> get props => [];
}

class SignUpSuccess extends LoginRegisterState {
  final UserModel user;

  const SignUpSuccess(this.user);

  @override
  String toString() => 'SignUpSuccess { displayName: ${user.email} }';

  @override
  List<Object> get props => [user.email];
}

class SignUpFailed extends LoginRegisterState {
  const SignUpFailed({required this.message});
  final String message;

  @override
  String toString() => 'SignUp Failed';

  @override
  List<Object> get props => [];
}

class LoginRegisterLoading extends LoginRegisterState {
  @override
  List<Object> get props => [];
}

class ResetPasswordFailed extends LoginRegisterState {
  final String message;

  const ResetPasswordFailed({required this.message});

  @override
  String toString() => 'ResetPasswordFailed';

  @override
  List<Object> get props => [message];
}

class ResetPasswordSuccess extends LoginRegisterState {
  @override
  String toString() => 'ResetPasswordSuccess';

  @override
  List<Object> get props => [];
}
