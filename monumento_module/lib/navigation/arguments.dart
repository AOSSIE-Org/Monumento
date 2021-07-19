import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';

class ProfileScreenArguments{
  final UserModel user;
  ProfileScreenArguments({@required this.user});
}
class NewPostScreenArguments{
  final File pickedImage;
  NewPostScreenArguments({@required this.pickedImage});

}