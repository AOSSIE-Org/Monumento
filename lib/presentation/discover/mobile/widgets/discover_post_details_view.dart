import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/feed/mobile/widgets/feed_post_card_mobile.dart';
import 'package:monumento/utils/app_colors.dart';

class DiscoverPostDetailsView extends StatelessWidget {
  final PostEntity post;
  const DiscoverPostDetailsView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.appBackground,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColor.appBlack,
            ),
          ),
          title: SvgPicture.asset(
            Assets.mobile.logoDiscover.path,
            height: 25,
            width: 161,
          ),
        ),
        body: PageView(
          scrollDirection: Axis.vertical,
          children: [
            FeedPostCardMobile(
              post: post,
            )
          ],
        ));
  }
}
