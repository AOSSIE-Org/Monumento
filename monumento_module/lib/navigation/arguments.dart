import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/monuments/models/monument_model.dart';

class ProfileScreenArguments{
  final UserModel user;
  ProfileScreenArguments({@required this.user});
}
class NewPostScreenArguments{
  final File pickedImage;
  NewPostScreenArguments({@required this.pickedImage});

}

class CommentsScreenArguments{
  final DocumentReference postDocumentRef;
  CommentsScreenArguments({this.postDocumentRef});
}

class DetailScreenArguments{
  final MonumentModel monument;
  final UserModel user;
  final bool isBookmarked;

  DetailScreenArguments({@required this.monument, @required this.user, @required this.isBookmarked});

}