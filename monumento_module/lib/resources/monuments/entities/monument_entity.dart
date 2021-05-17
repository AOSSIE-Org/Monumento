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
  MonumentEntity({this.id, this.city, this.country, this.imageUrl, this.name, @required this.wiki});

  @override
  List<Object> get props => [id];

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'country': country,
      'image': imageUrl,
      'wiki':wiki
    };
  }

  static MonumentEntity fromJson(Map<String, Object> json) {
    return MonumentEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['email'] as String,
      country: json['country'] as String,
      imageUrl: json['image'] as String,
      wiki: json['wiki'] as String
    );
  }

  static MonumentEntity fromSnapshot(DocumentSnapshot snap) {
    return MonumentEntity(
      id: snap.data['id'],
      name: snap.data['name'],
      city: snap.data['city'],
      country: snap.data['country'],
      imageUrl: snap.data['image'],
      wiki: snap.data['wiki']
    );
  }

  Map<String, Object> toDocument() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'country': country,
      'image': imageUrl,
      'wiki': wiki
    };
  }
}
