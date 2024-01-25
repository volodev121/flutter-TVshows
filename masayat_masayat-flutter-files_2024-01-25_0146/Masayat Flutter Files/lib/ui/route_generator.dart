import 'package:flutter/material.dart';
import 'package:nexthour/localization/language_screen.dart';
import 'package:nexthour/ui/gateways/cashfree_payment.dart';
import 'package:nexthour/ui/gateways/manual_payment_list.dart';
import 'package:nexthour/ui/gateways/payhere_payment.dart';
import 'package:nexthour/ui/gateways/payumoney_payment.dart';
import 'package:nexthour/ui/gateways/rave_payment.dart';
import 'package:nexthour/ui/gateways/upi_payment.dart';
import 'package:nexthour/ui/screens/audioScreen.dart';
import 'package:nexthour/ui/screens/liveEventScreen.dart';
import 'package:nexthour/ui/shared/recommended_grid_view.dart';
import '/ui/gateways/in_app_payment.dart';
import '/ui/screens/actors_movies_grid.dart';
import '/ui/screens/apply_coupon_screen.dart';
import '/ui/screens/change_password_screen.dart';
import '/ui/screens/create_screen_profile.dart';
import '/ui/screens/forgot_password_screen.dart';
import '/ui/screens/live_video_grid.dart';
import '/ui/screens/manage_profile_screen.dart';
import '/ui/screens/notification_detail_screen.dart';
import '/ui/screens/update_profile_screen.dart';
import '/ui/screens/watch_history_screen.dart';
import '../ui/gateways/paypal/PaypalPayment.dart';
import '../ui/gateways/paystack_payment.dart';
import '../ui/screens/actor_screen.dart';
import '../ui/screens/multi_screen.dart';
import '../ui/screens/app_settings_screen.dart';
import '../ui/screens/blog_list_screen.dart';
import '../ui/screens/donation_screen.dart';
import '../ui/screens/video_detail_screen.dart';
import 'package:page_transition/page_transition.dart';
import '../ui/screens/notifications_screen.dart';
import '../common/route_paths.dart';
import '../ui/screens/bottom_navigations_bar.dart';
import 'gateways/bank_payment.dart';
import '../ui/screens/blog_screen.dart';
import '../ui/screens/faq_screen.dart';
import '../ui/screens/login_home.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/membership_screen.dart';
import '../ui/screens/other_history_screen.dart';
import '../ui/screens/pay_history_screen.dart';
import 'gateways/braintree_payment.dart';
import 'gateways/instamojo.dart';
import 'gateways/manual_payment_screen.dart';
import 'gateways/paytm_payment.dart';
import 'gateways/razor_payment.dart';
import '../ui/screens/register_screen.dart';
import '../ui/screens/select_payment_screen.dart';
import '../ui/screens/stripe_history_screen.dart';
import 'gateways/stripe_payment.dart';
import '../ui/screens/subscription_plan_screen.dart';
import '../ui/screens/intro_screen.dart';
import 'screens/Downloaded_videos.dart';
import 'screens/home_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/search_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/video_grid_screen.dart';
import 'screens/wishlist_screen.dart';
import 'shared/actors_grid.dart';
import 'shared/top_grid_view.dart';
import 'widgets/grid_movie_tv.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case RoutePaths.splashScreen:
        SplashScreen? argument = args as SplashScreen?;
        return MaterialPageRoute(
            builder: (context) => SplashScreen(
                  token: argument!.token,
                ));
      case RoutePaths.introSlider:
        return PageTransition(
            child: IntroScreen(), type: PageTransitionType.rightToLeft);
      case RoutePaths.loginHome:
        return PageTransition(
            child: LoginHome(), type: PageTransitionType.rightToLeft);

      case RoutePaths.login:
        return MaterialPageRoute(builder: (context) => LoginScreen());

      case RoutePaths.register:
        return MaterialPageRoute(builder: (context) => RegisterScreen());
      case RoutePaths.bottomNavigationHome:
        return MaterialPageRoute(builder: (_) => MyBottomNavigationBar());
      case RoutePaths.membership:
        return MaterialPageRoute(builder: (context) => MembershipScreen());
      case RoutePaths.faq:
        return PageTransition(
            child: FAQScreen(), type: PageTransitionType.rightToLeft);
      case RoutePaths.createScreen:
        return PageTransition(
            child: CreateMultiProfile(), type: PageTransitionType.rightToLeft);
      case RoutePaths.multiScreen:
        return PageTransition(
            child: MultiScreen(), type: PageTransitionType.rightToLeft);
      case RoutePaths.actorScreen:
        ActorScreen? argument = args as ActorScreen?;
        return MaterialPageRoute(
            builder: (context) => ActorScreen(argument!.actor));
      case RoutePaths.blog:
        BlogScreen? argument = args as BlogScreen?;
        return MaterialPageRoute(
            builder: (context) => BlogScreen(argument!.index));
      case RoutePaths.blogList:
        return PageTransition(
            child: BlogListScreen(), type: PageTransitionType.rightToLeft);
      case RoutePaths.donation:
        return PageTransition(
            child: DonationScreen(), type: PageTransitionType.rightToLeft);
      case RoutePaths.notifications:
        return PageTransition(
            child: NotificationsScreen(), type: PageTransitionType.rightToLeft);
      case RoutePaths.notificationDetail:
        NotificationDetailScreen argument = args as NotificationDetailScreen;
        return PageTransition(
            child: NotificationDetailScreen(argument.title, argument.message),
            type: PageTransitionType.rightToLeft);
      case RoutePaths.instaMojo:
        InstamojoPaymentPage? argument = args as InstamojoPaymentPage?;
        return MaterialPageRoute(
            builder: (context) =>
                InstamojoPaymentPage(argument!.planIndex, argument.payAmount));
      case RoutePaths.subscriptionPlans:
        return PageTransition(
            child: SubPlanScreen(), type: PageTransitionType.rightToLeft);
      case RoutePaths.applyCoupon:
        ApplyCouponScreen argument = args as ApplyCouponScreen;
        return PageTransition(
            child: ApplyCouponScreen(argument.amount, argument.func),
            type: PageTransitionType.rightToLeft);
      case RoutePaths.selectPayment:
        SelectPaymentScreen? argument = args as SelectPaymentScreen?;
        return MaterialPageRoute(
            builder: (context) => SelectPaymentScreen(argument!.planIndex));
      case RoutePaths.paymentHistory:
        return MaterialPageRoute(builder: (context) => PaymentHistoryScreen());
      case RoutePaths.stripeHistory:
        return MaterialPageRoute(builder: (context) => StripeHistoryScreen());
      case RoutePaths.otherHistory:
        return MaterialPageRoute(builder: (context) => OtherHistoryScreen());
      case RoutePaths.manageProfile:
        return MaterialPageRoute(builder: (context) => ManageProfileScreen());
      case RoutePaths.changePassword:
        return MaterialPageRoute(builder: (context) => ChangePasswordScreen());
      case RoutePaths.updateProfile:
        return MaterialPageRoute(builder: (context) => UpdateProfileScreen());
      case RoutePaths.bankPayment:
        return MaterialPageRoute(builder: (context) => BankPayment());
      case RoutePaths.razorpay:
        RazorPayment? argument = args as RazorPayment?;
        return MaterialPageRoute(
            builder: (context) =>
                RazorPayment(argument!.index, argument.payAmount));

      case RoutePaths.stripe:
        StripePayment? argument = args as StripePayment?;
        return MaterialPageRoute(
            builder: (context) =>
                StripePayment(argument!.index, argument.couponCode));
      case RoutePaths.braintree:
        BraintreePaymentScreen? argument = args as BraintreePaymentScreen?;
        return MaterialPageRoute(
            builder: (context) => BraintreePaymentScreen(
                argument!.planIndex, argument.payAmount));
      case RoutePaths.payu:
        PayuPayment? argument = args as PayuPayment;
        return MaterialPageRoute(
          builder: (context) => PayuPayment(
            planIndex: argument.planIndex,
            payAmount: argument.payAmount,
          ),
        );
      case RoutePaths.paypal:
        PaypalPayment? argument = args as PaypalPayment?;
        return MaterialPageRoute(
            builder: (context) => PaypalPayment(
                  onFinish: argument!.onFinish,
                  currency: argument.currency,
                  userFirstName: argument.userFirstName,
                  userLastName: argument.userLastName,
                  userEmail: argument.userEmail,
                  payAmount: argument.payAmount,
                  planIndex: argument.planIndex,
                ));
      case RoutePaths.paytm:
        PaytmPayment? argument = args as PaytmPayment?;
        return MaterialPageRoute(
            builder: (context) =>
                PaytmPayment(argument!.index, argument.payAmount));
      case RoutePaths.paystack:
        PaystackPayment? argument = args as PaystackPayment?;
        return MaterialPageRoute(
            builder: (context) =>
                PaystackPayment(argument!.index, argument.payAmount));
      case RoutePaths.inApp:
        InApp? argument = args as InApp?;
        return MaterialPageRoute(builder: (context) => InApp(argument!.index));
      case RoutePaths.forgotPassword:
        ForgotPassword? argument = args as ForgotPassword?;
        return MaterialPageRoute(
            builder: (context) => ForgotPassword(argument!.email));
      case RoutePaths.topVideos:
        TopGridView argument = args as TopGridView;
        return MaterialPageRoute(
            builder: (context) => TopGridView(argument.topVideosList));
      case RoutePaths.liveGrid:
        return MaterialPageRoute(builder: (context) => LiveVideoGrid());
      case RoutePaths.actorMoviesGrid:
        ActorMoviesGrid? argument = args as ActorMoviesGrid?;
        return MaterialPageRoute(
            builder: (context) => ActorMoviesGrid(argument!.actorDetails));
      case RoutePaths.genreVideos:
        VideoGridScreen? argument = args as VideoGridScreen?;
        return MaterialPageRoute(
            builder: (context) => VideoGridScreen(
                argument!.id, argument.title, argument.genreDataList));
      case RoutePaths.gridVideos:
        GridMovieTV? argument = args as GridMovieTV?;
        return MaterialPageRoute(
            builder: (context) => GridMovieTV(argument!.type));
      case RoutePaths.actorsGrid:
        return MaterialPageRoute(builder: (context) => ActorsGrid());
      case RoutePaths.watchHistory:
        return PageTransition(
            child: WatchHistoryScreen(), type: PageTransitionType.rightToLeft);
      case RoutePaths.videoDetail:
        VideoDetailScreen? argument = args as VideoDetailScreen?;
        return MaterialPageRoute(
            builder: (context) => VideoDetailScreen(argument!.videoDetail));
      case RoutePaths.appSettings:
        return PageTransition(
            child: AppSettingsScreen(), type: PageTransitionType.rightToLeft);
      case RoutePaths.mainHome:
        return MaterialPageRoute(builder: (context) => HomeScreen());
      case RoutePaths.search:
        return MaterialPageRoute(builder: (context) => SearchScreen());
      case RoutePaths.wishlist:
        return MaterialPageRoute(builder: (context) => WishListScreen());
      case RoutePaths.download:
        return MaterialPageRoute(builder: (context) => DownloadedVideos());
      case RoutePaths.menu:
        return MaterialPageRoute(builder: (context) => MenuScreen());
      case RoutePaths.ManualPaymentList:
        ManualPaymentList? argument = args as ManualPaymentList?;
        return MaterialPageRoute(
          builder: (context) => ManualPaymentList(
            manualPaymentModel: argument!.manualPaymentModel,
            planIndex: argument.planIndex,
            payAmount: argument.payAmount,
          ),
        );
      case RoutePaths.ManualPayment:
        ManualPaymentScreen? argument = args as ManualPaymentScreen?;
        return MaterialPageRoute(
          builder: (context) => ManualPaymentScreen(
            manualPayment: argument!.manualPayment,
            planIndex: argument.planIndex,
            payAmount: argument.payAmount,
          ),
        );
      case RoutePaths.CashfreePayment:
        CashfreePayment? argument = args as CashfreePayment;
        return MaterialPageRoute(
          builder: (context) => CashfreePayment(
            planIndex: argument.planIndex,
            payAmount: argument.payAmount,
          ),
        );
      case RoutePaths.RavePayment:
        RavePayment? argument = args as RavePayment;
        return MaterialPageRoute(
          builder: (context) => RavePayment(
            planIndex: argument.planIndex,
            payAmount: argument.payAmount,
          ),
        );
      case RoutePaths.PayherePayment:
        PayHerePayment? argument = args as PayHerePayment;
        return MaterialPageRoute(
          builder: (context) => PayHerePayment(
            planIndex: argument.planIndex,
            payAmount: argument.payAmount,
          ),
        );
      case RoutePaths.ChooseLanguage:
        return MaterialPageRoute(
          builder: (context) => LanguageScreen(),
        );
      case RoutePaths.Audio:
        AudioScreen argument = args as AudioScreen;
        return MaterialPageRoute(
          builder: (context) => AudioScreen(
            audio: argument.audio,
          ),
        );
      case RoutePaths.Event:
        LiveEventScreen argument = args as LiveEventScreen;
        return MaterialPageRoute(
          builder: (context) => LiveEventScreen(
            liveEvent: argument.liveEvent,
          ),
        );
      case RoutePaths.UpiPayment:
        UPIPayment argument = args as UPIPayment;
        return MaterialPageRoute(
          builder: (context) => UPIPayment(
            planIndex: argument.planIndex,
            payAmount: argument.payAmount,
          ),
        );
      case RoutePaths.recommendedVideos:
        RecommendedGridView argument = args as RecommendedGridView;
        return MaterialPageRoute(
            builder: (context) => RecommendedGridView(argument.videoList));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
