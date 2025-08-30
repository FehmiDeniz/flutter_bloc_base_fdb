enum ServicePathEnum {
  login,
  refreshToken,
}

extension ServicePathEnumExtension on ServicePathEnum {
  String rawValue({String? id}) {
    switch (this) {
      case ServicePathEnum.login:
        return '/auth/login';
      case ServicePathEnum.refreshToken:
        return '/auth/refresh-token';
    }
  }
}
