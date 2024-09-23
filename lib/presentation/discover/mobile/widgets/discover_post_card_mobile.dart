import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/presentation/discover/mobile/widgets/discover_post_details_view.dart';

class DiscoverPostCardMobile extends StatefulWidget {
  final PostEntity post;
  const DiscoverPostCardMobile({super.key, required this.post});

  @override
  State<DiscoverPostCardMobile> createState() => _DiscoverPostCardMobileState();
}

class _DiscoverPostCardMobileState extends State<DiscoverPostCardMobile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => DiscoverPostDetailsView(
                      post: widget.post,
                    )),
          );
        },
        child: CachedNetworkImage(
            imageUrl: widget.post.imageUrl!,
            imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.sp),
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                )));
  }
}
