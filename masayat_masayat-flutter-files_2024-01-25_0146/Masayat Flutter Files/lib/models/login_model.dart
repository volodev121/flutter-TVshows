class LoginModel {
  LoginModel({
    this.tokenType,
    this.expiresIn,
    this.accessToken,
    this.refreshToken,
  });

  String? tokenType;
  dynamic  expiresIn;
  String? accessToken;
  String? refreshToken;

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    tokenType: json["token_type"],
    expiresIn: json["expires_in"],
    accessToken: json["access_token"],
    refreshToken: json["refresh_token"],
  );

  Map<String, dynamic> toJson() => {
    "token_type": tokenType,
    "expires_in": expiresIn,
    "access_token": accessToken,
    "refresh_token": refreshToken,
  };
}
