import 'package:json_annotation/json_annotation.dart';
import 'package:monumento/domain/entities/wiki_data_entity.dart';

part 'wiki_data_model.g.dart';

@JsonSerializable(explicitToJson: true)
class WikiDataModel {
  final String pageId;
  final String title;
  final String description;
  final String extract;

  WikiDataModel(
      {required this.pageId,
      required this.title,
      required this.description,
      required this.extract});

  factory WikiDataModel.fromJson(Map<String, dynamic> json) =>
      _$WikiDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$WikiDataModelToJson(this);

  WikiDataEntity toEntity() {
    return WikiDataEntity(
      pageId: pageId,
      title: title,
      description: description,
      extract: extract,
    );
  }
}
