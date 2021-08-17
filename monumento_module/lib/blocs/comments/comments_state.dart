part of 'comments_bloc.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();
}

class CommentsInitial extends CommentsState {
  @override
  List<Object> get props => [];
}

class InitialCommentsLoaded extends CommentsState {
  final List<CommentModel> initialComments;
  final bool hasReachedMax;

  InitialCommentsLoaded(
      {@required this.initialComments, @required this.hasReachedMax});

  @override
  List<Object> get props => [initialComments];
}

class MoreCommentsLoaded extends CommentsState {
  final List<CommentModel> comments;
  final bool hasReachedMax;
  MoreCommentsLoaded({@required this.comments, @required this.hasReachedMax});
  @override
  List<Object> get props => [comments, hasReachedMax];
}

class InitialCommentsLoadingFailed extends CommentsState {
  final String message;
  InitialCommentsLoadingFailed({this.message});
  @override
  List<Object> get props => [];
}

class MoreCommentsLoadingFailed extends CommentsState {
  @override
  List<Object> get props => [];
}

class LoadingInitialComments extends CommentsState {
  @override
  List<Object> get props => [];
}

class LoadingMoreComments extends CommentsState {
  @override
  List<Object> get props => [];
}
