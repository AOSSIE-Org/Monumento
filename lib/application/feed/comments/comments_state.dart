part of 'comments_bloc.dart';

sealed class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object> get props => [];
}

final class CommentsInitial extends CommentsState {}

class InitialCommentsLoaded extends CommentsState {
  final List<CommentModel> initialComments;
  final String postId;
  final bool hasReachedMax;

  const InitialCommentsLoaded(
      {required this.postId,
      required this.initialComments,
      required this.hasReachedMax});

  @override
  List<Object> get props => [initialComments, postId, hasReachedMax];
}

class MoreCommentsLoaded extends CommentsState {
  final List<CommentModel> comments;
  final bool hasReachedMax;
  const MoreCommentsLoaded(
      {required this.comments, required this.hasReachedMax});
  @override
  List<Object> get props => [comments, hasReachedMax];
}

class InitialCommentsLoadingFailed extends CommentsState {
  final String message;
  const InitialCommentsLoadingFailed({required this.message});
  @override
  List<Object> get props => [];
}

class MoreCommentsLoadingFailed extends CommentsState {
  @override
  List<Object> get props => [];
}

class LoadingInitialComments extends CommentsState {
  final String postId;

  const LoadingInitialComments({required this.postId});
  @override
  List<Object> get props => [postId];
}

class LoadingMoreComments extends CommentsState {
  final String postId;

  const LoadingMoreComments({required this.postId});
  @override
  List<Object> get props => [postId];
}

class CommentAdded extends CommentsState {
  final CommentEntity comment;
  const CommentAdded({required this.comment});
  @override
  List<Object> get props => [comment];
}

class FailedToAddComment extends CommentsState {
  @override
  List<Object> get props => [];
}

class AddingComment extends CommentsState {
  @override
  List<Object> get props => [];
}
