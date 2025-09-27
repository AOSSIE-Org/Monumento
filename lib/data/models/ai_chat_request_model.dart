class AiChatRequest {
  final String message;
  final String monumentName;
  final String monumentDescription;
  final String monumentLocation;

  const AiChatRequest({
    required this.message,
    required this.monumentName,
    required this.monumentDescription,
    required this.monumentLocation,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'monument_name': monumentName,
      'monument_description': monumentDescription,
      'monument_location': monumentLocation,
    };
  }
}
