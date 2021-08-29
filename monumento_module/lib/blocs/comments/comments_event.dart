part of 'comments_bloc.dart';

abstract class CommentsEvent extends Equatable {
  const CommentsEvent();
}

class LoadInitialComments extends CommentsEvent {
  final DocumentReference postDocReference;

  LoadInitialComments({@required this.postDocReference});

  @override
  // TODO: implement props
  List<Object> get props => [postDocReference];
}

class LoadMoreComments extends CommentsEvent {
  final DocumentSnapshot startAfterDoc;
  final DocumentReference postDocReference;

  LoadMoreComments(
      {@required this.startAfterDoc, @required this.postDocReference});
  @override
  List<Object> get props => [startAfterDoc.id];
}
