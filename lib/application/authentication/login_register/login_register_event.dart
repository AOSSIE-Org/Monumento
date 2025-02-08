part of 'login_register_bloc.dart';

sealed class LoginRegisterEvent extends Equatable {
  const LoginRegisterEvent();

  @override
  List<Object> get props => [];
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

  const LoginWithEmailPressed({required this.email, required this.password});

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
  final Uint8List? profilePictureFile;

  const SignUpWithEmailPressed({
    required this.email,
    required this.password,
    required this.name,
    required this.status,
    required this.username,
    this.profilePictureFile,
  });

  @override
  List<Object> get props => [email, password];

  @override
  String toString() {
    return 'SignUpWithEmailPressed { email: $email, password: $password }';
  }
}

class ResetPasswordButtonPressed extends LoginRegisterEvent {
  final String email;

  const ResetPasswordButtonPressed({required this.email});

  @override
  String toString() => 'ResetPasswordButtonPressed';

  @override
  List<Object> get props => [email];
}

class SaveOnboardingDetails extends LoginRegisterEvent {
  final String name;
  final String username;
  final String status;
  final Uint8List? profilePictureFile;

  const SaveOnboardingDetails({
    required this.name,
    required this.status,
    required this.username,
    this.profilePictureFile,
  });

  @override
  List<Object> get props => [name, status];

  @override
  String toString() {
    return 'SaveOnboardingDetails { name: $name, status: $status }';
  }
}
