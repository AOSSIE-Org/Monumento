import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/social/models/post_model.dart';
import 'package:monumento/resources/social/social_repository.dart';

part 'discover_posts_event.dart';
part 'discover_posts_state.dart';

class DiscoverPostsBloc extends Bloc<DiscoverPostsEvent, DiscoverPostsState> {
  final SocialRepository _socialRepository;

  DiscoverPostsBloc({@required SocialRepository socialRepository})
      : assert(socialRepository != null),
        _socialRepository = socialRepository,
        super(DiscoverPostsInitial());

  @override
  Stream<DiscoverPostsState> mapEventToState(
    DiscoverPostsEvent event,
  ) async* {
    // TODO: implement mapEventToState
    if (event is LoadInitialDiscoverPosts) {
      yield* _mapLoadInitialDiscoverPostsToState();
    } else if (event is LoadMoreDiscoverPosts) {
      yield* _mapLoadMoreDiscoverPostsToState(
          startAfterDoc: event.startAfterDoc);
    }
  }

  Stream<DiscoverPostsState> _mapLoadInitialDiscoverPostsToState() async* {
    try {
      yield LoadingInitialDiscoverPosts();

      List<PostModel> initialPosts =
          await _socialRepository.getInitialFeedPosts();

      yield InitialDiscoverPostsLoaded(initialPosts: initialPosts);
    } catch (e) {
      yield InitialDiscoverPostsLoadingFailed();
    }
  }

  Stream<DiscoverPostsState> _mapLoadMoreDiscoverPostsToState(
      {DocumentSnapshot startAfterDoc}) async* {
    try {
      yield LoadingMoreDiscoverPosts();
      List<PostModel> posts =
          await _socialRepository.getMorePosts(startAfterDoc: startAfterDoc);

      yield MoreDiscoverPostsLoaded(posts: posts);
    } catch (e) {
      yield MoreDiscoverPostsLoadingFailed(message: e.toString());
    }
  }
}
