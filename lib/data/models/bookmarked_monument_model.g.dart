// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarked_monument_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookmarkedMonumentModel _$BookmarkedMonumentModelFromJson(
        Map<String, dynamic> json) =>
    BookmarkedMonumentModel(
      bookmarkedByUid: json['bookmarkedByUid'] as String,
      monumentModel:
          MonumentModel.fromJson(json['monumentModel'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BookmarkedMonumentModelToJson(
        BookmarkedMonumentModel instance) =>
    <String, dynamic>{
      'bookmarkedByUid': instance.bookmarkedByUid,
      'monumentModel': instance.monumentModel.toJson(),
    };
