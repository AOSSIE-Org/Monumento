import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/popular_monuments/bookmark_monuments/bookmark_monuments_bloc.dart';
import 'package:monumento/application/profile/profile_posts/profile_posts_bloc.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/presentation/popular_monuments/desktop/monument_details_view_desktop.dart';
import 'package:monumento/presentation/profile_screen/desktop/widgets/user_details_card_widget.dart';
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
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  _jumpToPage(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage = index;
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      locator<ProfilePostsBloc>().add(const LoadInitialProfilePosts());
      locator<BookmarkMonumentsBloc>().add(const GetBookmarkedMonuments());
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 20,
              ),
              UserDetailsCardWidget(
                isAccountOwner: true,
                user: state.user,
                onPostsTap: () {
                  _jumpToPage(0);
                },
                onBookmarksTap: () {
                  _jumpToPage(1);
                },
                currentPage: _currentPage,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: [
                    BlocBuilder<ProfilePostsBloc, ProfilePostsState>(
                      bloc: locator<ProfilePostsBloc>(),
                      builder: (context, postsState) {
                        if (postsState is InitialProfilePostsLoaded) {
                          posts = [];
                          posts.insertAll(
                              posts.length, postsState.initialPosts);
                        }
                        if (postsState is MoreProfilePostsLoaded) {
                          posts.insertAll(posts.length,
                              postsState.posts as Iterable<PostEntity>);
                        }
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
                    BlocBuilder<BookmarkMonumentsBloc, BookmarkMonumentsState>(
                      bloc: locator<BookmarkMonumentsBloc>(),
                      builder: (context, state) {
                        if (state is BookmarkedMonumentsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is BookmarkedMonumentsLoaded) {
                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: 2,
                            ),
                            itemCount: state.bookmarkedMonuments.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MonumentDetailsViewDesktop(
                                        isBookmarked: true,
                                        monument:
                                            state.bookmarkedMonuments[index],
                                      ),
                                    ),
                                  );
                                },
                                child: CachedNetworkImage(
                                  imageUrl:
                                      state.bookmarkedMonuments[index].imageUrl,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: 600,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: Text("No bookmarks to display"),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
