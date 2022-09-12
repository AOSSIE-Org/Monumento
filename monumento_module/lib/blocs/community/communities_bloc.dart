import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/blocs/community/communities_event.dart';
import 'package:monumento/blocs/community/communities_state.dart';
import 'package:monumento/resources/communities/community_repository.dart';
import 'package:monumento/resources/communities/models/community_model.dart';

class CommunitiesBloc extends Bloc<CommunitiesEvent, CommunitiesState> {
   CommunityRepository _communityRepository;

  CommunitiesBloc({CommunityRepository communityRepository})
      : assert(communityRepository != null),
        _communityRepository = communityRepository,
        super(CommunitiesInitial());

  @override
  Stream<CommunitiesState> mapEventToState(
    CommunitiesEvent event,
  ) async* {
    if (event is LoadInitialCommunities) {
      yield* _mapLoadInitialCommunitiesToState();
    } else if (event is LoadMoreCommunities) {
      yield* _mapLoadMoreCommunitiesToState(
          startAfterDoc: event.startAfterDoc, documentReference: event.postDocReference);
    }
  }

  Stream<CommunitiesState> _mapLoadInitialCommunitiesToState(
      {DocumentReference documentReference}) async* {
    try {
      yield LoadingInitialCommunities();
      List<CommunityModel> communities = await _communityRepository
          .getInitialCommunity(postDocReference: documentReference);
      yield InitialCommunitiesLoaded(
          initialCommunities: communities, hasReachedMax: false);
    } catch (e) {
      print(e.toString());
      yield InitialCommunitiesLoadingFailed(message: e);
    }
  }

  Stream<CommunitiesState> _mapLoadMoreCommunitiesToState(
      {DocumentSnapshot startAfterDoc, DocumentReference documentReference}) async* {
    try {
      yield LoadingMoreCommunities();
      List<CommunityModel> communities = await _communityRepository
          .getInitialCommunity(postDocReference: documentReference);
      yield MoreCommunitiesLoaded(
          communities: communities, hasReachedMax: false);
    } catch (e) {
      print(e.toString());
      yield MoreCommunitiesLoadingFailed(message: e);
    }
  }

}
