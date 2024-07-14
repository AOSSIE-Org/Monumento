import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/profile/profile_posts/profile_posts_bloc.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ProfileScreenDesktop extends StatefulWidget {
  const ProfileScreenDesktop({super.key});

  @override
  State<ProfileScreenDesktop> createState() => _ProfileScreenDesktopState();
}

class _ProfileScreenDesktopState extends State<ProfileScreenDesktop> {
  List<PostEntity> posts = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      locator<ProfilePostsBloc>().add(const LoadInitialProfilePosts());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ResponsiveVisibility(
          hiddenConditions: const [
            Condition.smallerThan(breakpoint: 800),
          ],
          child: AppBar(
            title: Text(
              'Your Profile',
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
                width: 30,
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        bloc: locator<AuthenticationBloc>(),
        builder: (context, state) {
          state as Authenticated;
          return Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Card(
                child: Container(
                  width: 980,
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: state.user.profilePictureUrl ??
                                    defaultProfilePicture,
                                fit: BoxFit.cover,
                                width: 52,
                                height: 52,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 24,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    state.user.name,
                                    style: AppTextStyles.s18(
                                      color: AppColor.appSecondary,
                                      fontType: FontType.MEDIUM,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text("/"),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    '@${state.user.username}' ?? '',
                                    style: AppTextStyles.s14(
                                      color: AppColor.appSecondary,
                                      fontType: FontType.MEDIUM,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    state.user.status,
                                    style: AppTextStyles.s14(
                                      color: AppColor.appSecondary,
                                      fontType: FontType.REGULAR,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    state.user.posts.length.toString(),
                                    style: AppTextStyles.s24(
                                      color: AppColor.appSecondary,
                                      fontType: FontType.MEDIUM,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    'Posts',
                                    style: AppTextStyles.s14(
                                      color: AppColor.appGrey,
                                      fontType: FontType.REGULAR,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 18,
                              ),
                              Column(
                                children: [
                                  Text(
                                    state.user.followers.length.toString(),
                                    style: AppTextStyles.s24(
                                      color: AppColor.appSecondary,
                                      fontType: FontType.MEDIUM,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    'Followers',
                                    style: AppTextStyles.s14(
                                      color: AppColor.appGrey,
                                      fontType: FontType.REGULAR,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 18,
                              ),
                              Column(
                                children: [
                                  Text(
                                    state.user.following.length.toString(),
                                    style: AppTextStyles.s24(
                                      color: AppColor.appSecondary,
                                      fontType: FontType.MEDIUM,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    'Following',
                                    style: AppTextStyles.s14(
                                      color: AppColor.appGrey,
                                      fontType: FontType.REGULAR,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Divider(
                        color: AppColor.appGrey,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            'Posts',
                            style: AppTextStyles.s16(
                              color: AppColor.appSecondary,
                              fontType: FontType.MEDIUM,
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Text(
                            'Saved Bookmarks',
                            style: AppTextStyles.s16(
                              color: AppColor.appTextGrey,
                              fontType: FontType.MEDIUM,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<ProfilePostsBloc, ProfilePostsState>(
                bloc: locator<ProfilePostsBloc>(),
                builder: (context, postsState) {
                  if (postsState is InitialProfilePostsLoaded) {
                    posts = [];
                    posts.insertAll(posts.length, postsState.initialPosts);
                  }
                  if (postsState is MoreProfilePostsLoaded) {
                    posts.insertAll(
                        posts.length, postsState.posts as Iterable<PostEntity>);
                  }
                  return posts.isEmpty
                      ? const Center(
                          child: Text("No posts to display"),
                        )
                      : Expanded(
                          child: GridView.builder(
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
                          ),
                        );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
