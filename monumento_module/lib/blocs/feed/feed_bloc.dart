import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/social/models/post_model.dart';
import 'package:monumento/resources/social/social_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final SocialRepository _socialRepository;
  FeedBloc({SocialRepository socialRepository})
      : assert(socialRepository != null),
        _socialRepository = socialRepository,
        super(FeedInitial());

  @override
  Stream<FeedState> mapEventToState(
    FeedEvent event,
  ) async* {
    if (event is LoadInitialFeed) {
      yield* _mapLoadInitialFeedToState();
    } else if (event is LoadMorePosts) {
      yield* _mapLoadMorePostsToState(startAfterDoc: event.startAfterDoc);
    }
  }

  Stream<FeedState> _mapLoadInitialFeedToState() async* {
    try {
      yield LoadingInitialFeed();
      List<PostModel> initialPosts =
          await _socialRepository.getInitialFeedPosts();
      yield InitialFeedLoaded(initialPosts: initialPosts);
    } catch (_) {
      yield InitialFeedLoadingFailed();
    }
  }

  Stream<FeedState> _mapLoadMorePostsToState(
      {@required DocumentSnapshot startAfterDoc}) async* {
    try {
      yield LoadingMorePosts();
      List<PostModel> posts =
          await _socialRepository.getMorePosts(startAfterDoc: startAfterDoc);

      yield MorePostsLoaded(posts: posts);
    } catch (e) {
      yield MorePostsLoadingFailed(message: e.toString());
    }
  }
}
