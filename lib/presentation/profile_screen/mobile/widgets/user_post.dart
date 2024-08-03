import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/application/profile/profile_posts/profile_posts_bloc.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/presentation/profile_screen/mobile/user_post_details_screen.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/constants.dart';

class UserPost extends StatefulWidget {
  const UserPost({super.key});

  @override
  State<UserPost> createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> {
  List<PostEntity> posts = [];

  @override
  void initState() {
    locator<ProfilePostsBloc>().add(const LoadInitialProfilePosts());
    super.initState();
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
          return posts.isEmpty
              ? const Center(
                  child: Text("No posts to display"),
                )
              : GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: posts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                        );
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
                              ))),
                    );
                  });
        });
  }
}
