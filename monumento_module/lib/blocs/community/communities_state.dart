import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../resources/communities/models/community_model.dart';

abstract class CommunitiesState extends Equatable {
  const CommunitiesState();
}

class CommunitiesInitial extends CommunitiesState {
  @override
  List<Object> get props => [];
}

class InitialCommunitiesLoaded extends CommunitiesState {
  final List<CommunityModel> initialCommunities;
  final bool hasReachedMax;

  InitialCommunitiesLoaded(
      {@required this.initialCommunities, @required this.hasReachedMax});

  @override
  List<Object> get props => [initialCommunities];
}

class MoreCommunitiesLoaded extends CommunitiesState {
  final List<CommunityModel> communities;
  final bool hasReachedMax;

  MoreCommunitiesLoaded(
      {@required this.communities, @required this.hasReachedMax});

  @override
  List<Object> get props => [communities, hasReachedMax];
}

class InitialCommunitiesLoadingFailed extends CommunitiesState {
  final String message;

  InitialCommunitiesLoadingFailed({this.message});

  @override
  List<Object> get props => [];
}

class MoreCommunitiesLoadingFailed extends CommunitiesState {
  final String message;

  MoreCommunitiesLoadingFailed({this.message});

  @override
  List<Object> get props => [];
}

class LoadingInitialCommunities extends CommunitiesState {
  @override
  List<Object> get props => [];
}

class LoadingMoreCommunities extends CommunitiesState {
  @override
  List<Object> get props => [];
}
