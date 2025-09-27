// ai_chat_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/domain/repositories/ai_chat_repository.dart';

part 'ai_chat_bot_state.dart';

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  final AiChatRepository _aiChatRepository;

  AiChatBloc(this._aiChatRepository) : super(AiChatInitial()) {
    on<SendMessageToAi>(_mapSendMessageToAiToState);
    on<ClearAiChat>(_mapClearAiChatToState);
  }

  _mapSendMessageToAiToState(
      SendMessageToAi event, Emitter<AiChatState> emit) async {
    try {
      emit(AiChatLoading());

      final response = await _aiChatRepository.sendMessage(
        message: event.message,
        monumentName: event.monumentName,
        monumentDescription: event.monumentDescription,
        monumentLocation: event.monumentLocation,
      );

      emit(
        AiChatResponse(
          response: response,
          userMessage: event.message,
        ),
      );
    } catch (error) {
      emit(AiChatError(message: error.toString()));
    }
  }

  _mapClearAiChatToState(ClearAiChat event, Emitter<AiChatState> emit) async {
    emit(AiChatInitial());
  }
}
