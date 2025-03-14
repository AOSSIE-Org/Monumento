import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/feed/comments/comments_bloc.dart';
import 'package:monumento/domain/entities/comment_entity.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';

class CommentScreen extends StatefulWidget {
  final PostEntity post;
  const CommentScreen({super.key, required this.post});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  List<CommentEntity> comments = [];
  var commentFocusNode = FocusNode();
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    commentFocusNode.requestFocus();
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
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Column(children: [
              Container(
                  margin: const EdgeInsets.all(8),
                  height: 5,
                  width: 50,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: AppColor.appPrimary)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Comments",
                  style: AppTextStyles.s16(
                    color: AppColor.appSecondary,
                    fontType: FontType.MEDIUM,
                  ),
                ),
              ),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: BlocListener<CommentsBloc, CommentsState>(
                bloc: locator<CommentsBloc>(),
                listener: (context, state) {
                  if (state is CommentAdded &&
                      state.comment.postInvolvedId == widget.post.postId) {
                    setState(() {
                      comments.insert(0, state.comment);
                    });
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
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.sizeOf(context).width *
                                              2.2 /
                                              3,
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
                                      width: 320,
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Row(
              children: [
                BlocBuilder<AuthenticationBloc, AuthenticationState>(
                  bloc: locator<AuthenticationBloc>(),
                  builder: (context, state) {
                    state = state as Authenticated;
                    return CircleAvatar(
                      radius: 20,
                      backgroundImage: CachedNetworkImageProvider(
                        state.user.profilePictureUrl ?? defaultProfilePicture,
                      ),
                    );
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 2.2 / 3,
                  child: TextFormField(
                    cursorColor: AppColor.appPrimary,
                    focusNode: commentFocusNode,
                    controller: commentController,
                    decoration: InputDecoration(
                      focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColor.appPrimary, width: 2),
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          locator<CommentsBloc>().add(
                            AddCommentPressed(
                              postDocId: widget.post.postId,
                              comment: commentController.text,
                            ),
                          );
                          // clear the text field
                          commentController.clear();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            Assets.icons.icShare.path,
                            width: 24,
                            height: 24,
                          ),
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
          ),
        ],
      ),
    );
  }
}

class CommentBottomSheet {
  commentBottomSheet(BuildContext context, PostEntity post) {
    showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.sp),
                topLeft: Radius.circular(20.sp))),
        context: context,
        builder: (_) {
          return CommentScreen(post: post);
        });
  }
}
