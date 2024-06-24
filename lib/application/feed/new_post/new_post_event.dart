part of 'new_post_bloc.dart';

sealed class NewPostEvent extends Equatable {
  const NewPostEvent();

  @override
  List<Object> get props => [];
}

class AddNewPost extends NewPostEvent {
  final String title;
  final String? location;
  final File? image;
  final int postType;
  AddNewPost(
      {this.image, this.location, required this.title, required this.postType});
  @override
  List<Object> get props => [];
}
