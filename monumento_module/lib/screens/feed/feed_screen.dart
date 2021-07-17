import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:monumento/blocs/feed/feed_bloc.dart';
import 'package:monumento/resources/social/models/post_model.dart';
import 'package:monumento/screens/feed/components/feed_tile.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  FeedBloc _feedBloc;
  @override
  void initState() {
    super.initState();
    _feedBloc = BlocProvider.of<FeedBloc>(context, listen: false);
    _load();
  }

  List<PostModel> posts = [];
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(builder: (
        BuildContext context,
        FeedState currentState,
        ) {
      if (currentState is InitialFeedLoadingFailed) {
        return Center(child: Text("FAiled"));
      }
      if (currentState is InitialFeedLoaded ||
          currentState is MorePostsLoaded ||
          currentState is LoadingMorePosts ||
          currentState is MorePostsLoadingFailed) {
        if (currentState is InitialFeedLoaded) {
          posts = [];
          posts.insertAll(posts.length, currentState.initialPosts);
        }
        if (currentState is MorePostsLoaded) {
          posts.insertAll(posts.length, currentState.posts);
        }

        return LazyLoadScrollView(
          child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (_, index) {
                if (currentState is LoadingMorePosts &&
                    index == posts.length - 1) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FeedTile(
                        location: posts[index].location,
                        title: posts[index].title,
                        imageUrl: posts[index].imageUrl,author: posts[index].author,timeStamp: posts[index].timeStamp,),
                      CircularProgressIndicator(),
                    ],
                  );
                }
                return FeedTile(
                  location: posts[index].location,
                  title: posts[index].title,
                  imageUrl: posts[index].imageUrl,author: posts[index].author,timeStamp: posts[index].timeStamp,);
              }),
          // Posts are loaded in a batch of 10.
          // If the number of total posts already loaded is not a multiple of 10 then there are no more posts available to load.
          onEndOfPage: posts.length % 10 == 0 ? _loadMorePosts : () {},
          scrollOffset: 300,
        );
      }

      return Center(
        child: CircularProgressIndicator(),
      );
    });
  }

  _loadMorePosts() {
    _feedBloc.add(LoadMorePosts(startAfterDoc: posts.last.documentSnapshot));
  }

  void _load() {
    _feedBloc.add(LoadInitialFeed());
  }
}
