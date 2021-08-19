import 'package:flutter/material.dart';
import 'package:monumento/ui/widgets/feed_image_loading.dart';
import 'package:monumento/ui/widgets/profile_picture_loading.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerFeedTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        margin: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: ProfilePictureLoading(),
              title: Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[400],
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 8.0 / 2, right: 60, top: 8.0 / 2),
                  child: Container(
                    height: 20,
                    width: 100,
                    color: Colors.grey[300],
                  ),
                ),
              ),
              subtitle: Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[400],
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0 / 2, right: 100),
                  child: Container(
                    height: 20,
                    width: 80,
                    color: Colors.grey[300],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            FeedImageLoading(),
          ],
        ),
      ),
    );
  }
}
