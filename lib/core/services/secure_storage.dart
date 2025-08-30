import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static SecureStorage? _instance;
  static SecureStorage get instance {
    _instance ??= SecureStorage._init();
    return _instance!;
  }

  late final FlutterSecureStorage _storage;

  SecureStorage._init() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  }

  // Write string value
  Future<void> writeString({
    required String key,
    required String value,
  }) async {
    await _storage.write(key: key, value: value);
  }

  // Read string value
  Future<String?> readString({required String key}) async {
    return await _storage.read(key: key);
  }

  // Write bool value
  Future<void> writeBool({
    required String key,
    required bool value,
  }) async {
    await _storage.write(key: key, value: value.toString());
  }

  // Read bool value
  Future<bool?> readBool({required String key}) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  // Write int value
  Future<void> writeInt({
    required String key,
    required int value,
  }) async {
    await _storage.write(key: key, value: value.toString());
  }

  // Read int value
  Future<int?> readInt({required String key}) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  // Write double value
  Future<void> writeDouble({
    required String key,
    required double value,
  }) async {
    await _storage.write(key: key, value: value.toString());
  }

  // Read double value
  Future<double?> readDouble({required String key}) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return double.tryParse(value);
  }

  // Write map value (as JSON string)
  Future<void> writeMap({
    required String key,
    required Map<String, dynamic> value,
  }) async {
    final jsonString = _mapToJsonString(value);
    await _storage.write(key: key, value: jsonString);
  }

  // Read map value (from JSON string)
  Future<Map<String, dynamic>?> readMap({required String key}) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return _jsonStringToMap(value);
  }

  // Write list value (as JSON string)
  Future<void> writeList({
    required String key,
    required List<dynamic> value,
  }) async {
    final jsonString = _listToJsonString(value);
    await _storage.write(key: key, value: jsonString);
  }

  // Read list value (from JSON string)
  Future<List<dynamic>?> readList({required String key}) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return _jsonStringToList(value);
  }

  // Delete specific key
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  // Delete all keys
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // Check if key exists
  Future<bool> containsKey({required String key}) async {
    return await _storage.containsKey(key: key);
  }

  // Get all keys
  Future<List<String>> getAllKeys() async {
    return await _storage.readAll().then((map) => map.keys.toList());
  }

  // Get all values
  Future<Map<String, String>> getAllValues() async {
    return await _storage.readAll();
  }

  // Helper methods for JSON conversion
  String _mapToJsonString(Map<String, dynamic> map) {
    try {
      // Simple JSON conversion for basic types
      final entries = map.entries.map((entry) {
        final key = '"${entry.key}":';
        final value = _valueToJsonString(entry.value);
        return '$key$value';
      });
      return '{${entries.join(',')}}';
    } catch (e) {
      return '{}';
    }
  }

  Map<String, dynamic>? _jsonStringToMap(String jsonString) {
    try {
      // Simple JSON parsing for basic types
      // This is a basic implementation, consider using json_serializable for complex objects
      if (jsonString == '{}') return {};
      
      final map = <String, dynamic>{};
      final content = jsonString.substring(1, jsonString.length - 1);
      final pairs = content.split(',');
      
      for (final pair in pairs) {
        if (pair.trim().isEmpty) continue;
        final colonIndex = pair.indexOf(':');
        if (colonIndex == -1) continue;
        
        final key = pair.substring(0, colonIndex).trim().replaceAll('"', '');
        final valueString = pair.substring(colonIndex + 1).trim();
        final value = _jsonStringToValue(valueString);
        
        map[key] = value;
      }
      
      return map;
    } catch (e) {
      return null;
    }
  }

  String _listToJsonString(List<dynamic> list) {
    try {
      final values = list.map((item) => _valueToJsonString(item));
      return '[${values.join(',')}]';
    } catch (e) {
      return '[]';
    }
  }

  List<dynamic>? _jsonStringToList(String jsonString) {
    try {
      if (jsonString == '[]') return [];
      
      final content = jsonString.substring(1, jsonString.length - 1);
      if (content.trim().isEmpty) return [];
      
      final items = content.split(',');
      return items.map((item) => _jsonStringToValue(item.trim())).toList();
    } catch (e) {
      return null;
    }
  }

  String _valueToJsonString(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is num) return value.toString();
    if (value is bool) return value.toString();
    if (value is Map<String, dynamic>) return _mapToJsonString(value);
    if (value is List) return _listToJsonString(value);
    return '"$value"';
  }

  dynamic _jsonStringToValue(String valueString) {
    if (valueString == 'null') return null;
    if (valueString.startsWith('"') && valueString.endsWith('"')) {
      return valueString.substring(1, valueString.length - 1);
    }
    if (valueString == 'true') return true;
    if (valueString == 'false') return false;
    if (valueString.contains('.')) {
      return double.tryParse(valueString);
    }
    return int.tryParse(valueString) ?? valueString;
  }

  // Dispose
  void dispose() {
    // FlutterSecureStorage doesn't need explicit disposal
  }
}
