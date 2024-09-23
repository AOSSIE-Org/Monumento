part of 'authentication_bloc.dart';

sealed class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class Uninitialized extends AuthenticationState {
  @override
  String toString() => 'Uninitialized';

  @override
  List<Object> get props => [];
}

class Authenticated extends AuthenticationState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  String toString() => 'Authenticated { displayName: ${user.email} }';

  @override
  List<Object> get props => [user.email];
}

class Unauthenticated extends AuthenticationState {
  @override
  String toString() => 'Unauthenticated';

  @override
  List<Object> get props => [];
}

class OnboardingIncomplete extends AuthenticationState {
  @override
  String toString() => 'OnboardingIncomplete';

  @override
  List<Object> get props => [];
}

class OnboardingFailed extends AuthenticationState {
  final String message;

  const OnboardingFailed({required this.message});

  @override
  String toString() => 'OnboardingFailed';

  @override
  List<Object> get props => [message];
}

class OnboardingSuccess extends AuthenticationState {
  @override
  String toString() => 'OnboardingSuccess';

  @override
  List<Object> get props => [];
}
