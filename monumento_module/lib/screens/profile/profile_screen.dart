import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:monumento/blocs/profile/profile_bloc.dart';
import 'package:monumento/blocs/profile_posts/profile_posts_bloc.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/social/models/post_model.dart';

class ProfileScreen extends StatefulWidget {
  static final String route = "/profileScreen";
  final UserModel user;

  const ProfileScreen({@required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfilePostsBloc _profilePostsBloc;

  @override
  void initState() {
    _profilePostsBloc = BlocProvider.of<ProfilePostsBloc>(context);
    _profilePostsBloc.add(LoadInitialProfilePosts(uid: widget.user.uid));

    super.initState();
  }

  List<PostModel> posts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: LazyLoadScrollView(
            scrollOffset: 300,
            onEndOfPage: () {
              _profilePostsBloc.add(LoadMoreProfilePosts(
                  startAfterDoc: posts.last.documentSnapshot,
                  uid: widget.user.uid));
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ClipOval(
                        child: widget.user.profilePictureUrl != null
                            ? CachedNetworkImage(
                          imageUrl: widget.user.profilePictureUrl,
                          height: MediaQuery.of(context).size.height * .15,
                        )
                            : Image.asset("assets/explore.jpg"),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(widget.user.name),
                      SizedBox(
                        height: 8,
                      ),
                      Text(widget.user.email.split("@")[0]), //TODO : username
                      SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Follow",
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(Colors.amberAccent)),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 16,
                  ),
                ),
                BlocBuilder<ProfilePostsBloc, ProfilePostsState>(
                  bloc: _profilePostsBloc,
                  builder: (context, currentState) {
                    if (currentState is InitialProfilePostsLoadingFailed) {
                      return SliverFillRemaining(
                        child:  Center(
                          child: Text(currentState.message),
                        ),

                      );
                    }

                    if (currentState is InitialProfilePostsLoaded ||
                        currentState is MoreProfilePostsLoaded ||
                        currentState is LoadingMoreProfilePosts ||
                        currentState is MoreProfilePostsLoadingFailed) {
                      if (currentState is InitialProfilePostsLoaded) {
                        posts.insertAll(posts.length, currentState.initialPosts);
                      }
                      if (currentState is MoreProfilePostsLoaded) {
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8),
                      );
                    }
                    return SliverFillRemaining(
                      child:  Center(
                        child: CircularProgressIndicator(),
                      ),

                    );
                  },
                ),
              ],
            ),
          )),
    );
  }
}
