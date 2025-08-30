import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../core/services/network_error.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../model/auth/login_request_model.dart';
import '../../model/auth/login_response_model.dart';
import '../../model/auth/refresh_token_request_model.dart';
import '../../model/auth/refresh_token_response_model.dart';

class AuthUseCase {
  final AuthRepository _authRepository;

  AuthUseCase(this._authRepository);

  // Login işlemi
  Future<Either<LoginResponseModel?, NetworkError>> login(LoginRequestModel request) async {
    final response = await _authRepository.login(request);

    return response.fold(
      (loginResponse) async {
        if (loginResponse?.value != null) {
          await _authRepository.saveTokens(
            accessToken: loginResponse?.value?.value,
            refreshToken: loginResponse?.value?.refreshToken,
            validTo: loginResponse?.value?.validTo,
          );
        }
        return Left(loginResponse);
      },
      (error) => Right(error),
    );
  }

  // Refresh Token işlemi
  Future<Either<RefreshTokenResponseModel?, NetworkError>> refreshToken(
    RefreshTokenRequestModel request,
  ) async {
    final response = await _authRepository.refreshToken(request);

    return response.fold(
      (refreshResponse) async {
        if (refreshResponse?.value != null) {
          await _authRepository.saveTokens(
            accessToken: refreshResponse?.value?.value,
            refreshToken: refreshResponse?.value?.refreshToken,
            validTo: refreshResponse?.value?.validTo,
          );
        }
        return Left(refreshResponse);
      },
      (error) => Right(error),
    );
  }

  // Logout işlemi
  Future<void> logout() async {
    debugPrint('AuthUseCase: Çıkış işlemi başlatılıyor');

    try {
      // Önce API'ye logout isteği gönder (varsa)
      debugPrint('AuthUseCase: Çıkış isteği API’ye gönderiliyor.');
      await _authRepository.logout();
      debugPrint('AuthUseCase: API çıkış işlemi başarılı.');

      // Yerel depolamadaki verileri temizle
      debugPrint('AuthUseCase: Yerel depolama temizleniyor.');
      await _authRepository.clearTokens();
      debugPrint('AuthUseCase: Yerel depolama temizlendi.');
    } catch (e) {
      debugPrint('AuthUseCase: Çıkış işlemi sırasında bir hata oluştu.: $e');
      // Hata olsa bile local verileri temizlemeye çalış
      await _authRepository.clearTokens();
      rethrow;
    }
  }

  // Token kontrolü
  Future<bool> isLoggedIn() async {
    return await _authRepository.hasValidToken();
  }

  // Token al
  Future<String?> getToken() async {
    return await _authRepository.getToken();
  }
}
