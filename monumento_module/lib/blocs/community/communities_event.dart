import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class CommunitiesEvent extends Equatable {
  const CommunitiesEvent();
}

class LoadInitialCommunities extends CommunitiesEvent {
  @override
  List<Object> get props => [];
}

class LoadMoreCommunities extends CommunitiesEvent {
  final DocumentSnapshot startAfterDoc;
  final DocumentReference postDocReference;

  LoadMoreCommunities(
      {@required this.startAfterDoc, @required this.postDocReference});

  @override
  List<Object> get props => [startAfterDoc.id];
}
