import 'package:flutter/material.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/feed/mobile/widgets/feed_post_card_mobile.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/custom_mobile_appBar.dart';

class DiscoverPostDetailsView extends StatelessWidget {
  final PostEntity post;
  const DiscoverPostDetailsView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomMobileAppBar(
          logoPath: Assets.mobile.logoDiscover.path,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColor.appBlack,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
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
