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

FeatureType? tryGetFeatureType(String feature) {
  try {
    return FeatureType.values.firstWhere(
      (e) => e.toString().split('.').last == feature.split('.').last,
    );
  } catch (_) {
    return null;
  }
}

FeatureType getFeatureType(String feature) {
  return tryGetFeatureType(feature) ?? FeatureType.restaurant;
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
