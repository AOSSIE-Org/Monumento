import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/application/profile/profile_posts/profile_posts_bloc.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/presentation/profile_screen/mobile/user_post_details_screen.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/constants.dart';

class UserPostTabView extends StatefulWidget {
  const UserPostTabView({super.key});

  @override
  State<UserPostTabView> createState() => _UserPostTabViewState();
}

class _UserPostTabViewState extends State<UserPostTabView> {
  List<PostEntity> posts = [];
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    locator<ProfilePostsBloc>().add(const LoadInitialProfilePosts());
    super.initState();
  }

  Future<void> _refreshPosts() async {
    locator<ProfilePostsBloc>().add(const LoadInitialProfilePosts());
    return Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfilePostsBloc, ProfilePostsState>(
        bloc: locator<ProfilePostsBloc>(),
        builder: (context, state) {
          if (state is InitialProfilePostsLoaded) {
            posts = [];
            posts.insertAll(posts.length, state.initialPosts);
          }
          if (state is MoreProfilePostsLoaded) {
            posts.insertAll(posts.length, state.posts as Iterable<PostEntity>);
          }

          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refreshPosts,
            child: posts.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 200,
                        child: Center(
                          child: Text("No posts to display"),
                        ),
                      ),
                    ],
                  )
                : GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: posts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8),
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserPostDetailsScreen(
                                post: posts,
                                index: index,
                              ),
                            ),
                          ).then((_) {
                            // Refresh when returning from post details
                            _refreshPosts();
                          });
                        },
                        child: CachedNetworkImage(
                          imageUrl:
                              posts[index].imageUrl ?? defaultProfilePicture,
                          imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.sp),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          )),
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.sp),
                              color: Colors.grey[200],
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.sp),
                              color: Colors.grey[200],
                            ),
                            child: const Center(
                              child:
                                  Icon(Icons.error_outline, color: Colors.red),
                            ),
                          ),
                        ),
                      );
                    }),
          );
        });
  }
}
