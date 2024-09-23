import 'package:equatable/equatable.dart';
import 'package:monumento/domain/entities/user_entity.dart';

class CommentEntity extends Equatable {
  final String comment;
  final String postInvolvedId;
  final String commentDocId;
  final UserEntity author;
  final int timeStamp;

  const CommentEntity({
    required this.comment,
    required this.postInvolvedId,
    required this.commentDocId,
    required this.author,
    required this.timeStamp,
  });

  @override
  List<Object?> get props => [comment, postInvolvedId, author, timeStamp];
}
