part of 'recommended_users_bloc.dart';

sealed class RecommendedUsersEvent extends Equatable {
  const RecommendedUsersEvent();

  @override
  List<Object> get props => [];
}

class GetRecommendedUsers extends RecommendedUsersEvent {
  const GetRecommendedUsers();

  @override
  List<Object> get props => [];
}
