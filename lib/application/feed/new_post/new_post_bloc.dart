import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/data/models/post_model.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/domain/repositories/social_repository.dart';

part 'new_post_event.dart';
part 'new_post_state.dart';

class NewPostBloc extends Bloc<NewPostEvent, NewPostState> {
  final SocialRepository _socialRepository;
  NewPostBloc(this._socialRepository) : super(NewPostInitial()) {
    on<AddNewPost>(_mapAddNewPostToState);
  }

  void _mapAddNewPostToState(
      AddNewPost event, Emitter<NewPostState> emit) async {
    emit(AddingNewPost());
    try {
      emit(AddingNewPost());
      String? imageUrl;
      if (event.image != null) {
        imageUrl = await _socialRepository.uploadImageForUrl(
          file: event.image!,
          address: "posts",
        );
      }
      final PostModel post = await _socialRepository.uploadNewPost(
        title: event.title,
        location: event.location,
        imageUrl: imageUrl,
        postType: event.postType,
      );
      emit(NewPostAdded(post: post.toEntity()));
    } catch (e) {
      emit(NewPostFailed(message: e.toString()));
    }
  }
}
