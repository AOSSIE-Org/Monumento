import 'package:json_annotation/json_annotation.dart';
import 'package:monumento/domain/entities/local_expert_entity.dart';

part 'local_expert_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LocalExpertModel {
  final String expertId;
  final String name;
  final String imageUrl;
  final String designation;
  final String phoneNumber;

  LocalExpertModel(
      {required this.expertId,
      required this.name,
      required this.imageUrl,
      required this.designation,
      required this.phoneNumber});

  factory LocalExpertModel.fromJson(Map<String, dynamic> json) {
    return _$LocalExpertModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LocalExpertModelToJson(this);

  LocalExpertEntity toEntity() {
    return LocalExpertEntity(
      expertId: expertId,
      name: name,
      imageUrl: imageUrl,
      designation: designation,
      phoneNumber: phoneNumber,
    );
  }
}
