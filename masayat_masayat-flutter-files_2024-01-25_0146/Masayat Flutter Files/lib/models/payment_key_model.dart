class PaymentKeyModel {
  String? key;
  String? pass;
  String? paystack;
  String? razorkey;
  String? razorpass;
  String? paytmkey;
  String? paytmpass;
  String? imapikey;
  String? imauthtoken;
  String? imurl;
  String? paypalClientId;
  String? paypalSecretId;
  String? paypalMode;
  String? cashfreeAppID;
  String? cashfreeSecrectID;
  String? cashfreeApiEndUrl;
  String? payhereAppCode;
  String? payhereAppSecret;
  String? payhereMerchantId;
  String? payhereMode;
  String? ravePublicKey;
  String? raveSecretKey;
  String? raveCountry;
  String? raveSecretHash;
  String? ravePrefix;
  String? raveLogo;

  PaymentKeyModel(
      {this.key,
      this.pass,
      this.paystack,
      this.razorkey,
      this.razorpass,
      this.paytmkey,
      this.paytmpass,
      this.imapikey,
      this.imauthtoken,
      this.imurl,
      this.paypalClientId,
      this.paypalSecretId,
      this.paypalMode,
      this.cashfreeAppID,
      this.cashfreeSecrectID,
      this.cashfreeApiEndUrl,
      this.payhereAppCode,
      this.payhereAppSecret,
      this.payhereMerchantId,
      this.payhereMode,
      this.ravePublicKey,
      this.raveSecretKey,
      this.raveCountry,
      this.raveSecretHash,
      this.ravePrefix,
      this.raveLogo});

  PaymentKeyModel.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    pass = json['pass'];
    paystack = json['paystack'];
    razorkey = json['razorkey'];
    razorpass = json['razorpass'];
    paytmkey = json['paytmkey'];
    paytmpass = json['paytmpass'];
    imapikey = json['imapikey'];
    imauthtoken = json['imauthtoken'];
    imurl = json['imurl'];
    paypalClientId = json['paypalClientId'];
    paypalSecretId = json['paypalSecretId'];
    paypalMode = json['paypalMode'];
    cashfreeAppID = json['cashfreeAppID'];
    cashfreeSecrectID = json['cashfreeSecrectID'];
    cashfreeApiEndUrl = json['cashfreeApiEndUrl'];
    payhereAppCode = json['payhereAppCode'];
    payhereAppSecret = json['payhereAppSecret'];
    payhereMerchantId = json['payhereMerchantId'];
    payhereMode = json['payhereMode'];
    ravePublicKey = json['ravePublicKey'];
    raveSecretKey = json['raveSecretKey'];
    raveCountry = json['raveCountry'];
    raveSecretHash = json['raveSecretHash'];
    ravePrefix = json['ravePrefix'];
    raveLogo = json['raveLogo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['pass'] = this.pass;
    data['paystack'] = this.paystack;
    data['razorkey'] = this.razorkey;
    data['razorpass'] = this.razorpass;
    data['paytmkey'] = this.paytmkey;
    data['paytmpass'] = this.paytmpass;
    data['imapikey'] = this.imapikey;
    data['imauthtoken'] = this.imauthtoken;
    data['imurl'] = this.imurl;
    data['paypalClientId'] = this.paypalClientId;
    data['paypalSecretId'] = this.paypalSecretId;
    data['paypalMode'] = this.paypalMode;
    data['cashfreeAppID'] = this.cashfreeAppID;
    data['cashfreeSecrectID'] = this.cashfreeSecrectID;
    data['cashfreeApiEndUrl'] = this.cashfreeApiEndUrl;
    data['payhereAppCode'] = this.payhereAppCode;
    data['payhereAppSecret'] = this.payhereAppSecret;
    data['payhereMerchantId'] = this.payhereMerchantId;
    data['payhereMode'] = this.payhereMode;
    data['ravePublicKey'] = this.ravePublicKey;
    data['raveSecretKey'] = this.raveSecretKey;
    data['raveCountry'] = this.raveCountry;
    data['raveSecretHash'] = this.raveSecretHash;
    data['ravePrefix'] = this.ravePrefix;
    data['raveLogo'] = this.raveLogo;
    return data;
  }
}
