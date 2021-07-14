import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:monumento/blocs/discover_posts/discover_posts_bloc.dart';
import 'package:monumento/blocs/search/search_bloc.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/social/models/post_model.dart';

//TODO lazy loading for search results
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  FocusNode _node = FocusNode();
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
    _node.addListener(() {
      setState(() {
        _node.hasFocus ? _showSearch = true : _showSearch = false;
      });
    });
    _searchBloc = BlocProvider.of<SearchBloc>(context, listen: false);
    _discoverPostsBloc = BlocProvider.of<DiscoverPostsBloc>(context, listen: false);
    _discoverPostsBloc.add(LoadInitialDiscoverPosts());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (_node.hasFocus) {
            _node.unfocus();
            return false;
          } else {
            return true;
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
          child: LazyLoadScrollView(
            scrollOffset: 300,
            onEndOfPage: () async {
              if (_node.hasFocus) {
                // _loadMoreSearchResults();
              } else {
                // _loadMoreDiscoverPosts();
              }
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SearchBar(
                    node: _node,
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
                !_showSearch
                    ? BlocBuilder<DiscoverPostsBloc, DiscoverPostsState>(
                        builder: (context, currentState) {
                          if (currentState
                              is InitialDiscoverPostsLoadingFailed) {
                            return SliverToBoxAdapter(child: Center(child: Text("FAiled")));
                          }

                          if (currentState is InitialDiscoverPostsLoaded ||
                              currentState is MoreDiscoverPostsLoaded ||
                              currentState is LoadingMoreDiscoverPosts ||
                              currentState is MoreDiscoverPostsLoadingFailed) {
                            if (currentState is InitialDiscoverPostsLoaded) {
                              posts.insertAll(
                                  posts.length, currentState.initialPosts);
                            }
                            if (currentState is MoreDiscoverPostsLoaded) {
                              posts.insertAll(posts.length, currentState.posts);
                            }
                            return SliverGrid(
                              delegate: SliverChildBuilderDelegate((_, index) {
                                return ClipRRect(
                                  child: CachedNetworkImage(
                                      imageUrl: posts[index].imageUrl),
                                  borderRadius: BorderRadius.circular(5),
                                );
                              }, childCount: posts.length),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 1,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8),
                            );
                          }
                          return SliverToBoxAdapter(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      )
                    : BlocBuilder<SearchBloc, SearchState>(
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
                          if(state is LoadingPeople){
                            return SliverFillRemaining(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          return users.length == 0
                              ? SliverFillRemaining(
                                  child: Center(
                                    child: Text("No Search Results"),
                                  ),
                                )
                              : SliverList(
                                  delegate:
                                      SliverChildBuilderDelegate((_, index) {
                                    if (state is LoadingMorePeople &&
                                        index == users.length - 1) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    "https://data.whicdn.com/images/336211867/original.jpg",
                                              ),
                                            ),
                                            title: Text(users[index].name),
                                            subtitle: Text(users[index]
                                                .email
                                                .split("@")[0]),
                                          ),
                                          CircularProgressIndicator(),
                                        ],
                                      );
                                    }
                                    return ListTile(
                                      leading: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              "https://data.whicdn.com/images/336211867/original.jpg",
                                        ),
                                      ),
                                      title: Text(users[index].name),
                                      subtitle: Text(
                                          users[index].email.split("@")[0]),
                                    );
                                  }, childCount: users.length),
                                );
                        },
                      ),
              ],
            ),
          ),
        ));
  }

  _loadMoreSearchResults() {
    if (users.length % 10 == 0) {
      _searchBloc.add(SearchMorePeople(
          searchQuery: _searchController.text,
          startAfterDoc: users.last.documentSnapshot));
    }
  }

  _loadMoreDiscoverPosts() {
    if (posts.length % 10 == 0) {
      _discoverPostsBloc.add(
          LoadMoreDiscoverPosts(startAfterDoc: posts.last.documentSnapshot));
    }
  }
}

class SearchBar extends StatelessWidget {
  final FocusNode node;
  final Function onChange;
  final TextEditingController controller;

  const SearchBar({@required this.node, this.onChange, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChange,
      focusNode: node,
      controller: controller,
      decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey, width: 2)),
          hintText: "Search People",
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          prefixIcon: Icon(Icons.search_outlined)),
    );
  }
}
//TODO Search Screen : Random Posts, Onclick search results to profile page, lazyloading according to posts and search results
//TODO Google Sign In : Navigate user to a form for reviewing the info retrieved and choosing a username
//TODO Username : Check available username before signing up
//TODO Notification Screen
//TODO Comments Screen
//TODO Profile Screen (User's posts and Follow Feature)
//TODO postFor field for feed after follow feature is implemented
//TODO Create issues and PRs
