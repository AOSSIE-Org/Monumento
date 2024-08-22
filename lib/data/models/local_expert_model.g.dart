// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_expert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalExpertModel _$LocalExpertModelFromJson(Map<String, dynamic> json) =>
    LocalExpertModel(
      expertId: json['expertId'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      designation: json['designation'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );

Map<String, dynamic> _$LocalExpertModelToJson(LocalExpertModel instance) =>
    <String, dynamic>{
      'expertId': instance.expertId,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'designation': instance.designation,
      'phoneNumber': instance.phoneNumber,
    };
