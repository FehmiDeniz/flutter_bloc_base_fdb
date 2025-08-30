part of 'login_bloc.dart';

abstract class LoginEvent {
  const LoginEvent();
}

class LoginSubmitted extends LoginEvent {
  final String username;
  final String password;
  final String? deviceUnique;

  const LoginSubmitted({
    required this.username,
    required this.password,
    this.deviceUnique,
  });
}

class TogglePasswordVisibility extends LoginEvent {
  const TogglePasswordVisibility();
}

class ToggleRememberMe extends LoginEvent {
  const ToggleRememberMe();
}

class CheckSavedCredentials extends LoginEvent {
  const CheckSavedCredentials();
}

class ClearLoginError extends LoginEvent {
  const ClearLoginError();
}
