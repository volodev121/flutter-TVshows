class Config {
  int? id;
  String? logo;
  String? favicon;
  String? livetvicon;
  String? title;
  String? wEmail;
  dynamic verifyEmail;
  dynamic download;
  dynamic freeSub;
  dynamic freeDays;
  String? stripePubKey;
  String? stripeSecretKey;
  String? paypalMarEmail;
  String? currencyCode;
  String? currencySymbol;
  String? invoiceAdd;
  dynamic primeMainSlider;
  dynamic catlog;
  dynamic withlogin;
  dynamic primeGenreSlider;
  dynamic donation;
  String? donationLink;
  dynamic primeFooter;
  dynamic primeMovieSingle;
  String? termsCondition;
  String? privacyPol;
  String? refundPol;
  String? copyright;
  dynamic stripePayment;
  dynamic paypalPayment;
  dynamic razorpayPayment;
  dynamic ageRestriction;
  dynamic payuPayment;
  dynamic bankdetails;
  String? accountNo;
  String? branch;
  String? accountName;
  String? ifscCode;
  String? bankName;
  dynamic paytmPayment;
  dynamic paytmTest;
  dynamic preloader;
  dynamic fbLogin;
  dynamic gitlabLogin;
  dynamic googleLogin;
  dynamic welEml;
  dynamic blog;
  dynamic isPlaystore;
  dynamic isAppstore;
  String? playstore;
  String? appstore;
  dynamic userRating;
  dynamic comments;
  dynamic braintree;
  dynamic paystack;
  dynamic removeLandingPage;
  dynamic coinpay;
  dynamic captcha;
  dynamic amazonLogin;
  String? createdAt;
  String? updatedAt;
  dynamic molliePayment;
  dynamic cashfreePayment;
  dynamic aws;
  dynamic omisePayment;
  dynamic flutterravePayment;
  dynamic instamojoPayment;
  dynamic commentsApproval;
  dynamic payherePayment;
  String? preloaderImg;

  Config(
      {this.id,
      this.logo,
      this.favicon,
      this.livetvicon,
      this.title,
      this.wEmail,
      this.verifyEmail,
      this.download,
      this.freeSub,
      this.freeDays,
      this.stripePubKey,
      this.stripeSecretKey,
      this.paypalMarEmail,
      this.currencyCode,
      this.currencySymbol,
      this.invoiceAdd,
      this.primeMainSlider,
      this.catlog,
      this.withlogin,
      this.primeGenreSlider,
      this.donation,
      this.donationLink,
      this.primeFooter,
      this.primeMovieSingle,
      this.termsCondition,
      this.privacyPol,
      this.refundPol,
      this.copyright,
      this.stripePayment,
      this.paypalPayment,
      this.razorpayPayment,
      this.ageRestriction,
      this.payuPayment,
      this.bankdetails,
      this.accountNo,
      this.branch,
      this.accountName,
      this.ifscCode,
      this.bankName,
      this.paytmPayment,
      this.paytmTest,
      this.preloader,
      this.fbLogin,
      this.gitlabLogin,
      this.googleLogin,
      this.welEml,
      this.blog,
      this.isPlaystore,
      this.isAppstore,
      this.playstore,
      this.appstore,
      this.userRating,
      this.comments,
      this.braintree,
      this.paystack,
      this.removeLandingPage,
      this.coinpay,
      this.captcha,
      this.amazonLogin,
      this.createdAt,
      this.updatedAt,
      this.molliePayment,
      this.cashfreePayment,
      this.aws,
      this.omisePayment,
      this.flutterravePayment,
      this.instamojoPayment,
      this.commentsApproval,
      this.payherePayment,
      this.preloaderImg});

  Config.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    logo = json['logo'];
    favicon = json['favicon'];
    livetvicon = json['livetvicon'];
    title = json['title'];
    wEmail = json['w_email'];
    verifyEmail = json['verify_email'];
    download = json['download'];
    freeSub = json['free_sub'];
    freeDays = json['free_days'];
    stripePubKey = json['stripe_pub_key'];
    stripeSecretKey = json['stripe_secret_key'];
    paypalMarEmail = json['paypal_mar_email'];
    currencyCode = json['currency_code'];
    currencySymbol = json['currency_symbol'];
    invoiceAdd = json['invoice_add'];
    primeMainSlider = json['prime_main_slider'];
    catlog = json['catlog'];
    withlogin = json['withlogin'];
    primeGenreSlider = json['prime_genre_slider'];
    donation = json['donation'];
    donationLink = json['donation_link'];
    primeFooter = json['prime_footer'];
    primeMovieSingle = json['prime_movie_single'];
    termsCondition = json['terms_condition'];
    privacyPol = json['privacy_pol'];
    refundPol = json['refund_pol'];
    copyright = json['copyright'];
    stripePayment = json['stripe_payment'];
    paypalPayment = json['paypal_payment'];
    razorpayPayment = json['razorpay_payment'];
    ageRestriction = json['age_restriction'];
    payuPayment = json['payu_payment'];
    bankdetails = json['bankdetails'];
    accountNo = json['account_no'];
    branch = json['branch'];
    accountName = json['account_name'];
    ifscCode = json['ifsc_code'];
    bankName = json['bank_name'];
    paytmPayment = json['paytm_payment'];
    paytmTest = json['paytm_test'];
    preloader = json['preloader'];
    fbLogin = json['fb_login'];
    gitlabLogin = json['gitlab_login'];
    googleLogin = json['google_login'];
    welEml = json['wel_eml'];
    blog = json['blog'];
    isPlaystore = json['is_playstore'];
    isAppstore = json['is_appstore'];
    playstore = json['playstore'];
    appstore = json['appstore'];
    userRating = json['user_rating'];
    comments = json['comments'];
    braintree = json['braintree'];
    paystack = json['paystack'];
    removeLandingPage = json['remove_landing_page'];
    coinpay = json['coinpay'];
    captcha = json['captcha'];
    amazonLogin = json['amazon_login'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    molliePayment = json['mollie_payment'];
    cashfreePayment = json['cashfree_payment'];
    aws = json['aws'];
    omisePayment = json['omise_payment'];
    flutterravePayment = json['flutterrave_payment'];
    instamojoPayment = json['instamojo_payment'];
    commentsApproval = json['comments_approval'];
    payherePayment = json['payhere_payment'];
    preloaderImg = json['preloader_img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['logo'] = this.logo;
    data['favicon'] = this.favicon;
    data['livetvicon'] = this.livetvicon;
    data['title'] = this.title;
    data['w_email'] = this.wEmail;
    data['verify_email'] = this.verifyEmail;
    data['download'] = this.download;
    data['free_sub'] = this.freeSub;
    data['free_days'] = this.freeDays;
    data['stripe_pub_key'] = this.stripePubKey;
    data['stripe_secret_key'] = this.stripeSecretKey;
    data['paypal_mar_email'] = this.paypalMarEmail;
    data['currency_code'] = this.currencyCode;
    data['currency_symbol'] = this.currencySymbol;
    data['invoice_add'] = this.invoiceAdd;
    data['prime_main_slider'] = this.primeMainSlider;
    data['catlog'] = this.catlog;
    data['withlogin'] = this.withlogin;
    data['prime_genre_slider'] = this.primeGenreSlider;
    data['donation'] = this.donation;
    data['donation_link'] = this.donationLink;
    data['prime_footer'] = this.primeFooter;
    data['prime_movie_single'] = this.primeMovieSingle;
    data['terms_condition'] = this.termsCondition;
    data['privacy_pol'] = this.privacyPol;
    data['refund_pol'] = this.refundPol;
    data['copyright'] = this.copyright;
    data['stripe_payment'] = this.stripePayment;
    data['paypal_payment'] = this.paypalPayment;
    data['razorpay_payment'] = this.razorpayPayment;
    data['age_restriction'] = this.ageRestriction;
    data['payu_payment'] = this.payuPayment;
    data['bankdetails'] = this.bankdetails;
    data['account_no'] = this.accountNo;
    data['branch'] = this.branch;
    data['account_name'] = this.accountName;
    data['ifsc_code'] = this.ifscCode;
    data['bank_name'] = this.bankName;
    data['paytm_payment'] = this.paytmPayment;
    data['paytm_test'] = this.paytmTest;
    data['preloader'] = this.preloader;
    data['fb_login'] = this.fbLogin;
    data['gitlab_login'] = this.gitlabLogin;
    data['google_login'] = this.googleLogin;
    data['wel_eml'] = this.welEml;
    data['blog'] = this.blog;
    data['is_playstore'] = this.isPlaystore;
    data['is_appstore'] = this.isAppstore;
    data['playstore'] = this.playstore;
    data['appstore'] = this.appstore;
    data['user_rating'] = this.userRating;
    data['comments'] = this.comments;
    data['braintree'] = this.braintree;
    data['paystack'] = this.paystack;
    data['remove_landing_page'] = this.removeLandingPage;
    data['coinpay'] = this.coinpay;
    data['captcha'] = this.captcha;
    data['amazon_login'] = this.amazonLogin;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['mollie_payment'] = this.molliePayment;
    data['cashfree_payment'] = this.cashfreePayment;
    data['aws'] = this.aws;
    data['omise_payment'] = this.omisePayment;
    data['flutterrave_payment'] = this.flutterravePayment;
    data['instamojo_payment'] = this.instamojoPayment;
    data['comments_approval'] = this.commentsApproval;
    data['payhere_payment'] = this.payherePayment;
    data['preloader_img'] = this.preloaderImg;
    return data;
  }
}
