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
  final String image_1x1_;
  final String wiki;

  MonumentEntity(
      {this.id,
      this.city,
      this.country,
      this.imageUrl,
      this.name,
      this.image_1x1_,
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
        image_1x1_: data['image_1x1_'] as String,
        wiki: data['wikipediaLink'] as String);
  }

  factory MonumentEntity.fromSnapshot(DocumentSnapshot snap) {
    final Map<String, dynamic> data = snap.data();
    return MonumentEntity(
        id: data['id'],
        name: data['name'],
        city: data['city'],
        country: data['country'],
        imageUrl: data['image'],
        image_1x1_: data['image_1x1_'],
        wiki: data['wikipediaLink']);
  }

  Map<String, Object> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'country': country,
      'image': imageUrl,
      'image_1x1_' : image_1x1_,
      'wikipediaLink': wiki
    };
  }

  String toJson() => json.encode(toMap());

  factory MonumentEntity.fromJson(String source) =>
      MonumentEntity.fromMap(json.decode(source));
}
