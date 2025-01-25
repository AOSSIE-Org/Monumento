import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/application/feed/feed_bloc.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/feed/mobile/widgets/feed_post_card_mobile.dart';
import 'package:monumento/presentation/notification/desktop/notification_view_desktop.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/custom_mobile_appBar.dart';

class YourFeedViewMobile extends StatefulWidget {
  const YourFeedViewMobile({super.key});

  @override
  State<YourFeedViewMobile> createState() => _YourFeedViewMobileState();
}

class _YourFeedViewMobileState extends State<YourFeedViewMobile> {
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
      appBar: CustomMobileAppBar(
        logoPath: Assets.mobile.logoFeed.path,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) {
                    return const NotificationViewDesktop();
                  },
                ),
              );
            },
          ),
        ],
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
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  addAutomaticKeepAlives: true,
                  itemCount: posts.length,
                  itemBuilder: (ctx, i) {
                    if (i == posts.length) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return FeedPostCardMobile(
                      post: posts[i],
                    );
                  },
                  separatorBuilder: (ctx, i) {
                    return SizedBox(
                      height: 15.h,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
