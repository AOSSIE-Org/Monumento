import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/data/models/post_model.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/domain/repositories/social_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final SocialRepository _socialRepository;
  FeedBloc(this._socialRepository) : super(FeedInitial()) {
    on<LoadInitialFeed>(_mapLoadInitialFeedToState);
    on<LoadMorePosts>(_mapLoadMorePostsToState);
    on<LikePost>(_mapLikePostToState);
    on<UnlikePost>(_mapUnlikePostToState);
  }

  _mapLoadInitialFeedToState(
      LoadInitialFeed event, Emitter<FeedState> emit) async {
    try {
      emit(LoadingInitialFeed());
      List<PostModel> initialPosts =
          await _socialRepository.getInitialFeedPosts();
      List<PostEntity> initialPostsEntity =
          initialPosts.map((e) => e.toEntity()).toList();
      emit(InitialFeedLoaded(initialPosts: initialPostsEntity));
    } catch (_) {
      emit(InitialFeedLoadingFailed());
    }
  }

  _mapLoadMorePostsToState(LoadMorePosts event, Emitter<FeedState> emit) async {
    try {
      emit(LoadingMorePosts());
      List<PostModel> posts = await _socialRepository.getMorePosts(
          startAfterDocId: event.startAfterDocId);
      List<PostEntity> postsEntity = posts.map((e) => e.toEntity()).toList();
      bool hasReachedMax = posts.isEmpty;

      emit(MorePostsLoaded(posts: postsEntity, hasReachedMax: hasReachedMax));
    } catch (e) {
      emit(MorePostsLoadingFailed(message: e.toString()));
    }
  }

  _mapLikePostToState(LikePost event, Emitter<FeedState> emit) async {
    try {
      await _socialRepository.likePost(postId: event.postId);
      emit(PostLiked(postId: event.postId, isPostLiked: true));
    } catch (e) {
      emit(PostLikeFailed(postId: event.postId, message: e.toString()));
    }
  }

  _mapUnlikePostToState(UnlikePost event, Emitter<FeedState> emit) async {
    try {
      await _socialRepository.unlikePost(postId: event.postId);
      emit(PostUnLiked(postId: event.postId, isPostLiked: false));
    } catch (e) {
      emit(PostUnlikeFailed(postId: event.postId, message: e.toString()));
    }
  }
}
