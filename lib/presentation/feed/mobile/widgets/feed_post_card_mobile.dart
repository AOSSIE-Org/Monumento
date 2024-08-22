import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';
import 'package:monumento/application/feed/feed_bloc.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/presentation/feed/mobile/widgets/comment_bottom_sheet.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';

import 'package:timeago/timeago.dart' as timeago;

class FeedPostCardMobile extends StatefulWidget {
  final PostEntity post;
  const FeedPostCardMobile({super.key, required this.post});

  @override
  State<FeedPostCardMobile> createState() => _FeedPostCardMobileState();
}

class _FeedPostCardMobileState extends State<FeedPostCardMobile>
    with AutomaticKeepAliveClientMixin<FeedPostCardMobile> {
  bool isLiked = false;
  int likesCount = 0;

  @override
  void initState() {
    setState(() {
      isLiked = widget.post.isPostLiked ?? false;
      likesCount = widget.post.likesCount ?? 0;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
      child: Container(
        padding: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: AppColor.appWhite,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(widget.post.author.profilePictureUrl ??
                        defaultProfilePicture),
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.author.name,
                      style: AppTextStyles.s16(
                        color: AppColor.appSecondary,
                        fontType: FontType.MEDIUM,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      widget.post.location ?? "@${widget.post.author.username}",
                      style: AppTextStyles.s14(
                        color: AppColor.appSecondary,
                        fontType: FontType.REGULAR,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(onPressed: (){
                      
                    },icon:const Icon(Icons.more_horiz)),
                    Text(
                      timeago.format(DateTime.fromMillisecondsSinceEpoch(
                          widget.post.timeStamp)),
                      style: AppTextStyles.s12(
                        color: AppColor.appTextLightGrey,
                        fontType: FontType.REGULAR,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            widget.post.imageUrl == null
                ? Text(
                    widget.post.title,
                    style: AppTextStyles.s16(
                      color: AppColor.appSecondary,
                      fontType: FontType.REGULAR,
                    ),
                  )
                : Image(
                    image:
                        CachedNetworkImageProvider(widget.post.imageUrl ?? ""),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
            widget.post.imageUrl == null
                ? const SizedBox(
                    height: 24,
                  )
                : const SizedBox(),
            Row(
              children: [
                BlocListener<FeedBloc, FeedState>(
                  bloc: locator<FeedBloc>(),
                  listener: (context, state) {
                    if (state is PostLiked) {
                      if (state.postId == widget.post.postId) {
                        setState(() {
                          isLiked = true;
                          likesCount = likesCount > 0 ? likesCount + 1 : 1;
                        });
                      }
                    } else if (state is PostUnLiked) {
                      if (state.postId == widget.post.postId) {
                        setState(() {
                          isLiked = false;
                          likesCount =
                              (likesCount - 1) > 0 ? likesCount - 1 : 0;
                        });
                      }
                    } else if (state is PostLikeFailed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to like post"),
                        ),
                      );
                    } else if (state is PostUnlikeFailed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to unlike post"),
                        ),
                      );
                    }
                  },
                  child: LikeButton(
                    size: 24,
                    isLiked: isLiked,
                    postFrameCallback: (LikeButtonState state) {
                      state.controller?.forward();
                    },
                    likeBuilder: (isLiked) {
                      return SvgPicture.asset(
                        isLiked
                            ? 'assets/icons/ic_heart_filled.svg'
                            : 'assets/icons/ic_heart.svg',
                        width: 24,
                        height: 24,
                      );
                    },
                    likeCountAnimationType: LikeCountAnimationType.part,
                    onTap: (bool isLiked) async {
                      if (!isLiked) {
                        locator<FeedBloc>().add(
                          LikePost(postId: widget.post.postId),
                        );
                        return true;
                      } else {
                        locator<FeedBloc>().add(
                          UnlikePost(postId: widget.post.postId),
                        );
                        return false;
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/ic_comment.svg',
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () {
                    CommentBottomSheet()
                        .commentBottomSheet(context, widget.post);
                  },
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/ic_share.svg',
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              likesCount >= 0 ? "$likesCount likes" : "$likesCount like",
              style: AppTextStyles.s14(
                color: AppColor.appSecondary,
                fontType: FontType.MEDIUM,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            widget.post.postType == 0
                ? Text(
                    widget.post.title,
                    style: AppTextStyles.s16(
                      color: AppColor.appSecondary,
                      fontType: FontType.REGULAR,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
