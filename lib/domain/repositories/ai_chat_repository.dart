abstract class AiChatRepository {
  Future<String> sendMessage({
    required String message,
    required String monumentName,
    required String monumentDescription,
    required String monumentLocation,
  });
}
