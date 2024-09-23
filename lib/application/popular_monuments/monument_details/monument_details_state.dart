part of 'monument_details_bloc.dart';

sealed class MonumentDetailsState extends Equatable {
  const MonumentDetailsState();

  @override
  List<Object> get props => [];
}

final class MonumentDetailsInitial extends MonumentDetailsState {}

class LoadingMonumentWikiDetails extends MonumentDetailsState {
  @override
  List<Object> get props => [];
}

class MonumentWikiDetailsRetrieved extends MonumentDetailsState {
  final WikiDataEntity wikiData;

  const MonumentWikiDetailsRetrieved({required this.wikiData});
  @override
  List<Object> get props => [wikiData];
}

class FailedToRetrieveMonumentWikiDetails extends MonumentDetailsState {
  @override
  List<Object> get props => [];
}
