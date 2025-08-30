import 'package:flutter_bloc_base_template/domain/model/base_model.dart';

class LoginResponseModel extends BaseModel<LoginResponseModel> {
  Value? value;
  String? message;
  int? responseCode;

  LoginResponseModel({
    this.value,
    this.message,
    this.responseCode,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
        value: json["Value"] == null ? null : Value.fromJson(json["Value"]),
        message: json["Message"],
        responseCode: json["ResponseCode"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "Value": value?.toJson(),
        "Message": message,
        "ResponseCode": responseCode,
      };

  @override
  LoginResponseModel fromJson(Map<String, dynamic> json) => LoginResponseModel.fromJson(json);

  @override
  LoginResponseModel copyWith({
    Value? value,
    String? message,
    int? responseCode,
  }) {
    return LoginResponseModel(
      value: value ?? this.value,
      message: message ?? this.message,
      responseCode: responseCode ?? this.responseCode,
    );
  }
}

class Value {
  DateTime? validTo;
  String? value;
  String? refreshToken;

  Value({
    this.validTo,
    this.value,
    this.refreshToken,
  });

  factory Value.fromJson(Map<String, dynamic> json) => Value(
        validTo: json["ValidTo"] == null ? null : DateTime.parse(json["ValidTo"]),
        value: json["Value"],
        refreshToken: json["RefreshToken"],
      );

  Map<String, dynamic> toJson() => {
        "ValidTo": validTo?.toIso8601String(),
        "Value": value,
        "RefreshToken": refreshToken,
      };
}
