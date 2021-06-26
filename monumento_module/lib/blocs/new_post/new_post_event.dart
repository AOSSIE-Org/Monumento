part of 'new_post_bloc.dart';

@immutable
abstract class NewPostEvent extends Equatable {}

class AddNewPost extends NewPostEvent {
  final String title;
  final String location;
  final File image;
  AddNewPost(
      {@required this.image, @required this.location, @required this.title});
  @override
  List<Object> get props => [];
}
