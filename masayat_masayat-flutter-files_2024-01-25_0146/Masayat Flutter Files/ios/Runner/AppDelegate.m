#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "BraintreeCore.h"
#import "FlutterDownloaderPlugin.h"

#import <LoginWithAmazon/LoginWithAmazon.h>

@implementation AppDelegate

void registerPlugins(NSObject<FlutterPluginRegistry>* registry) {
  if (![registry hasPlugin:@"FlutterDownloaderPlugin"]) {
     [FlutterDownloaderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterDownloaderPlugin"]];
  }
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  [FlutterDownloaderPlugin setPluginRegistrantCallback:registerPlugins];
  [BTAppContextSwitcher setReturnURLScheme:@"com.Sammour.Masayat.payments"];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)
url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    return [AMZNAuthorizationManager handleOpenURL:url
                                 sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
}

@end
