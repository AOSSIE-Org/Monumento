import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/feed/comments/comments_bloc.dart';
import 'package:monumento/application/feed/feed_bloc.dart';
import 'package:monumento/domain/entities/comment_entity.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';
import 'package:timeago/timeago.dart' as timeago;

class FeedPostCard extends StatefulWidget {
  final PostEntity post;
  const FeedPostCard({super.key, required this.post});

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard>
    with AutomaticKeepAliveClientMixin<FeedPostCard> {
  bool isLiked = false;
  int likesCount = 0;
  List<CommentEntity> comments = [];
  var commentFocusNode = FocusNode();
  final TextEditingController commentController = TextEditingController();

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
  void dispose() {
    commentFocusNode.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
      child: Container(
        margin: const EdgeInsets.all(20),
        width: 520,
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
                  foregroundImage: CachedNetworkImageProvider(
                    widget.post.author.profilePictureUrl ?? defaultProfilePicture,
                  ),
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
                        isDesktop: true,
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
                        isDesktop: true,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
            const SizedBox(
              height: 24,
            ),
            widget.post.imageUrl == null || widget.post.imageUrl!.isEmpty
                ? (widget.post.postType == 2
                    ? Container(
                        width: double.infinity,
                        height: 210,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Assets.desktop.checkedin.image(
                              width: 160,
                              height: 160,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              widget.post.title.isEmpty
                                  ? "${widget.post.author.name} visited ${widget.post.location ?? "a place"}"
                                  : widget.post.title,
                              style: AppTextStyles.s16(
                                color: AppColor.appSecondary,
                                fontType: FontType.REGULAR,
                                isDesktop: true,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        widget.post.title,
                        style: AppTextStyles.s16(
                          color: AppColor.appSecondary,
                          fontType: FontType.REGULAR,
                          isDesktop: true,
                        ),
                      ))
                : Container(
                    width: double.infinity,
                    height: 380,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color.fromARGB(255, 127, 127, 127),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                            widget.post.imageUrl ?? ""),
                        fit: BoxFit.cover,
                      ),
                    ),
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
                  icon: Assets.icons.icComment.svg(width: 24, height: 24),
                  onPressed: () {
                    commentFocusNode.requestFocus();
                  },
                ),
                IconButton(
                  icon: Assets.icons.icShare.svg(width: 24, height: 24),
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
            widget.post.postType == 0
                ? Text(
                    widget.post.title,
                    style: AppTextStyles.s16(
                      color: AppColor.appSecondary,
                      fontType: FontType.REGULAR,
                      isDesktop: true,
                    ),
                  )
                : const SizedBox(),
            const SizedBox(
              height: 14,
            ),
            Row(
              children: [
                BlocBuilder<AuthenticationBloc, AuthenticationState>(
                  bloc: locator<AuthenticationBloc>(),
                  builder: (context, state) {
                    state = state as Authenticated;
                    return CircleAvatar(
                      radius: 20,
                      foregroundImage: CachedNetworkImageProvider(
                        state.user.profilePictureUrl ??
                            defaultProfilePicture
                      ),
                    );
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 430,
                  child: TextFormField(
                    cursorColor: AppColor.appPrimary,
                    focusNode: commentFocusNode,
                    controller: commentController,
                    decoration: InputDecoration(
                      focusColor: AppColor.appPrimary,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          locator<CommentsBloc>().add(
                            AddCommentPressed(
                              postDocId: widget.post.postId,
                              comment: commentController.text,
                            ),
                          );
                          commentController.clear();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              Assets.icons.icShare.svg(width: 24, height: 24),
                        ),
                      ),
                      isDense: true,
                      hintText: "Add a comment...",
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            BlocListener<CommentsBloc, CommentsState>(
              bloc: locator<CommentsBloc>(),
              listener: (context, state) {
                if (state is CommentAdded &&
                    state.comment.postInvolvedId == widget.post.postId) {
                  commentController.clear();
                  setState(() {
                    comments.insert(0, state.comment);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Comment added successfully"),
                    ),
                  );
                }
                if (state is FailedToAddComment) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to add comment"),
                    ),
                  );
                }
              },
              child: BlocBuilder<CommentsBloc, CommentsState>(
                bloc: locator<CommentsBloc>(),
                buildWhen: (previous, current) {
                  if (current is InitialCommentsLoaded) {
                    var shouldRebuild = current.postId == widget.post.postId;
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
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: comments
                          .map(
                            (comment) => Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                          comment.author.profilePictureUrl ??
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
                                  constraints: const BoxConstraints(
                                    maxWidth: 440,
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
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.author.name,
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
                                          comment.comment,
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
                            ),
                          )
                          .toList(),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            if ((widget.post.commentsCount ?? 0) > comments.length)
              TextButton(
                onPressed: () {
                  locator<CommentsBloc>().add(
                    LoadMoreComments(
                      postDocId: widget.post.postId,
                      startAfterId: comments.last.commentDocId,
                    ),
                  );
                },
                child: const Text(
                  "View more comments",
                  style: TextStyle(
                    color: AppColor.appSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
