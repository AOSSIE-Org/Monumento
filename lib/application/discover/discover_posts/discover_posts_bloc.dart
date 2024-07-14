import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/data/models/post_model.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/domain/repositories/social_repository.dart';

part 'discover_posts_event.dart';
part 'discover_posts_state.dart';

class DiscoverPostsBloc extends Bloc<DiscoverPostsEvent, DiscoverPostsState> {
  final SocialRepository _socialRepository;
  DiscoverPostsBloc(this._socialRepository) : super(DiscoverPostsInitial()) {
    on<LoadInitialDiscoverPosts>(_mapLoadInitialDiscoverPostsToState);
    on<LoadMoreDiscoverPosts>(_mapLoadMoreDiscoverPostsToState);
  }

  Future<void> _mapLoadInitialDiscoverPostsToState(
      LoadInitialDiscoverPosts event, Emitter<DiscoverPostsState> emit) async {
    try {
      emit(LoadingInitialDiscoverPosts());

      List<PostModel> initialPosts =
          await _socialRepository.getInitialDiscoverPosts();

      List<PostEntity> initialPostsEntity =
          initialPosts.map((post) => post.toEntity()).toList();

      emit(InitialDiscoverPostsLoaded(initialPosts: initialPostsEntity));
    } catch (e) {
      emit(InitialDiscoverPostsLoadingFailed());
    }
  }

  Future<void> _mapLoadMoreDiscoverPostsToState(
      LoadMoreDiscoverPosts event, Emitter<DiscoverPostsState> emit) async {
    try {
      emit(LoadingMoreDiscoverPosts());

      List<PostModel> posts = await _socialRepository.getMorePosts(
          startAfterDocId: event.startAfterDocId);

      List<PostEntity> postsEntity =
          posts.map((post) => post.toEntity()).toList();

      if (posts.isEmpty) {
        emit(MoreDiscoverPostsLoaded(posts: postsEntity, hasReachedMax: true));
      } else {
        emit(MoreDiscoverPostsLoaded(posts: postsEntity, hasReachedMax: false));
      }
    } catch (e) {
      emit(MoreDiscoverPostsLoadingFailed(message: e.toString()));
    }
  }
}
