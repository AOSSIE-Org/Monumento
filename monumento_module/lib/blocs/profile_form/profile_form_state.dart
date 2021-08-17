part of 'profile_form_bloc.dart';

abstract class ProfileFormState extends Equatable {
  const ProfileFormState();
}

class ProfileFormInitial extends ProfileFormState {
  @override
  List<Object> get props => [];
}

class ProfileFormError extends ProfileFormState {
  final String message;

  @override
  List<Object> get props => [message];

  ProfileFormError({@required this.message});
}

class ProfileCreated extends ProfileFormState {
  final UserModel user;

  @override
  List<Object> get props => [user];

  const ProfileCreated({
    @required this.user,
  });
}

class ProfileFormLoading extends ProfileFormState {
  @override
  List<Object> get props => [];
}
