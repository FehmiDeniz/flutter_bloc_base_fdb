import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:try_again_app/common/enums/service_path_enums.dart';
import '../../common/enums/local_storage_enum.dart';
import '../../core/services/network_error.dart';
import '../../core/services/network_manager.dart';
import '../../core/storage/secure_storage.dart';
import '../../domain/model/auth/login_request_model.dart';
import '../../domain/model/auth/login_response_model.dart';
import '../../domain/model/auth/refresh_token_request_model.dart';
import '../../domain/model/auth/refresh_token_response_model.dart';

class AuthRepository {
  final NetworkManager _networkManager;
  final SecureStorageLocale _secureStorage;

  AuthRepository({
    required NetworkManager networkManager,
    required SecureStorageLocale secureStorage,
  })  : _networkManager = networkManager,
        _secureStorage = secureStorage;

  // Login işlemi
  Future<Either<LoginResponseModel?, NetworkError>> login(LoginRequestModel request) async {
    try {
      final response = await _networkManager.post<Map<String, dynamic>>(
        ServicePathEnum.login.rawValue(),
        data: request.toJson(),
      );
      final model = LoginResponseModel.fromJson(response.data ?? {});
      return Left(model);
    } on NetworkError catch (e) {
      return Right(e);
    } catch (e) {
      return Right(NetworkError.unknown(e.toString()));
    }
  }

  // Refresh Token işlemi
  Future<Either<RefreshTokenResponseModel?, NetworkError>> refreshToken(
    RefreshTokenRequestModel request,
  ) async {
    try {
      final response = await _networkManager.post<Map<String, dynamic>>(
        ServicePathEnum.refreshToken.rawValue(),
        data: request.toJson(),
      );
      final model = RefreshTokenResponseModel.fromJson(response.data ?? {});
      return Left(model);
    } on NetworkError catch (e) {
      return Right(e);
    } catch (e) {
      return Right(NetworkError.unknown(e.toString()));
    }
  }

  // Token'ları kaydet
  Future<void> saveTokens({
    String? accessToken,
    String? refreshToken,
    DateTime? validTo,
  }) async {
    debugPrint('\nTokenlar kaydediliyor:');
    debugPrint('Erişim Tokenı: $accessToken');
    debugPrint('Yenileme Tokenı: $refreshToken');
    debugPrint('Geçerlilik Süresi: $validTo\n');

    try {
      if (accessToken != null) {
        await _secureStorage.writeString(
          localStorageEnum: LocalStorageEnum.token,
          value: accessToken,
        );
        debugPrint('Erişim Tokenı başarıyla kaydedildi');
      }

      if (refreshToken != null) {
        await _secureStorage.writeString(
          localStorageEnum: LocalStorageEnum.refreshToken,
          value: refreshToken,
        );
        debugPrint('Yenileme Tokenı başarıyla kaydedildi');
      }

      if (validTo != null) {
        await _secureStorage.writeString(
          localStorageEnum: LocalStorageEnum.tokenValidTo,
          value: validTo.toIso8601String(),
        );
        debugPrint('Token geçerlilik tarihi başarıyla kaydedildi');
      }
    } catch (e) {
      debugPrint('Tokenları kaydederken bir hata oluştu: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    debugPrint('AuthRepository: Çıkış işlemi başlatılıyor.');

    try {
      // API'ye logout isteği gönder (varsa)
      debugPrint('AuthRepository: API’ye çıkış isteği gönderiliyor.');
      // await _repositoryManager.post('/auth/logout');
      debugPrint('AuthRepository: API çıkış işlemi başarıyla tamamlandı.');
    } catch (e) {
      debugPrint('AuthRepository: API çıkış işlemi sırasında bir hata oluştu: $e');
      // API hatası olsa bile devam et
    }
  }

  // Token'ları temizle
  Future<void> clearTokens() async {
    debugPrint('AuthRepository: Saklanan tokenlar temizleniyor.');

    try {
      await _secureStorage.delete(LocalStorageEnum.token);
      await _secureStorage.delete(LocalStorageEnum.refreshToken);
      await _secureStorage.delete(LocalStorageEnum.tokenValidTo);
      debugPrint('AuthRepository: Tüm tokenlar başarıyla temizlendi.');
    } catch (e) {
      debugPrint('AuthRepository: Tokenları temizlerken bir hata oluştu: $e');
      rethrow;
    }
  }

  // Token al
  Future<String?> getToken() async {
    return await _secureStorage.readString(LocalStorageEnum.token);
  }

  // Refresh Token al
  Future<String?> getRefreshToken() async {
    return await _secureStorage.readString(LocalStorageEnum.refreshToken);
  }

  // Token geçerlilik süresini al
  Future<DateTime?> getTokenValidTo() async {
    final validToStr = await _secureStorage.readString(LocalStorageEnum.tokenValidTo);
    if (validToStr != null) {
      return DateTime.parse(validToStr);
    }
    return null;
  }

  // Token kontrolü
  Future<bool> hasValidToken() async {
    final token = await getToken();
    final validTo = await getTokenValidTo();

    if (token == null || validTo == null) {
      return false;
    }

    return validTo.isAfter(DateTime.now());
  }
}
