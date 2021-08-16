part of 'new_post_bloc.dart';

@immutable
abstract class NewPostState extends Equatable {}

class NewPostInitial extends NewPostState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class NewPostAdded extends NewPostState {
  final PostModel post;
  NewPostAdded({this.post});
  @override
  List<Object> get props => [post];
}

class AddingNewPost extends NewPostState {
  @override
  List<Object> get props => [];
}

class NewPostFailed extends NewPostState {
  final String message;
  NewPostFailed({this.message});
  @override
  // TODO: implement props
  List<Object> get props => [];
}
