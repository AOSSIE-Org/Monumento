import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/domain/repositories/social_repository.dart';

part 'recommended_users_event.dart';
part 'recommended_users_state.dart';

class RecommendedUsersBloc
    extends Bloc<RecommendedUsersEvent, RecommendedUsersState> {
  final SocialRepository _socialRepository;
  RecommendedUsersBloc(this._socialRepository)
      : super(RecommendedUsersInitial()) {
    on<GetRecommendedUsers>(_mapGetRecommendedUsersToState);
  }

  void _mapGetRecommendedUsersToState(
      GetRecommendedUsers event, Emitter<RecommendedUsersState> emit) async {
    emit(RecommendedUsersLoading());
    final recommendedUsers = await _socialRepository.getRecommendedUsers();
    final recommendedUsersEntities =
        recommendedUsers.map((user) => user.toEntity()).toList();
    emit(RecommendedUsersLoaded(recommendedUsers: recommendedUsersEntities));
  }
}
