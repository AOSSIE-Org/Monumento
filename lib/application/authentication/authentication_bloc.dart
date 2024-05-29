import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/domain/repositories/authentication_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authRepository;
  AuthenticationBloc(this._authRepository) : super(Uninitialized()) {
    on<AppStarted>(_mapAppStartedToState);
    on<LoggedIn>(_mapLoggedInToState);
    on<LoggedOut>(_mapLoggedOutToState);
  }

  _mapAppStartedToState(
      AuthenticationEvent event, Emitter<AuthenticationState> emit) async {
    try {
      final user = await _authRepository.getUser();
      if (user != null) {
        emit(Authenticated(user.toEntity()));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  _mapLoggedInToState(
      AuthenticationEvent event, Emitter<AuthenticationState> emit) async {
    final user = await _authRepository.getUser();

    if (user != null) {
      emit(Authenticated(user.toEntity()));
    } else {
      emit(Unauthenticated());
    }
  }

  _mapLoggedOutToState(
      AuthenticationEvent event, Emitter<AuthenticationState> emit) async* {
    emit(Unauthenticated());
  }
}
