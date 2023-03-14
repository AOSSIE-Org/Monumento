import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FeedImageLoading extends StatelessWidget {
  const FeedImageLoading({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      child: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[400],
          child: Container(
            width: double.infinity,
            color: Colors.grey[300],
          )),
      aspectRatio: 1,
    );
  }
}
