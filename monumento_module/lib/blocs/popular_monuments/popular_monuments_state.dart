part of 'popular_monuments_bloc.dart';

abstract class PopularMonumentsState extends Equatable {
  const PopularMonumentsState();
}

class PopularMonumentsInitial extends PopularMonumentsState {
  @override
  List<Object> get props => [];
}

class PopularMonumentsRetrieved extends PopularMonumentsState {
  final List<DocumentSnapshot> popularMonuments;

  PopularMonumentsRetrieved({this.popularMonuments});
  @override
  List<Object> get props => [];
}

class FailedToRetrievePopularMonuments extends PopularMonumentsState {
  @override
  List<Object> get props => [];
}

class LoadingPopularMonuments extends PopularMonumentsState {
  @override
  List<Object> get props => [];
}
