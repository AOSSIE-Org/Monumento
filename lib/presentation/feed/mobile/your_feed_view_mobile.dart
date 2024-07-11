import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monumento/application/feed/feed_bloc.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/presentation/feed/mobile/widgets/feed_post_card_mobile.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';

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
      appBar: AppBar(
          backgroundColor: AppColor.appBackground,
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SvgPicture.asset(
              'assets/mobile/logo_feed.svg',
              height: 25,
              width: 161,
            ),
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColor.appBlack)),
          ])),
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
                      height: 20.h,
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
