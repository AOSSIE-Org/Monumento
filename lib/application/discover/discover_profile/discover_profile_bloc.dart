import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/data/models/post_model.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/domain/repositories/social_repository.dart';

part 'discover_profile_event.dart';
part 'discover_profile_state.dart';

class DiscoverProfileBloc
    extends Bloc<DiscoverProfileEvent, DiscoverProfileState> {
  final SocialRepository _socialRepository;
  DiscoverProfileBloc(this._socialRepository)
      : super(DiscoverProfileInitial()) {
    on<LoadDiscoverProfilePosts>(_mapLoadDiscoverProfilePostsToState);
  }

  void _mapLoadDiscoverProfilePostsToState(LoadDiscoverProfilePosts event,
      Emitter<DiscoverProfileState> emit) async {
    try {
      emit(DiscoverProfileLoading());

      List<PostModel> posts =
          await _socialRepository.getInitialUserPosts(uid: event.userId);

      List<PostEntity> postsEntity =
          posts.map((post) => post.toEntity()).toList();

      emit(DiscoverProfilePostsLoaded(posts: postsEntity));
    } catch (e) {
      emit(DiscoverProfileLoadingFailed());
    }
  }
}
