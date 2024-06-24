part of 'comments_bloc.dart';

sealed class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object> get props => [];
}

class LoadInitialComments extends CommentsEvent {
  final String postDocId;

  const LoadInitialComments({required this.postDocId});

  @override
  List<Object> get props => [postDocId];
}

class LoadMoreComments extends CommentsEvent {
  final String startAfterId;
  final String postDocId;

  const LoadMoreComments({required this.startAfterId, required this.postDocId});
  @override
  List<Object> get props => [startAfterId, postDocId];
}

class AddCommentPressed extends CommentsEvent {
  final String comment;
  final String postDocId;

  const AddCommentPressed({required this.comment, required this.postDocId});

  @override
  List<Object> get props => [comment, postDocId];
}
