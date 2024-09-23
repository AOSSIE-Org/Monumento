import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/data/models/post_model.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/domain/repositories/social_repository.dart';

part 'profile_posts_event.dart';
part 'profile_posts_state.dart';

class ProfilePostsBloc extends Bloc<ProfilePostsEvent, ProfilePostsState> {
  final SocialRepository _socialRepository;

  ProfilePostsBloc(this._socialRepository):super(ProfilePostsInitial()){
    on<LoadInitialProfilePosts>(_mapLoadInitialProfilePostsToState);
    on<LoadMoreProfilePosts>(_mapLoadMoreProfilePostsToState);
  }

  _mapLoadInitialProfilePostsToState(LoadInitialProfilePosts event, Emitter<ProfilePostsState> emit ) async{
    try {
      emit(LoadingInitialProfilePosts());
      List<PostModel> initialPosts =
          await _socialRepository.getInitialProfilePosts();
      List<PostEntity> initialPostsEntity =
          initialPosts.map((e) => e.toEntity()).toList();
      emit(InitialProfilePostsLoaded(initialPosts: initialPostsEntity));
    } catch (_) {
      emit(InitialProfilePostsLoadingFailed(message: _.toString()));
    }
  }

  _mapLoadMoreProfilePostsToState(LoadMoreProfilePosts event, Emitter<ProfilePostsState> emit) async{
    try {
      emit(LoadingMoreProfilePosts());
      List<PostModel> posts = await _socialRepository.getMoreProfilePosts(
          startAfterDocId: event.startAfterDocId);
      List<PostEntity> postsEntity = posts.map((e) => e.toEntity()).toList();
      bool hasReachedMax = posts.isEmpty;

      emit(MoreProfilePostsLoaded(posts:postsEntity,hasReachedMax:hasReachedMax));
    } catch (_) {
      emit(MoreProfilePostsLoadingFailed());
    }
  }
}
