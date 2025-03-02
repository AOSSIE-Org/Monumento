import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';
import 'package:monumento/application/feed/comments/comments_bloc.dart';
import 'package:monumento/application/feed/feed_bloc.dart';
import 'package:monumento/domain/entities/comment_entity.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailsPopupWidget extends StatefulWidget {
  final PostEntity post;
  const PostDetailsPopupWidget({super.key, required this.post});

  @override
  State<PostDetailsPopupWidget> createState() => _PostDetailsPopupWidgetState();
}

class _PostDetailsPopupWidgetState extends State<PostDetailsPopupWidget> {
  bool isLiked = false;
  int likesCount = 0;
  List<CommentEntity> comments = [];

  @override
  void initState() {
    setState(() {
      isLiked = widget.post.isPostLiked ?? false;
      likesCount = widget.post.likesCount ?? 0;
    });
    locator<CommentsBloc>()
        .add(LoadInitialComments(postDocId: widget.post.postId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return Card(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveVisibility(
            hiddenConditions: const [
              Condition.largerThan(breakpoint: 850),
            ],
            child: PopUpImage(
                imageUrl: widget.post.imageUrl!, width: width * 0.87),
          ),
          ResponsiveVisibility(
            hiddenConditions: const [
              Condition.smallerThan(breakpoint: 850),
            ],
            child: PopUpImage(
                imageUrl: widget.post.imageUrl!, width: width * 0.48),
          ),
          ResponsiveVisibility(
            hiddenConditions: const [
              Condition.smallerThan(breakpoint: 850),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: height * 0.08,
                  width: width * 0.39,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 12,
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: CachedNetworkImageProvider(
                          widget.post.author.profilePictureUrl ??
                              defaultProfilePicture,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.post.author.name,
                            style: AppTextStyles.s16(
                              color: AppColor.appSecondary,
                              fontType: FontType.MEDIUM,
                              isDesktop: true,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            widget.post.location ??
                                "@${widget.post.author.username}",
                            style: AppTextStyles.s14(
                              color: AppColor.appSecondary,
                              fontType: FontType.REGULAR,
                              isDesktop: true,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.more_horiz),
                          Text(
                            timeago.format(DateTime.fromMillisecondsSinceEpoch(
                                widget.post.timeStamp)),
                            style: AppTextStyles.s12(
                              color: AppColor.appTextLightGrey,
                              fontType: FontType.REGULAR,
                              isDesktop: true,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: height * 0.54,
                  child: BlocListener<CommentsBloc, CommentsState>(
                    bloc: locator<CommentsBloc>(),
                    listener: (context, state) {
                      if (state is CommentAdded) {}
                    },
                    child: BlocBuilder<CommentsBloc, CommentsState>(
                      bloc: locator<CommentsBloc>(),
                      buildWhen: (previous, current) {
                        if (current is InitialCommentsLoaded) {
                          var shouldRebuild =
                              current.postId == widget.post.postId;
                          if (shouldRebuild) {
                            comments = current.initialComments
                                .map((e) => e.toEntity())
                                .toList();
                          }
                          return shouldRebuild;
                        }
                        if (current is LoadingInitialComments) {
                          if (current.postId == widget.post.postId) {
                            return true;
                          }
                        }
                        if (current is LoadingMoreComments) {
                          if (current.postId == widget.post.postId) {
                            return true;
                          }
                        }
                        return false;
                      },
                      builder: (context, state) {
                        if (state is InitialCommentsLoaded ||
                            state is MoreCommentsLoaded) {
                          return SizedBox(
                            width: width * 0.36,
                            child: ListView.separated(
                              itemCount: comments.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              separatorBuilder: (context, index) {
                                return const SizedBox(
                                  height: 12,
                                );
                              },
                              itemBuilder: (context, index) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColor.appWhite,
                                            width: 2,
                                          ),
                                          image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                              comments[index]
                                                      .author
                                                      .profilePictureUrl ??
                                                  defaultProfilePicture,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: width * 0.3,
                                      ),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: AppColor.appGreyAccent,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                          ),
                                        ),
                                        width: double.infinity,
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              comments[index].author.name,
                                              style: AppTextStyles.s14(
                                                color: AppColor.appSecondary,
                                                fontType: FontType.MEDIUM,
                                                isDesktop: true,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              comments[index].comment,
                                              style: AppTextStyles.s14(
                                                color: AppColor.appSecondary,
                                                fontType: FontType.REGULAR,
                                                isDesktop: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    BlocListener<FeedBloc, FeedState>(
                      bloc: locator<FeedBloc>(),
                      listener: (context, state) {
                        if (state is PostLiked) {
                          setState(() {
                            isLiked = true;
                            likesCount++;
                          });
                        } else if (state is PostUnLiked) {
                          setState(() {
                            isLiked = false;
                            likesCount--;
                          });
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
                                ? Assets.icons.icHeartFilled.path
                                : Assets.icons.icHeart.path,
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
                        Assets.icons.icComment.path,
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        Assets.icons.icShare.path,
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
                  likesCount != 1 ? "$likesCount likes" : "$likesCount like",
                  style: AppTextStyles.s14(
                    color: AppColor.appSecondary,
                    fontType: FontType.MEDIUM,
                    isDesktop: true,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PopUpImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  const PopUpImage({super.key, required this.imageUrl, required this.width});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: width,
        margin: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(12.sp),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}
