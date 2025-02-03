import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/presentation/feed/mobile/widgets/feed_post_card_mobile.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/custom_mobile_appBar.dart';

class UserPostDetailsScreen extends StatefulWidget {
  final List<PostEntity> post;
  final int index;
  const UserPostDetailsScreen(
      {super.key, required this.index, required this.post});

  @override
  State<UserPostDetailsScreen> createState() => _UserPostDetailsScreenState();
}

class _UserPostDetailsScreenState extends State<UserPostDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomMobileAppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColor.appBlack,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            Text(
              "Post",
              style: AppTextStyles.s18(
                color: AppColor.appBlack,
                fontType: FontType.BOLD,
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                addAutomaticKeepAlives: true,
                itemCount: widget.post.length,
                itemBuilder: (ctx, i) {
                  if (i == widget.post.length) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return FeedPostCardMobile(
                    post: widget.post[i],
                  );
                },
                separatorBuilder: (ctx, i) {
                  return SizedBox(
                    height: 20.h,
                  );
                },
              ),
            ),
          ],
        ));
  }
}
