part of 'new_post_bloc.dart';

sealed class NewPostState extends Equatable {
  const NewPostState();

  @override
  List<Object> get props => [];
}

final class NewPostInitial extends NewPostState {}

class NewPostAdded extends NewPostState {
  final PostEntity post;
  NewPostAdded({required this.post});
  @override
  List<Object> get props => [post];
}

class AddingNewPost extends NewPostState {
  @override
  List<Object> get props => [];
}

class NewPostFailed extends NewPostState {
  final String message;
  NewPostFailed({required this.message});
  @override
  // TODO: implement props
  List<Object> get props => [];
}
