//
//  AppDelegate.m
//  Argus
//
//  Created by WizJin on 2020/11/29.
//

#import "AppDelegate.h"
#import "AGMFAManager.h"
#import "AGRouter.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return [AGRouter.shared launchWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return [AGRouter.shared handleURL:url];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        [AGRouter.shared handleURL:userActivity.webpageURL];
    }
    return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler {
    BOOL res = [AGRouter.shared handleShortcut:shortcutItem.type];
    if (completionHandler != NULL) {
        completionHandler(res);
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [AGMFAManager.shared active];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [AGMFAManager.shared deactive];
}


@end
