import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/social/models/post_model.dart';
import 'package:monumento/resources/social/social_repository.dart';

part 'profile_posts_event.dart';
part 'profile_posts_state.dart';

class ProfilePostsBloc extends Bloc<ProfilePostsEvent, ProfilePostsState> {
  final SocialRepository _socialRepository;

  ProfilePostsBloc({@required SocialRepository socialRepository})
      : assert(socialRepository != null),
        _socialRepository = socialRepository,
        super(ProfilePostsInitial());

  @override
  Stream<ProfilePostsState> mapEventToState(
    ProfilePostsEvent event,
  ) async* {
    // TODO: implement mapEventToState
    if (event is LoadInitialProfilePosts) {
      yield* _mapLoadInitialProfilePostsToState(uid: event.uid);
    } else if (event is LoadMoreProfilePosts) {
      yield* _mapLoadMoreProfilePostsToState(
          startAfterDoc: event.startAfterDoc, uid: event.uid);
    }
  }

  Stream<ProfilePostsState> _mapLoadInitialProfilePostsToState(
      {@required String uid}) async* {
    try {
      yield LoadingInitialProfilePosts();
      List<PostModel> initialPosts =
          await _socialRepository.getInitialProfilePosts(uid: uid);
      yield InitialProfilePostsLoaded(initialPosts: initialPosts);
    } catch (_) {
      yield InitialProfilePostsLoadingFailed(message: _.toString());
    }
  }

  Stream<ProfilePostsState> _mapLoadMoreProfilePostsToState(
      {DocumentSnapshot startAfterDoc, @required String uid}) async* {
    try {
      yield LoadingMoreProfilePosts();
      List<PostModel> posts = await _socialRepository.getMoreProfilePosts(
          startAfterDoc: startAfterDoc, uid: uid);

      yield MoreProfilePostsLoaded(posts: posts);
    } catch (_) {
      yield MoreProfilePostsLoadingFailed();
    }
  }
}
