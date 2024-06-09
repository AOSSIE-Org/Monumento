part of 'monument_details_bloc.dart';

sealed class MonumentDetailsEvent extends Equatable {
  const MonumentDetailsEvent();

  @override
  List<Object> get props => [];
}

class GetMonumentWikiDetails extends MonumentDetailsEvent {
  final String monumentWikiId;

  const GetMonumentWikiDetails({required this.monumentWikiId});

  @override
  List<Object> get props => [monumentWikiId];
}
