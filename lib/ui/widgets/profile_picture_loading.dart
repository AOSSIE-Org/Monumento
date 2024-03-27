import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfilePictureLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      child: CircleAvatar(
        radius: 30,
        child: Container(),
        backgroundColor: Colors.grey[300],
      ),
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[400],
    );
  }
}
