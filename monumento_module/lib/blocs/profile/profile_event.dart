part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class GetProfileData extends ProfileEvent {
  final String userId;
  GetProfileData({this.userId});
  @override
  // TODO: implement props
  List<Object> get props => [userId];
}
