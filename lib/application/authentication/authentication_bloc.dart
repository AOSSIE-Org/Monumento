import 'dart:developer';

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
    on<LogOutPressed>(_mapLogOutToState);
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
      
      int retries = 0;
      const maxRetries = 3;
      const retryDelay = Duration(milliseconds: 300);
      
      while (retries < maxRetries) {
        final (userLoggedIn, user) = await _authRepository.getUser();
        log('User: $userLoggedIn, $user (attempt ${retries + 1})');
        
        if (userLoggedIn && user != null) {
          
          emit(Authenticated(user.toEntity()));
          return;
        } else if (userLoggedIn && user == null) {
          if (retries == maxRetries - 1) {
            
            emit(OnboardingIncomplete());
            return;
          }
        } else {
         
          emit(Unauthenticated());
          return;
        }
        
        
        retries++;
        await Future.delayed(retryDelay);
      }
      
      
      emit(Unauthenticated());
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  _mapLoggedInToState(
      AuthenticationEvent event, Emitter<AuthenticationState> emit) async {
   
    int retries = 0;
    const maxRetries = 3;
    const retryDelay = Duration(milliseconds: 300);
    
    while (retries < maxRetries) {
      final (userLoggedIn, user) = await _authRepository.getUser();
      
      if (userLoggedIn && user != null) {
      
        emit(Authenticated(user.toEntity()));
        return;
      } else if (userLoggedIn && user == null) {
        if (retries == maxRetries - 1) {
          
          emit(OnboardingIncomplete());
          return;
        }
      } else {
       
        emit(Unauthenticated());
        return;
      }
      
     
      retries++;
      await Future.delayed(retryDelay);
    }
    
   
    emit(Unauthenticated());
  }

  _mapLogOutToState(
      AuthenticationEvent event, Emitter<AuthenticationState> emit) async {
    await _authRepository.signOut();
    emit(Unauthenticated());
  }

  _mapLoggedOutToState(
      AuthenticationEvent event, Emitter<AuthenticationState> emit) async* {
    emit(Unauthenticated());
  }
}
