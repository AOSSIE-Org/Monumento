import 'package:flutter_bloc/flutter_bloc.dart';
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
    on<LoggedInWithInCompleteOnboarding>(
        _mapLoggedInWithInCompleteOnboardingToState);
  }

  _mapLoggedInWithInCompleteOnboardingToState(
      AuthenticationEvent event, Emitter<AuthenticationState> emit) {
    emit(OnboardingIncomplete());
  }

  _mapAppStartedToState(
      AuthenticationEvent event, Emitter<AuthenticationState> emit) async {
    try {
      final (userLoggedIn, user) = await _authRepository.getUser();
      print('User: $userLoggedIn, $user');
      if (userLoggedIn && user != null) {
        emit(Authenticated(user.toEntity()));
      } else if (userLoggedIn && user == null) {
        emit(OnboardingIncomplete());
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  _mapLoggedInToState(
      AuthenticationEvent event, Emitter<AuthenticationState> emit) async {
    final (userLoggedIn, user) = await _authRepository.getUser();

    if (userLoggedIn && user != null) {
      emit(Authenticated(user.toEntity()));
    } else if (userLoggedIn && user == null) {
      emit(OnboardingIncomplete());
    } else {
      emit(Unauthenticated());
    }
  }

  _mapLoggedOutToState(
      AuthenticationEvent event, Emitter<AuthenticationState> emit) async* {
    emit(Unauthenticated());
  }
}
