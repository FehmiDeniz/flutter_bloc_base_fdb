import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/services/network_error.dart';
import '../../../../../data/di/injection.dart';
import '../../../../../domain/model/auth/login_request_model.dart';
import '../../../../../domain/model/auth/login_response_model.dart';
import '../../../../../domain/usecase/auth/auth_usecase.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthUseCase _authUseCase;
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _prefs = getIt<SharedPreferences>();

  static const _keyUsername = 'saved_username';
  static const _keyPassword = 'saved_password';
  static const _keyRememberMe = 'remember_me';

  LoginBloc({
    required AuthUseCase authUseCase,
  })  : _authUseCase = authUseCase,
        super(const LoginState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<ClearLoginError>(_onClearLoginError);
    on<ToggleRememberMe>(_onToggleRememberMe);
    on<CheckSavedCredentials>(_onCheckSavedCredentials);

    add(const CheckSavedCredentials());
  }

  Future<void> _onCheckSavedCredentials(
    CheckSavedCredentials event,
    Emitter<LoginState> emit,
  ) async {
    final rememberMe = _prefs.getBool(_keyRememberMe) ?? false;

    if (rememberMe) {
      final savedUsername = _prefs.getString(_keyUsername);
      final savedPassword = _prefs.getString(_keyPassword);

      if (savedUsername != null && savedPassword != null) {
        usernameController.text = savedUsername;
        passwordController.text = savedPassword;
      }
    }

    emit(state.copyWith(rememberMe: rememberMe));
  }

  void _onToggleRememberMe(
    ToggleRememberMe event,
    Emitter<LoginState> emit,
  ) {
    final newValue = !state.rememberMe;
    _prefs.setBool(_keyRememberMe, newValue);
    emit(state.copyWith(rememberMe: newValue));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));

    debugPrint('Login Attempt:');
    debugPrint('Username: ${event.username}');
    debugPrint('Password: ${event.password}');
    debugPrint('Device ID: ${event.deviceUnique}');
    debugPrint('Remember Me: ${state.rememberMe}');

    final request = LoginRequestModel(
      username: event.username,
      password: event.password,
      deviceUnique: event.deviceUnique,
    );

    final response = await _authUseCase.login(request);

    response.fold(
      (loginResponse) {
        if (state.rememberMe) {
          _prefs.setString(_keyUsername, event.username);
          _prefs.setString(_keyPassword, event.password);
        } else {
          _prefs.remove(_keyUsername);
          _prefs.remove(_keyPassword);
        }

        debugPrint('Login Success: ${loginResponse?.message}');

        emit(state.copyWith(
          status: LoginStatus.success,
          loginResponse: loginResponse,
        ));
      },
      (failure) {
        debugPrint('Giriş Başarısız: ${failure.message}');
        emit(state.copyWith(
          status: LoginStatus.failure,
          failure: failure,
        ));
      },
    );
  }

  void _onTogglePasswordVisibility(
    TogglePasswordVisibility event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      isPasswordVisible: !state.isPasswordVisible,
    ));
  }

  void _onClearLoginError(
    ClearLoginError event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      status: LoginStatus.initial,
      failure: null,
    ));
  }

  @override
  Future<void> close() {
    usernameController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
