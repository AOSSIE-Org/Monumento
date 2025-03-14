import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/application/discover/discover_profile/discover_profile_bloc.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/presentation/profile_screen/desktop/widgets/user_details_card_widget.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/constants.dart';
import 'package:monumento/utils/custom_mobile_appBar.dart';

class DiscoverProfileViewDesktop extends StatefulWidget {
  final UserEntity user;
  const DiscoverProfileViewDesktop({super.key, required this.user});

  @override
  State<DiscoverProfileViewDesktop> createState() =>
      _DiscoverProfileViewDesktopState();
}

class _DiscoverProfileViewDesktopState
    extends State<DiscoverProfileViewDesktop> {
  List<PostEntity> posts = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      locator<DiscoverProfileBloc>()
          .add(LoadDiscoverProfilePosts(userId: widget.user.uid));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomMobileAppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColor.appBlack,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 20,
            ),
            UserDetailsCardWidget(
              user: widget.user,
              isAccountOwner: false,
              onPostsTap: () {},
              onBookmarksTap: () {},
              currentPage: 0,
            ),
            Expanded(
              child: BlocBuilder<DiscoverProfileBloc, DiscoverProfileState>(
                bloc: locator<DiscoverProfileBloc>(),
                builder: (context, postsState) {
                  if (postsState is DiscoverProfilePostsLoaded) {
                    posts = [];
                    var imagePosts = postsState.posts
                        .where((element) => element.postType == 0)
                        .toList();
                    posts.insertAll(posts.length, imagePosts);
                  }
                  // if (postsState is MoreDiscoverPostsLoaded) {
                  //   posts.insertAll(posts.length,
                  //       postsState.posts as Iterable<PostEntity>);
                  // }
                  return posts.isEmpty
                      ? const Center(
                          child: Text("No posts to display"),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: posts[index].imageUrl ??
                                  defaultProfilePicture,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
