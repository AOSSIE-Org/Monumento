import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showSnackBar({@required BuildContext context, @required String text}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.amber,
    content: Text(
      text,
      style: TextStyle(color: Colors.white),
    ),
  ));
}
