import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/application/feed/feed_bloc.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/presentation/feed/desktop/widgets/feed_post_card.dart';
import 'package:monumento/presentation/feed/desktop/widgets/recommended_users_card.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'widgets/create_post_card.dart';

class YourFeedViewDesktop extends StatefulWidget {
  const YourFeedViewDesktop({super.key});

  @override
  State<YourFeedViewDesktop> createState() => _YourFeedViewDesktopState();
}

class _YourFeedViewDesktopState extends State<YourFeedViewDesktop> {
  List<PostEntity> posts = [];

  final _scrollController = ScrollController();

  @override
  void initState() {
    locator<FeedBloc>().add(LoadInitialFeed());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        locator<FeedBloc>().add(LoadMorePosts(
          startAfterDocId: posts.last.postId,
        ));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: ResponsiveVisibility(
          hiddenConditions: const [
            Condition.smallerThan(breakpoint: 800),
          ],
          child: AppBar(
            title: Text(
              'Your Feed',
              style: AppTextStyles.s18(
                color: AppColor.appSecondary,
                fontType: FontType.MEDIUM,
              ),
            ),
            backgroundColor: AppColor.appBackground,
            elevation: 1,
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColor.appSecondary,
                ),
                onPressed: () {},
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<FeedBloc, FeedState>(
        bloc: locator<FeedBloc>(),
        builder: (context, state) {
          if (state is InitialFeedLoaded) {
            posts = [];
            posts.insertAll(posts.length, state.initialPosts);
          }
          if (state is MorePostsLoaded) {
            posts.insertAll(posts.length, state.posts as Iterable<PostEntity>);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const ResponsiveVisibility(
                visibleConditions: [
                  Condition.smallerThan(breakpoint: 1000),
                ],
                child: Spacer(),
              ),
              SizedBox(
                width: 540,
                child: ListView.separated(
                  controller: _scrollController,
                  addAutomaticKeepAlives: true,
                  itemCount:
                      (posts.length + 1) + (state is LoadingMorePosts ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i == posts.length + 1) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (i == 0) {
                      return Padding(
                        padding: EdgeInsets.only(top: 16.h),
                        child: const CreatePostCard(),
                      );
                    }
                    return FeedPostCard(
                      post: posts[i - 1],
                    );
                  },
                  separatorBuilder: (ctx, i) {
                    return SizedBox(
                      height: 20.h,
                    );
                  },
                ),
              ),
              const ResponsiveVisibility(
                visibleConditions: [
                  Condition.smallerThan(breakpoint: 1000),
                ],
                child: Spacer(),
              ),
              const ResponsiveVisibility(
                hiddenConditions: [
                  Condition.smallerThan(breakpoint: 1200),
                ],
                child: RecommendedUsersCard(),
              ),
              const ResponsiveVisibility(
                visibleConditions: [
                  Condition.smallerThan(breakpoint: 1000),
                ],
                child: Spacer(),
              ),
            ],
          );
        },
      ),
    );
  }
}
