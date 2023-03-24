part of 'profile_form_bloc.dart';

abstract class ProfileFormEvent extends Equatable {
  const ProfileFormEvent();
}

class CreateUserDoc extends ProfileFormEvent {
  final File profilePictureFile;
  final String username;
  final String name;
  final String status;
  final String email;
  final String uid;

  @override
  // TODO: implement props
  List<Object> get props =>
      [username, name, profilePictureFile, status, email, uid];

  const CreateUserDoc({
    this.profilePictureFile,
    @required this.username,
    @required this.name,
    @required this.status,
    @required this.email,
    @required this.uid,
  });
}
