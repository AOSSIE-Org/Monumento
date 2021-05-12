import 'package:monumento/resources/authentication/entities/user_entity.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String profilePictureUrl;
  final String status;

  UserModel(
      {this.email, this.uid, this.name, this.profilePictureUrl, this.status = ""});

  UserModel copyWith() {
    return UserModel(
        email: email,
        uid: uid,
        name: name,
        profilePictureUrl: profilePictureUrl,
        status: status);
  }

  UserEntity toEntity() {
    return UserEntity(
        email: email,
        uid: uid,
        name: name,
        profilePictureUrl: profilePictureUrl,
        status: status);
  }

  static UserModel fromEntity(UserEntity userEntity) {
    return UserModel(
        uid: userEntity.uid,
        name: userEntity.name,
        email: userEntity.email,
        profilePictureUrl: userEntity.profilePictureUrl,
        status: userEntity.status);
  }
}
