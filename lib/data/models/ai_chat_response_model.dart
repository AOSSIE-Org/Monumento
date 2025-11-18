class AiChatResponse {
  final String content;
  final DateTime timestamp;
  final bool isSuccess;
  final String? errorMessage;

  const AiChatResponse({
    required this.content,
    required this.timestamp,
    this.isSuccess = true,
    this.errorMessage,
  });

  factory AiChatResponse.success(String content) {
    return AiChatResponse(
      content: content,
      timestamp: DateTime.now(),
      isSuccess: true,
    );
  }

  factory AiChatResponse.error(String errorMessage) {
    return AiChatResponse(
      content: '',
      timestamp: DateTime.now(),
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
