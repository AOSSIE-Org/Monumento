import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/social/models/comment_model.dart';
import 'package:monumento/resources/social/social_repository.dart';

part 'new_comment_event.dart';
part 'new_comment_state.dart';

class NewCommentBloc extends Bloc<NewCommentEvent, NewCommentState> {
  final SocialRepository _socialRepository;

  NewCommentBloc({SocialRepository socialRepository})
      : assert(socialRepository != null),
        _socialRepository = socialRepository,
        super(NewCommentInitial());

  @override
  Stream<NewCommentState> mapEventToState(
    NewCommentEvent event,
  ) async* {
    // TODO: implement mapEventToState
    if (event is AddCommentPressed) {
      yield* _mapAddCommentPressedToState(
          comment: event.comment, documentRef: event.postDocReference);
    }
  }

  Stream<NewCommentState> _mapAddCommentPressedToState(
      {String comment, DocumentReference documentRef}) async* {
    try {
      yield AddingComment();
      CommentModel commentAdded = await _socialRepository.addNewComment(
          postDocReference: documentRef, comment: comment);
      yield CommentAdded(comment: commentAdded);
    } catch (e) {
      print(e.toString());
      yield FailedToAddComment();
    }
  }
}
