import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nexthour/localization/language_provider.dart';
import 'package:nexthour/providers/all_user_provider.dart';
import 'package:nexthour/providers/app_ui_shorting_provider.dart';
import 'package:nexthour/providers/audio_provider.dart';
import 'package:nexthour/providers/count_view_provider.dart';
import 'package:nexthour/providers/live_event_provider.dart';
import 'package:nexthour/providers/manual_payment_provider.dart';
import 'package:nexthour/providers/upi_details_provider.dart';
import 'common/theme_work.dart';
import 'providers/actor_movies_provider.dart';
import 'providers/app_config.dart';
import 'common/route_paths.dart';
import 'package:provider/provider.dart';
import 'common/styles.dart';
import 'providers/faq_provider.dart';
import 'providers/login_provider.dart';
import 'providers/main_data_provider.dart';
import 'providers/menu_data_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/movie_tv_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/payment_key_provider.dart';
import 'providers/slider_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/coupon_provider.dart';
import 'ui/route_generator.dart';
import 'ui/screens/splash_screen.dart';
import 'providers/watch_history_provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class MyApp extends StatefulWidget {
  MyApp({this.token});
  final String? token;
  @override
  _MyAppState createState() => _MyAppState();
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    var localizationDelegate = LocalizedApp.of(context).delegate;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppConfig()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => SliderProvider()),
        ChangeNotifierProvider(create: (_) => MainProvider()),
        ChangeNotifierProvider(create: (_) => MovieTVProvider()),
        ChangeNotifierProvider(create: (_) => MenuDataProvider()),
        ChangeNotifierProvider(create: (_) => WishListProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => FAQProvider()),
        ChangeNotifierProvider(create: (_) => PaymentKeyProvider()),
        ChangeNotifierProvider(create: (_) => WatchHistoryProvider()),
        ChangeNotifierProvider(create: (_) => ActorMoviesProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider()),
        ChangeNotifierProvider(create: (_) => ManualPaymentProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AppUIShortingProvider()),
        ChangeNotifierProvider(create: (_) => AllUsersProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => LiveEventProvider()),
        ChangeNotifierProvider(create: (_) => CountViewProvider()),
        ChangeNotifierProvider(create: (_) => UpiDetailsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
        },
        child: LocalizationProvider(
          state: LocalizationProvider.of(context).state,
          child: Consumer<ThemeProvider>(
              builder: (context, ThemeProvider themeNotifier, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: RoutePaths.appTitle,
              theme:
                  themeNotifier.isDark ? buildDarkTheme() : buildLightTheme(),
              initialRoute: RoutePaths.splashScreen,
              onGenerateRoute: RouteGenerator.generateRoute,
              navigatorObservers: [
                FirebaseAnalyticsObserver(analytics: analytics),
              ],
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                localizationDelegate
              ],
              supportedLocales: localizationDelegate.supportedLocales,
              locale: localizationDelegate.currentLocale,
              routes: {
                RoutePaths.splashScreen: (context) =>
                    SplashScreen(token: widget.token),
              },
            );
          }),
        ),
      ),
    );
  }
}
