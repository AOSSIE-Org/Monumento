import 'package:json_annotation/json_annotation.dart';

enum FeatureType {
  @JsonValue("restaurant")
  restaurant,
  @JsonValue("toilet")
  toilet,
  @JsonValue("hotel")
  hotel,
  @JsonValue("atm")
  atm,
  @JsonValue("supermarket")
  supermarket,
  @JsonValue("pharmacy")
  pharmacy,
}

FeatureType getFeatureType(String feature) {
  return FeatureType.values.firstWhere(
    (e) => e.toString().split('.').last == feature.split('.').last,
    orElse: () => FeatureType.restaurant,
  );
}

enum NotificationType {
  likeNotification,
  commentNotification,
  followRequest,
  acceptedFollowRequested,
  followedYou,
}

NotificationType getNotificationType(String type) {
  return NotificationType.values.firstWhere(
    (e) => e.toString().split('.').last == type.split('.').last,
    orElse: () => NotificationType.likeNotification,
  );
}
