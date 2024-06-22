import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/data/models/comment_model.dart';
import 'package:monumento/domain/entities/comment_entity.dart';
import 'package:monumento/domain/repositories/social_repository.dart';

part 'comments_event.dart';
part 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final SocialRepository _socialRepository;
  CommentsBloc(this._socialRepository) : super(CommentsInitial()) {
    on<LoadInitialComments>(_mapLoadInitialCommentsToState);
    on<LoadMoreComments>(_mapLoadMoreCommentsToState);
    on<AddCommentPressed>(_mapAddCommentPressedToState);
  }

  _mapLoadInitialCommentsToState(
      LoadInitialComments event, Emitter<CommentsState> emit) async {
    emit(LoadingInitialComments(postId: event.postDocId));
    try {
      final comments = await _socialRepository.getInitialComments(
          postDocId: event.postDocId);
      emit(InitialCommentsLoaded(
        initialComments: comments,
        hasReachedMax: comments.isEmpty,
        postId: event.postDocId,
      ));
    } catch (e) {
      emit(InitialCommentsLoadingFailed(message: e.toString()));
    }
  }

  _mapLoadMoreCommentsToState(
      LoadMoreComments event, Emitter<CommentsState> emit) async {
    emit(LoadingMoreComments(postId: event.postDocId));
    try {
      final comments = await _socialRepository.getMoreComments(
          postDocId: event.postDocId, startAfterDocId: event.startAfterId);
      emit(MoreCommentsLoaded(
        comments: comments,
        hasReachedMax: comments.isEmpty,
      ));
    } catch (e) {
      emit(MoreCommentsLoadingFailed());
    }
  }

  _mapAddCommentPressedToState(
      AddCommentPressed event, Emitter<CommentsState> emit) async {
    try {
      CommentModel commentAdded = await _socialRepository.addNewComment(
          comment: event.comment, postDocId: event.postDocId);
      emit(CommentAdded(comment: commentAdded.toEntity()));
    } catch (e) {
      emit(InitialCommentsLoadingFailed(message: e.toString()));
    }
  }
}
