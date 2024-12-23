import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/discover/discover_posts/discover_posts_bloc.dart';
import 'package:monumento/application/discover/search/search_bloc.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/discover/mobile/discover_profile_view_mobile.dart';
import 'package:monumento/presentation/discover/mobile/widgets/discover_post_card_mobile.dart';
import 'package:monumento/presentation/notification/desktop/notification_view_desktop.dart';
import 'package:monumento/presentation/profile_screen/mobile/profile_screen_mobile.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';
import 'package:monumento/utils/debouncer.dart';

class DiscoverViewMobile extends StatefulWidget {
  const DiscoverViewMobile({super.key});

  @override
  State<DiscoverViewMobile> createState() => _DiscoverViewMobileState();
}

class _DiscoverViewMobileState extends State<DiscoverViewMobile> {
  List<PostEntity> posts = [];

  @override
  void initState() {
    locator<DiscoverPostsBloc>().add(LoadInitialDiscoverPosts());
    super.initState();
  }

  OverlayEntry? overlayEntry;
  final LayerLink layerLink = LayerLink();
  final TextEditingController searchController = TextEditingController();

  void showOverlay(BuildContext context) {
    if (overlayEntry != null) {
      return;
    }
    overlayEntry = createOverlayEntry(context);
    Overlay.of(context).insert(overlayEntry!);
  }

  OverlayEntry createOverlayEntry(BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    final _debouncer = Debouncer(delay: const Duration(milliseconds: 600));

    return OverlayEntry(
      builder: (context) => BlocBuilder<SearchBloc, SearchState>(
        bloc: locator<SearchBloc>(),
        builder: (context, state) {
          return Positioned(
            // top: offset.dy + 60, // Adjust according to your UI
            left: offset.dx,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
              onTap: hideOverlay,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      children: [
                        const Spacer(
                          flex: 1,
                        ),
                        Material(
                          elevation: 8.0,
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 350,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: searchController,
                                    autofocus: true,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: AppColor.appLightGrey,
                                      ),
                                      hintText:
                                          'Search for people to connect with',
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (query) {
                                      _debouncer.run(() {
                                        locator<SearchBloc>().add(
                                          SearchPeople(searchQuery: query),
                                        );
                                        overlayEntry?.markNeedsBuild();
                                      });
                                    },
                                  ),
                                ),
                                if (state is LoadingPeople)
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: LinearProgressIndicator(
                                      color: AppColor.appPrimary,
                                      backgroundColor: AppColor.appSecondary,
                                    ),
                                  ),
                                if (state is SearchedPeople)
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxHeight: 200,
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: state.searchedUsers.length,
                                      itemBuilder: (context, index) {
                                        // add the authbloc to check whether the currentuser is the same as the user being searched for/clicked on
                                        return BlocBuilder<AuthenticationBloc,
                                            AuthenticationState>(
                                          bloc: locator<AuthenticationBloc>(),
                                          builder: (context, authState) {
                                            authState as Authenticated;
                                            return ListTile(
                                              leading: CircleAvatar(
                                                backgroundImage:
                                                    CachedNetworkImageProvider(
                                                  state.searchedUsers[index]
                                                          .profilePictureUrl ??
                                                      defaultProfilePicture,
                                                ),
                                              ),
                                              title: Text(state
                                                  .searchedUsers[index].name),
                                              subtitle: Text(
                                                state.searchedUsers[index]
                                                        .username ??
                                                    '',
                                              ),
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                    return (authState
                                                                .user.uid ==
                                                            state
                                                                .searchedUsers[
                                                                    index]
                                                                .uid)
                                                        ? ProfileScreenMobile()
                                                        : DiscoverProfileViewMobile(
                                                            user: state
                                                                    .searchedUsers[
                                                                index],
                                                          );
                                                  }),
                                                );
                                                hideOverlay();
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(
                          flex: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void hideOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColor.appBackground,
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Assets.mobile.logoDiscover.svg(
              height: 25,
              width: 161,
            ),
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) {
                        return const NotificationViewDesktop();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColor.appBlack)),
          ])),
      body: CompositedTransformTarget(
        link: layerLink,
        child: BlocBuilder<DiscoverPostsBloc, DiscoverPostsState>(
          bloc: locator<DiscoverPostsBloc>(),
          builder: (context, state) {
            if (state is InitialDiscoverPostsLoaded) {
              posts = [];
              posts.insertAll(posts.length, state.initialPosts);
            }
            if (state is MoreDiscoverPostsLoaded) {
              posts.insertAll(posts.length, state.posts);
            }
            return posts.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                            height: 72,
                            color: AppColor.appWhite,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 30),
                            child: GestureDetector(
                              onTap: () {
                                showOverlay(context);
                              },
                              child: Container(
                                  height: 44,
                                  width: 342,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColor.appLightGrey),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(6))),
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 24,
                                      ),
                                      const Icon(
                                        Icons.search,
                                        color: AppColor.appLightGrey,
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      Text(
                                        'Search for people to connect with',
                                        style: AppTextStyles.s14(
                                            color: AppColor.appLightGrey,
                                            fontType: FontType.REGULAR),
                                      ),
                                    ],
                                  )),
                            )),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: StaggeredGrid.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            children: posts.map((post) {
                              return StaggeredGridTile.count(
                                  crossAxisCellCount: 1,
                                  mainAxisCellCount: 1,
                                  child: DiscoverPostCardMobile(
                                    post: post,
                                  ));
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }
}
