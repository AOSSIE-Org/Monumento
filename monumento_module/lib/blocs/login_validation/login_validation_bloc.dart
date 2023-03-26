import 'package:email_validator/email_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/blocs/login_validation/login_validation_event.dart';
import 'package:monumento/blocs/login_validation/login_validation_state.dart';

class LoginValidationBloc
    extends Bloc<LoginValidationEvent, LoginValidationState> {
  LoginValidationBloc(LoginValidationState initialState) : super(initialState) {
    on<LoginTextChangedEvent>((event, emit) {
      if (event.emailValue == "" && EmailValidator.validate(event.emailValue)) {
        emit(LoginValidationErrorState("Please enter a valid email address"));
      }
      else if(event.passwordValue.length<6){
        emit(LoginValidationErrorState("Please enter a vlaid password"));
      }
      else{
        emit(LoginValidationValidState());
      }
    });

    // on<LoginSubmittedEvent>((event, emit) {});
  }
}
