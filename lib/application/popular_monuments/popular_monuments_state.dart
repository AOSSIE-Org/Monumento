part of 'popular_monuments_bloc.dart';

sealed class PopularMonumentsState extends Equatable {
  const PopularMonumentsState();

  @override
  List<Object> get props => [];
}

class PopularMonumentsInitial extends PopularMonumentsState {
  @override
  List<Object> get props => [];
}

class PopularMonumentsRetrieved extends PopularMonumentsState {
  final List<MonumentEntity> popularMonuments;

  const PopularMonumentsRetrieved({required this.popularMonuments});
  @override
  List<Object> get props => [popularMonuments];
}

class FailedToRetrievePopularMonuments extends PopularMonumentsState {
  @override
  List<Object> get props => [];
}

class LoadingPopularMonuments extends PopularMonumentsState {
  @override
  List<Object> get props => [];
}
