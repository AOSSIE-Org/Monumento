import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Define responsive breakpoints
    final bool isSmallScreen = screenWidth < 650;
    
    // Calculate adaptive dimensions
    final imageWidth = isSmallScreen 
        ? screenWidth * 0.9
            : screenWidth * 0.48;
    
    var contentWidth = isSmallScreen 
        ? screenWidth * 0.8
            : screenWidth * 0.39;
    
    var commentInputWidth = isSmallScreen 
        ? contentWidth * 0.6
            : contentWidth * 0.25;
    contentWidth = contentWidth - 15;
    commentInputWidth = commentInputWidth - 15;
    // Determine layout direction
    final isHorizontalLayout = !isSmallScreen;

    return Card(
      child: isHorizontalLayout
          ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(imageWidth),
                _buildDetailsSection(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  contentWidth: contentWidth,
                  commentInputWidth: commentInputWidth,
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(imageWidth),
                _buildDetailsSection(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  contentWidth: contentWidth,
                  commentInputWidth: commentInputWidth,
                  isVerticalLayout: true,
                ),
              ],
            ),
    );
  }

  Widget _buildImage(double width) {
    return PopUpImage(imageUrl: widget.post.imageUrl!, width: width);
  }

  Widget _buildDetailsSection({
    required double screenWidth,
    required double screenHeight,
    required double contentWidth,
    required double commentInputWidth,
    bool isVerticalLayout = false,
  }) {
    // Calculate header height
    final headerHeight = isVerticalLayout 
        ? screenHeight * 0.06 
        : screenHeight * 0.08;
    
    // Calculate comments section height
    var commentsHeight = isVerticalLayout 
        ? screenHeight * 0.2
        : screenHeight * 0.54;

    return SizedBox(
      width: contentWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Post header with author info
          SizedBox(
            height: headerHeight,
            width: contentWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: CachedNetworkImageProvider(
                      widget.post.author.profilePictureUrl ?? defaultProfilePicture,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
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
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.post.location ?? "@${widget.post.author.username}",
                          style: AppTextStyles.s14(
                            color: AppColor.appSecondary,
                            fontType: FontType.REGULAR,
                            isDesktop: true,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.more_horiz),
                      Text(
                        timeago.format(
                          DateTime.fromMillisecondsSinceEpoch(widget.post.timeStamp)
                        ),
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
          ),
          const SizedBox(height: 12),
          
          // Comments section
          SizedBox(
            height: commentsHeight,
            child: _buildCommentsSection(contentWidth),
          ),
          
          // Like, comment buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildLikeButton(),
                IconButton(
                  icon: SvgPicture.asset(
                    Assets.icons.icComment.path,
                    width: 24, height: 24,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    Assets.icons.icShare.path,
                    width: 24, height: 24,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Likes count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              likesCount != 1 ? "$likesCount likes" : "$likesCount like",
              style: AppTextStyles.s14(
                color: AppColor.appSecondary,
                fontType: FontType.MEDIUM,
                isDesktop: true,
              ),
            ),
          ),
          
          // Comment input field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
            child: Row(
              children: [
                BlocBuilder<AuthenticationBloc, AuthenticationState>(
                  bloc: locator<AuthenticationBloc>(),
                  builder: (context, state) {
                    state = state as Authenticated;
                    return CircleAvatar(
                      radius: 16,
                      backgroundImage: CachedNetworkImageProvider(
                        state.user.profilePictureUrl ?? defaultProfilePicture,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: commentInputWidth,
                    ),
                    child: TextFormField(
                      cursorColor: AppColor.appPrimary,
                      controller: commentController,
                      decoration: InputDecoration(
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColor.appPrimary, width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            if (commentController.text.isNotEmpty) {
                              locator<CommentsBloc>().add(
                                AddCommentPressed(
                                  postDocId: widget.post.postId,
                                  comment: commentController.text,
                                ),
                              );
                              commentController.clear();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              Assets.icons.icShare.path,
                              width: 24, height: 24,
                            ),
                          ),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        hintText: "Add a comment...",
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(double contentWidth) {
    return BlocBuilder<CommentsBloc, CommentsState>(
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
        if (state is InitialCommentsLoaded || state is MoreCommentsLoaded) {
          return comments.isEmpty
              ? Center(
                  child: Text(
                    "No comments yet",
                    style: AppTextStyles.s14(
                      color: AppColor.appTextLightGrey,
                      fontType: FontType.REGULAR,
                      isDesktop: true,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: comments.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  scrollDirection: Axis.vertical,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildCommentItem(contentWidth, index),
                );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildCommentItem(double contentWidth, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: CachedNetworkImageProvider(
            comments[index].author.profilePictureUrl ?? defaultProfilePicture,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comments[index].author.name,
                  style: AppTextStyles.s14(
                    color: AppColor.appSecondary,
                    fontType: FontType.MEDIUM,
                    isDesktop: true,
                  ),
                ),
                const SizedBox(height: 4),
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
  }

  Widget _buildLikeButton() {
    return BlocListener<FeedBloc, FeedState>(
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
            isLiked ? Assets.icons.icHeartFilled.path : Assets.icons.icHeart.path,
            width: 24, height: 24,
          );
        },
        likeCountAnimationType: LikeCountAnimationType.part,
        onTap: (bool isLiked) async {
          if (!isLiked) {
            locator<FeedBloc>().add(LikePost(postId: widget.post.postId));
            return true;
          } else {
            locator<FeedBloc>().add(UnlikePost(postId: widget.post.postId));
            return false;
          }
        },
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
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 650;
    
    // Calculate appropriate height
    final imageHeight = isSmallScreen 
        ? 350.0  // Square aspect ratio on small screens
        : screenHeight * 0.7; // Taller on larger screens
        
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: width,
        height: imageHeight,
        margin: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(12.sp),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,  // Changed to cover for better image display
          ),
        ),
      ),
      placeholder: (context, url) => Container(
        width: width,
        height: imageHeight,
        margin: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12.sp),
        ),
        child: Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: imageHeight,
        margin: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12.sp),
        ),
        child: Center(child: Icon(Icons.error)),
      ),
    );
  }
}
