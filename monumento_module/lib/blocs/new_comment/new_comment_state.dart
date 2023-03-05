part of 'new_comment_bloc.dart';

abstract class NewCommentState extends Equatable {
  const NewCommentState();
}

class NewCommentInitial extends NewCommentState {
  @override
  List<Object> get props => [];
}

class CommentAdded extends NewCommentState {
  final CommentModel comment;
  CommentAdded({this.comment});
  @override
  // TODO: implement props
  List<Object> get props => [comment];
}

class FailedToAddComment extends NewCommentState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class AddingComment extends NewCommentState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}
