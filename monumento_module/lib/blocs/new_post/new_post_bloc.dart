import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/social/models/post_model.dart';
import 'package:monumento/resources/social/social_repository.dart';

part 'new_post_event.dart';
part 'new_post_state.dart';

class NewPostBloc extends Bloc<NewPostEvent, NewPostState> {
  final SocialRepository _socialRepository;

  NewPostBloc({@required SocialRepository socialRepository})
      : assert(socialRepository != null),
        _socialRepository = socialRepository,
        super(NewPostInitial());

  @override
  Stream<NewPostState> mapEventToState(
    NewPostEvent event,
  ) async* {
    if (event is AddNewPost) {
      yield* _mapAddNewPostToState(
          image: event.image, location: event.location, title: event.title);
    }
  }

  Stream<NewPostState> _mapAddNewPostToState(
      {@required File image,
      @required String title,
      @required String location}) async* {
    try {
      yield AddingNewPost();
      final String imageUrl = await _socialRepository.uploadImageForUrl(
          file: image, address: "posts");
      if (imageUrl != null) {
        final PostModel post = await _socialRepository.uploadNewPost(
            title: title, location: location, imageUrl: imageUrl);
        yield NewPostAdded(post: post);
      } else {
        yield NewPostFailed();
      }
    } catch (_) {
      yield NewPostFailed();
    }
  }
}
