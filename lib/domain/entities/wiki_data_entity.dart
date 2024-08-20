import 'package:equatable/equatable.dart';

class WikiDataEntity extends Equatable {
  final String pageId;
  final String title;
  final String description;
  final String extract;

  const WikiDataEntity(
      {required this.pageId,
      required this.title,
      required this.description,
      required this.extract});

  @override
  List<Object?> get props => [pageId, title, description, extract];
}
