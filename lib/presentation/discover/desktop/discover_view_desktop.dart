import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:monumento/application/discover/discover_posts/discover_posts_bloc.dart';
import 'package:monumento/application/discover/search/search_bloc.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/presentation/discover/desktop/discover_profile_view_desktop.dart';
import 'package:monumento/presentation/discover/desktop/widgets/discover_post_card_widget.dart';
import 'package:monumento/presentation/discover/desktop/widgets/post_details_popup_widget.dart';
import 'package:monumento/presentation/notification/desktop/notification_view_desktop.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';
import 'package:monumento/utils/debouncer.dart';
import 'package:responsive_framework/responsive_framework.dart';

class DiscoverViewDesktop extends StatefulWidget {
  const DiscoverViewDesktop({super.key});

  @override
  State<DiscoverViewDesktop> createState() => _DiscoverViewDesktopState();
}

final GlobalKey<ScaffoldState> _key = GlobalKey();

class _DiscoverViewDesktopState extends State<DiscoverViewDesktop> {
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

  void hideOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
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
                            width: 600,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: searchController,
                                    autofocus: true,
                                    decoration: const InputDecoration(
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
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                              state.searchedUsers[index]
                                                      .profilePictureUrl ??
                                                  defaultProfilePicture,
                                            ),
                                          ),
                                          title: Text(
                                              state.searchedUsers[index].name),
                                          subtitle: Text(
                                            state.searchedUsers[index]
                                                    .username ??
                                                '',
                                          ),
                                          onTap: () {
                                            locator<SearchBloc>().add(
                                              SelectSearchedPeople(
                                                user:
                                                    state.searchedUsers[index],
                                              ),
                                            );
                                            hideOverlay();
                                            _key.currentState!.openEndDrawer();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: AppColor.appBackground,
      endDrawer: BlocConsumer<SearchBloc, SearchState>(
        bloc: locator<SearchBloc>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is SearchedPeopleSelected) {
            return SizedBox(
              width: 900.w,
              child: Drawer(
                child: DiscoverProfileViewDesktop(
                  user: state.user,
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: ResponsiveVisibility(
          hiddenConditions: const [
            Condition.smallerThan(breakpoint: 800),
          ],
          child: AppBar(
            title: Text(
              'Discover People and Places',
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
                  Icons.search,
                  color: AppColor.appSecondary,
                ),
                onPressed: () {
                  showOverlay(context);
                },
              ),
              const SizedBox(
                width: 10,
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColor.appSecondary,
                ),
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
              ),
              const SizedBox(
                width: 30,
              ),
            ],
          ),
        ),
      ),
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
                ? NoPostsYet()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: StaggeredGrid.count(
                        crossAxisCount:
                            MediaQuery.sizeOf(context).width <= 600 ? 3 : 4,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: posts.map((post) {
                          return StaggeredGridTile.count(
                            crossAxisCellCount: 1,
                            mainAxisCellCount: 1,
                            child: DiscoverPostCardWidget(
                              post: post,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      child: SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                0.9,
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.8,
                                        child: PostDetailsPopupWidget(
                                          post: post,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }

  Widget NoPostsYet() {
    return Center(
      child: Text(
        "You Have No Posts Yet",
        style: AppTextStyles.s18(
          color: AppColor.appSecondary,
          fontType: FontType.MEDIUM,
        ),
      ),
    );
  }
}
