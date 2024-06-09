// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wiki_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WikiDataModel _$WikiDataModelFromJson(Map<String, dynamic> json) =>
    WikiDataModel(
      pageId: json['pageId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      extract: json['extract'] as String,
    );

Map<String, dynamic> _$WikiDataModelToJson(WikiDataModel instance) =>
    <String, dynamic>{
      'pageId': instance.pageId,
      'title': instance.title,
      'description': instance.description,
      'extract': instance.extract,
    };
