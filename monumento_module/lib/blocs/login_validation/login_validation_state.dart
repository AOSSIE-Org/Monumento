abstract class LoginValidationState{}

class LoginValidationInitialState extends LoginValidationState{}

class LoginValidationValidState extends LoginValidationState{}

class LoginValidationErrorState extends LoginValidationState{
  final String errorMessage;
  LoginValidationErrorState(this.errorMessage);
}