import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:monumento/blocs/discover_posts/discover_posts_bloc.dart';
import 'package:monumento/blocs/search/search_bloc.dart';
import 'package:monumento/navigation/arguments.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/social/models/post_model.dart';
import 'package:monumento/resources/social/social_repository.dart';
import 'package:monumento/ui/screens/discover/components/search_bar.dart';
import 'package:monumento/ui/screens/profile/profile_screen.dart';
import 'package:monumento/ui/widgets/custom_app_bar.dart';
import 'package:monumento/ui/widgets/discover_post_loading.dart';
import 'package:monumento/ui/widgets/search_tile_loading.dart';
import 'package:monumento/utilities/constants.dart';

//TODO lazy loading for search results
class SearchScreen extends StatefulWidget {
  final FocusNode node;
  const SearchScreen({Key key, @required this.node}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _showSearch = false;
  List<UserModel> users = [];
  List<PostModel> posts = [];
  SearchBloc _searchBloc;
  DiscoverPostsBloc _discoverPostsBloc;
  TextEditingController _searchController;
  int count = 1;

  @override
  void initState() {
    super.initState();
    widget.node.addListener(() {
      setState(() {
        widget.node.hasFocus ? _showSearch = true : _showSearch = false;
      });
    });
    _searchBloc = SearchBloc(
        socialRepository: RepositoryProvider.of<SocialRepository>(context));
    _discoverPostsBloc = DiscoverPostsBloc(
        socialRepository: RepositoryProvider.of<SocialRepository>(context));
    _discoverPostsBloc.add(LoadInitialDiscoverPosts());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (widget.node.hasFocus) {
            widget.node.unfocus();
            return false;
          } else {
            return true;
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: LazyLoadScrollView(
            scrollOffset: 300,
            onEndOfPage: () async {
              if (widget.node.hasFocus) {
                SearchState state = _searchBloc.state;
                if (state is SearchedPeople) {
                  _loadMoreSearchResults();
                } else if (state is SearchedMorePeople && state.hasReachedMax) {
                  _loadMoreSearchResults();
                }
              } else {
                DiscoverPostsState state = _discoverPostsBloc.state;
                if (state is InitialDiscoverPostsLoaded) {
                  _loadMoreDiscoverPosts();
                } else if (state is MoreDiscoverPostsLoaded &&
                    state.hasReachedMax) {
                  _loadMoreDiscoverPosts();
                }
              }
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  sliver:
                      CustomAppBar(title: 'Discover', textStyle: kStyle28W600),
                ),
                SliverToBoxAdapter(
                  child: SearchBar(
                    node: widget.node,
                    onChange: (query) {
                      _searchBloc.add(SearchPeople(
                          searchQuery: (query as String).replaceAll(' ', '')));
                      print((query as String).replaceAll(' ', ''));
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 24,
                  ),
                ),
                !_showSearch ? _buildDiscoverPosts() : _buildSearchView()
              ],
            ),
          ),
        ));
  }

  _loadMoreSearchResults() {
    _searchBloc.add(SearchMorePeople(
        searchQuery: _searchController.text,
        startAfterDoc: users.last.documentSnapshot));
  }

  _loadMoreDiscoverPosts() {
    _discoverPostsBloc
        .add(LoadMoreDiscoverPosts(startAfterDoc: posts.last.documentSnapshot));
  }

  Widget _buildDiscoverPosts() {
    return BlocBuilder<DiscoverPostsBloc, DiscoverPostsState>(
      bloc: _discoverPostsBloc,
      builder: (context, currentState) {
        if (currentState is InitialDiscoverPostsLoadingFailed) {
          return SliverFillRemaining(
              child: Center(child: Text("Failed to load posts")));
        }

        if (currentState is InitialDiscoverPostsLoaded ||
            currentState is MoreDiscoverPostsLoaded ||
            currentState is LoadingMoreDiscoverPosts ||
            currentState is MoreDiscoverPostsLoadingFailed) {
          if (currentState is InitialDiscoverPostsLoaded) {
            posts = [];
            posts.insertAll(posts.length, currentState.initialPosts);
          }
          if (currentState is MoreDiscoverPostsLoaded) {
            posts.insertAll(posts.length, currentState.posts);
          }
          return posts.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Text("No posts to display"),
                  ),
                )
              : SliverGrid(
                  delegate: SliverChildBuilderDelegate((_, index) {
                    return ClipRRect(
                      child:
                          CachedNetworkImage(imageUrl: posts[index].imageUrl),
                      borderRadius: BorderRadius.circular(5),
                    );
                  }, childCount: posts.length),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8),
                );
        }
        return SliverGrid(
          delegate: SliverChildBuilderDelegate((_, index) {
            return ClipRRect(
              child: DiscoverPostLoading(),
              borderRadius: BorderRadius.circular(5),
            );
          }, childCount: 10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8),
        );
      },
    );
  }

  Widget _buildSearchView() {
    return BlocBuilder<SearchBloc, SearchState>(
      bloc: _searchBloc,
      builder: (context, state) {
        if (state is SearchedPeople) {
          users = [];
          users.insertAll(0, state.searchedUsers);
        } else if (state is SearchedMorePeople) {
          users.insertAll(users.length, state.searchedUsers);
        }
        if (state is SearchingMorePeopleFailed) {
          return SliverFillRemaining(
            child: Center(
              child: Text("Failed to load more results"),
            ),
          );
        }
        if (state is SearchingPeopleFailed) {
          return SliverFillRemaining(
            child: Center(
              child: Text("Failed to load results"),
            ),
          );
        }
        if (state is LoadingPeople) {
          return SliverList(
            delegate: SliverChildBuilderDelegate((_, index) {
              return SearchTileLoading();
            }),
          );
        }

        return users.length == 0
            ? SliverFillRemaining(
                child: Center(
                  child: Text("No Search Results"),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate((_, index) {
                  if (state is LoadingMorePeople && index == users.length - 1) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: users[index].profilePictureUrl,
                              placeholder: (_, text) {
                                return Container(
                                  color: Colors.white,
                                  width: 60,
                                );
                              },
                            ),
                          ),
                          title: Text(users[index].name),
                          subtitle: Text(users[index].email.split("@")[0]),
                          onTap: () {
                            widget.node.unfocus();
                            Navigator.pushNamed(
                                context, ProfileScreen.route,
                                arguments:
                                ProfileScreenArguments(user: users[index]));
                          },
                        ),
                        CircularProgressIndicator(),
                      ],
                    );
                  }
                  return ListTile(
                    leading: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: users[index].profilePictureUrl,
                        placeholder: (_, text) {
                          return Container(
                            color: Colors.white,
                            width: 60,
                          );
                        },
                      ),
                    ),
                    title: Text(users[index].name),
                    subtitle: Text(users[index].email.split("@")[0]),
                    onTap: () => Navigator.pushNamed(
                        context, ProfileScreen.route,
                        arguments: ProfileScreenArguments(user: users[index])),
                  );
                }, childCount: users.length),
              );
      },
    );
  }
}
//TODO postFor field for feed after follow feature is implemented
