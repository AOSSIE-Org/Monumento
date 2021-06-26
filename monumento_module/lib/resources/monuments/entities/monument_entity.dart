import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class MonumentEntity extends Equatable {
  final String id;
  final String name;
  final String city;
  final String country;
  final String imageUrl;
  final String wiki;
  MonumentEntity(
      {this.id,
      this.city,
      this.country,
      this.imageUrl,
      this.name,
      @required this.wiki});

  @override
  List<Object> get props => [id];

  factory MonumentEntity.fromMap(Map<String, Object> data) {
    return MonumentEntity(
        id: data['id'] as String,
        name: data['name'] as String,
        city: data['email'] as String,
        country: data['country'] as String,
        imageUrl: data['image'] as String,
        wiki: data['wiki'] as String);
  }

  factory MonumentEntity.fromSnapshot(DocumentSnapshot snap) {
    final Map<String, dynamic> data = snap.data();
    return MonumentEntity(
        id: data['id'],
        name: data['name'],
        city: data['city'],
        country: data['country'],
        imageUrl: data['image'],
        wiki: data['wiki']);
  }

  Map<String, Object> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'country': country,
      'image': imageUrl,
      'wiki': wiki
    };
  }

  String toJson() => json.encode(toMap());

  factory MonumentEntity.fromJson(String source) =>
      MonumentEntity.fromMap(json.decode(source));
}
