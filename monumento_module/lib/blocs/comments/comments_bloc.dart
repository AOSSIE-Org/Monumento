import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/social/models/comment_model.dart';
import 'package:monumento/resources/social/social_repository.dart';

part 'comments_event.dart';
part 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final SocialRepository _socialRepository;

  CommentsBloc({SocialRepository socialRepository})
      : assert(socialRepository != null),
        _socialRepository = socialRepository,
        super(CommentsInitial());

  @override
  Stream<CommentsState> mapEventToState(
    CommentsEvent event,
  ) async* {
    if (event is LoadInitialComments) {
      yield* _mapLoadInitialCommentsToState(
          documentRef: event.postDocReference);
    } else if (event is LoadMoreComments) {
      yield* _mapLoadMoreCommentsToState(
          startAfterDoc: event.startAfterDoc, docRef: event.postDocReference);
    }
  }

  Stream<CommentsState> _mapLoadInitialCommentsToState(
      {DocumentReference documentRef}) async* {
    try {
      yield LoadingInitialComments();
      List<CommentModel> comments = await _socialRepository.getInitialComments(
          postDocReference: documentRef);
      yield InitialCommentsLoaded(
          initialComments: comments, hasReachedMax: false);
    } catch (e) {
      print(e.toString());
      yield InitialCommentsLoadingFailed(message: e);
    }
  }

  Stream<CommentsState> _mapLoadMoreCommentsToState(
      {DocumentSnapshot startAfterDoc, DocumentReference docRef}) async* {
    try {
      yield LoadingMoreComments();
      List<CommentModel> comments = await _socialRepository.getMoreComments(
          postDocReference: docRef, startAfterDoc: startAfterDoc);
      yield MoreCommentsLoaded(
          comments: comments, hasReachedMax: comments.isEmpty);
    } catch (e) {
      print(e.toString());
      yield MoreCommentsLoadingFailed();
    }
  }
}
