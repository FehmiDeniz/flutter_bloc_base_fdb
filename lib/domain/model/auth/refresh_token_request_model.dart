import 'package:try_again_app/domain/model/base_model.dart';

class RefreshTokenRequestModel extends BaseModel<RefreshTokenRequestModel> {
  String? accessToken;
  String? refreshToken;

  RefreshTokenRequestModel({
    this.accessToken,
    this.refreshToken,
  });

  factory RefreshTokenRequestModel.fromJson(Map<String, dynamic> json) => RefreshTokenRequestModel(
        accessToken: json["access_token"],
        refreshToken: json["refresh_token"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "refresh_token": refreshToken,
      };

  @override
  RefreshTokenRequestModel fromJson(Map<String, dynamic> json) =>
      RefreshTokenRequestModel.fromJson(json);

  @override
  RefreshTokenRequestModel copyWith({
    String? accessToken,
    String? refreshToken,
  }) {
    return RefreshTokenRequestModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
