import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../common/enums/local_storage_enum.dart';

class SecureStorageLocale {
  late FlutterSecureStorage storage;
  static final SecureStorageLocale _instance = SecureStorageLocale._init();

  static SecureStorageLocale get instance => _instance;

  SecureStorageLocale._init() {
    storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  }

  // String okuma
  Future<String?> readString(LocalStorageEnum localStorageEnum) async {
    String? value = await storage.read(key: localStorageEnum.rawValue());
    return value;
  }

  // String yazma
  Future<void> writeString({
    required LocalStorageEnum localStorageEnum,
    required String? value,
  }) async {
    await storage.write(
      key: localStorageEnum.rawValue(),
      value: value,
    );
  }

  // Tüm verileri silme
  Future<void> deleteAll() async {
    await storage.deleteAll();
  }

  // Belirli bir anahtarı silme
  Future<void> delete(LocalStorageEnum localStorageEnum) async {
    await storage.delete(key: localStorageEnum.rawValue());
  }

  // Tüm anahtarları getirme
  Future<List<String>> getAllKeys() async {
    Map<String, String> allValues = await storage.readAll();
    return allValues.keys.toList();
  }

  // Tüm değerleri getirme
  Future<Map<String, String>> getAllValues() async {
    return await storage.readAll();
  }

  // Belirli bir anahtarın var olup olmadığını kontrol etme
  Future<bool> containsKey(LocalStorageEnum localStorageEnum) async {
    return await storage.containsKey(key: localStorageEnum.rawValue());
  }
}
