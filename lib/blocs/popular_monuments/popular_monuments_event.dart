part of 'popular_monuments_bloc.dart';

abstract class PopularMonumentsEvent extends Equatable {
  const PopularMonumentsEvent();
}

class GetPopularMonuments extends PopularMonumentsEvent {
  @override
  List<Object> get props => [];
}
