import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/data/models/user_model.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/domain/repositories/social_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SocialRepository _socialRepository;
  SearchBloc(this._socialRepository) : super(SearchInitial()) {
    on<SearchPeople>(_mapSearchPeopleToState);
    on<SearchMorePeople>(_mapSearchMorePeopleToState);
    on<SelectSearchedPeople>(_mapSelectSearchedPeopleToState);
  }

  Future<void> _mapSearchPeopleToState(
      SearchPeople event, Emitter<SearchState> emit) async {
    try {
      emit(LoadingPeople());

      List<UserModel> users =
          await _socialRepository.searchPeople(searchQuery: event.searchQuery);

      List<UserEntity> usersEntity =
          users.map((user) => user.toEntity()).toList();

      emit(SearchedPeople(searchedUsers: usersEntity));
    } catch (e) {
      emit(SearchingPeopleFailed());
    }
  }

  Future<void> _mapSearchMorePeopleToState(
      SearchMorePeople event, Emitter<SearchState> emit) async {
    try {
      emit(LoadingMorePeople());

      List<UserModel> users = await _socialRepository.getMoreSearchResults(
          searchQuery: event.searchQuery,
          startAfterDocId: event.startAfterDocId);

      List<UserEntity> usersEntity =
          users.map((user) => user.toEntity()).toList();

      if (users.isEmpty) {
        emit(SearchedMorePeople(
            searchedUsers: usersEntity, hasReachedMax: true));
      } else {
        emit(SearchedMorePeople(
            searchedUsers: usersEntity, hasReachedMax: false));
      }
    } catch (e) {
      emit(SearchingMorePeopleFailed());
    }
  }

  void _mapSelectSearchedPeopleToState(
      SelectSearchedPeople event, Emitter<SearchState> emit) {
    emit(SearchedPeopleSelected(user: event.user));
  }
}
