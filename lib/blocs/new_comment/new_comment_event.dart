part of 'new_comment_bloc.dart';

abstract class NewCommentEvent extends Equatable {
  const NewCommentEvent();
}

class AddCommentPressed extends NewCommentEvent {
  final String comment;
  final DocumentReference postDocReference;

  AddCommentPressed({@required this.comment, @required this.postDocReference});

  @override
  // TODO: implement props
  List<Object> get props => [comment, postDocReference];
}
