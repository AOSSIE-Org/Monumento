part of 'update_profile_bloc.dart';

sealed class UpdateProfileEvent extends Equatable {
  const UpdateProfileEvent();
}

class UpdateUserDetails extends UpdateProfileEvent{
  final Map<Object,dynamic> userInfo;

  const UpdateUserDetails({required this.userInfo});
  
  @override
  List<Object?> get props => [userInfo];
}
