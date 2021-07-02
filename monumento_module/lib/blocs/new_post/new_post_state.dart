part of 'new_post_bloc.dart';

@immutable
abstract class NewPostState extends Equatable {}

class NewPostInitial extends NewPostState {
  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}

class NewPostAdded extends NewPostState {
  final PostModel post;
  NewPostAdded({this.post});
  @override
  List<Object> get props => [post];
}

class NewPostFailed extends NewPostState {
  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}
