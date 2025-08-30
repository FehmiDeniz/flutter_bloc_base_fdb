import 'package:flutter_bloc_base_template/domain/model/base_model.dart';

class RefreshTokenResponseModel extends BaseModel<RefreshTokenResponseModel> {
  Value? value;
  String? message;
  int? responseCode;

  RefreshTokenResponseModel({
    this.value,
    this.message,
    this.responseCode,
  });

  factory RefreshTokenResponseModel.fromJson(Map<String, dynamic> json) =>
      RefreshTokenResponseModel(
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
  RefreshTokenResponseModel fromJson(Map<String, dynamic> json) =>
      RefreshTokenResponseModel.fromJson(json);

  @override
  RefreshTokenResponseModel copyWith({
    Value? value,
    String? message,
    int? responseCode,
  }) {
    return RefreshTokenResponseModel(
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
