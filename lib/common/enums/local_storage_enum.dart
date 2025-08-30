enum LocalStorageEnum {
  token,
  refreshToken,
  rememberMe,
  tokenValidTo,
}

extension LocalStorageEnumExtension on LocalStorageEnum {
  String rawValue() {
    switch (this) {
      case LocalStorageEnum.token:
        return 'token';
      case LocalStorageEnum.refreshToken:
        return 'refreshToken';
      case LocalStorageEnum.rememberMe:
        return 'rememberMe';
      case LocalStorageEnum.tokenValidTo:
        return 'tokenValidTo';
    }
  }
}
