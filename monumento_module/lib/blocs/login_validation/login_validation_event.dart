abstract class LoginValidationEvent{}

class LoginTextChangedEvent extends LoginValidationEvent{
  final String emailValue;
  final String passwordValue;
  LoginTextChangedEvent(this.emailValue, this.passwordValue); 
}

class LoginSubmittedEvent extends LoginValidationEvent{
final String email;
final String password;
LoginSubmittedEvent(this.email, this.password);
}