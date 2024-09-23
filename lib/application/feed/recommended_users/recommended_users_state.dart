part of 'recommended_users_bloc.dart';

sealed class RecommendedUsersState extends Equatable {
  const RecommendedUsersState();

  @override
  List<Object> get props => [];
}

final class RecommendedUsersInitial extends RecommendedUsersState {}

final class RecommendedUsersLoading extends RecommendedUsersState {}

final class RecommendedUsersLoaded extends RecommendedUsersState {
  final List<UserEntity> recommendedUsers;

  const RecommendedUsersLoaded({required this.recommendedUsers});

  @override
  List<Object> get props => [recommendedUsers];
}
