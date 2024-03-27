import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/social/social_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SocialRepository _socialRepository;

  SearchBloc({SocialRepository socialRepository})
      : assert(socialRepository != null),
        _socialRepository = socialRepository,
        super(SearchInitial());

  @override
  Stream<SearchState> mapEventToState(
    SearchEvent event,
  ) async* {
    // TODO: implement mapEventToState
    if (event is SearchPeople) {
      yield* _mapSearchPeopleToState(searchQuery: event.searchQuery);
    } else if (event is SearchMorePeople) {
      yield* _mapSearchMorePeopleToState(
          searchQuery: event.searchQuery, startAfterDoc: event.startAfterDoc);
    }
  }

  Stream<SearchState> _mapSearchPeopleToState(
      {@required String searchQuery}) async* {
    try {
      List<UserModel> users =
          await _socialRepository.searchPeople(searchQuery: searchQuery);
      yield SearchedPeople(searchedUsers: users);
    } catch (_) {
      print(_.toString());
      yield SearchingPeopleFailed();
    }
  }

  Stream<SearchState> _mapSearchMorePeopleToState(
      {String searchQuery, DocumentSnapshot<Object> startAfterDoc}) async* {
    try {
      List<UserModel> users = await _socialRepository.getMoreSearchResults(
          searchQuery: searchQuery, startAfterDoc: startAfterDoc);
      yield SearchedMorePeople(searchedUsers: users);
    } catch (_) {
      print(_.toString());
      yield SearchingMorePeopleFailed();
    }
  }
}
