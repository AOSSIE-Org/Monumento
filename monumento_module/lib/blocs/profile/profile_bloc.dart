import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/monuments/monument_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  MonumentRepository _firebaseMonumentRepository;
  ProfileBloc({@required MonumentRepository firebaseMonumentRepository})
      : assert(firebaseMonumentRepository != null),
        _firebaseMonumentRepository = firebaseMonumentRepository,
        super(ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    if (event is GetProfileData) {
      yield* _mapGetProfileDataToState(userId: event.userId);
    }
  }

  Stream<ProfileState> _mapGetProfileDataToState({String userId}) async* {
    try {
      final DocumentSnapshot profileData =
          await _firebaseMonumentRepository.getProfileData(userId);
      yield ProfileDataRetrieved(profileDoc: profileData);
    } catch (_) {
      yield FailedToRetrieveProfileData();
    }
  }
}
