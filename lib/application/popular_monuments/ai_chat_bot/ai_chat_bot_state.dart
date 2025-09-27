// ai_chat_event.dart
part of 'ai_chat_bot_bloc.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();

  @override
  List<Object> get props => [];
}

class SendMessageToAi extends AiChatEvent {
  final String message;
  final String monumentName;
  final String monumentDescription;
  final String monumentLocation;

  const SendMessageToAi({
    required this.message,
    required this.monumentName,
    required this.monumentDescription,
    required this.monumentLocation,
  });

  @override
  List<Object> get props =>
      [message, monumentName, monumentDescription, monumentLocation];
}

class ClearAiChat extends AiChatEvent {}

abstract class AiChatState extends Equatable {
  const AiChatState();

  @override
  List<Object> get props => [];
}

class AiChatInitial extends AiChatState {}

class AiChatLoading extends AiChatState {}

class AiChatResponse extends AiChatState {
  final String response;
  final String userMessage;

  const AiChatResponse({
    required this.response,
    required this.userMessage,
  });

  @override
  List<Object> get props => [response, userMessage];
}

class AiChatError extends AiChatState {
  final String message;

  const AiChatError({required this.message});

  @override
  List<Object> get props => [message];
}
