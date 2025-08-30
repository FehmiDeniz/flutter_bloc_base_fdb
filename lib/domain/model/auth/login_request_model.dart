// To parse this JSON data, do
//
//     final loginRequestModel = loginRequestModelFromJson(jsonString);

import 'package:flutter_bloc_base_template/domain/model/base_model.dart';

class LoginRequestModel extends BaseModel<LoginRequestModel> {
  String? username;
  String? password;
  String? deviceUnique;

  LoginRequestModel({
    this.username,
    this.password,
    this.deviceUnique,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) => LoginRequestModel(
        username: json["username"],
        password: json["password"],
        deviceUnique: json["device_unique"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "username": username,
        "password": password,
        "device_unique": deviceUnique,
      };

  @override
  LoginRequestModel fromJson(Map<String, dynamic> json) => LoginRequestModel.fromJson(json);

  @override
  LoginRequestModel copyWith({
    String? username,
    String? password,
    String? deviceUnique,
  }) {
    return LoginRequestModel(
      username: username ?? this.username,
      password: password ?? this.password,
      deviceUnique: deviceUnique ?? this.deviceUnique,
    );
  }
}
