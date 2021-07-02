part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  @override
  List<Object> get props => [];
}

class ProfileDataRetrieved extends ProfileState {
  final UserModel profile;

  ProfileDataRetrieved({this.profile});
  @override
  List<Object> get props => [];
}

class FailedToRetrieveProfileData extends ProfileState {
  @override
  List<Object> get props => [];
}
