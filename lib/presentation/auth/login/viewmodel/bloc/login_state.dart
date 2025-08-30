part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState {
  final LoginStatus status;
  final LoginResponseModel? loginResponse;
  final NetworkError? failure;
  final bool isPasswordVisible;
  final bool rememberMe;

  const LoginState({
    this.status = LoginStatus.initial,
    this.loginResponse,
    this.failure,
    this.isPasswordVisible = false,
    this.rememberMe = false,
  });

  LoginState copyWith({
    LoginStatus? status,
    LoginResponseModel? loginResponse,
    NetworkError? failure,
    bool? isPasswordVisible,
    bool? rememberMe,
  }) {
    return LoginState(
      status: status ?? this.status,
      loginResponse: loginResponse ?? this.loginResponse,
      failure: failure ?? this.failure,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}
