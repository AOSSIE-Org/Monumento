part of 'update_profile_bloc.dart';

sealed class UpdateProfileState extends Equatable {
  const UpdateProfileState();
}

class UpdateProfileInitial extends UpdateProfileState{

  @override
  List<Object?> get props => [];
}

class UpdateProfileLoading extends UpdateProfileState{
  @override
  List<Object?> get props => [];
  
}

class UpdateProfileSuccess extends UpdateProfileState{
  @override
  String toString() => 'Profile Updated Successfully!';
  
  @override
  List<Object?> get props => [];
  
}

class UpdateProfileFailure extends UpdateProfileState{
  final String message;
  const UpdateProfileFailure({required this.message});

  @override
  List<Object?> get props => [message];
  
}