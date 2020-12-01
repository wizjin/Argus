//
//  AGRouter.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGRouter.h"
#import <JLRoutes/JLRoutes.h>
#import <Toast/Toast.h>
#import "AGMainViewController.h"
#import "AGWebViewController.h"
#import "AGMFAManager.h"
#import "AGTheme.h"

@interface AGRouter ()

@property (nonatomic, readonly, strong) JLRoutes *routes;

@end

@implementation AGRouter

+ (instancetype)shared {
    static AGRouter *router;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [AGRouter new];
    });
    return router;
}

- (instancetype)init {
    if (self = [super init]) {
        _routes = [JLRoutes routesForScheme:@".argus.router"];
        [self initRouters:self.routes];
    }
    return self;
}

- (UIWindow *)window {
    return UIApplication.sharedApplication.delegate.window;
}

- (void)setWindow:(UIWindow *)window {
    UIApplication.sharedApplication.delegate.window = window;
}

- (BOOL)launchWithOptions:(NSDictionary *)options {
    UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window = window;
    window.backgroundColor = AGTheme.shared.backgroundColor;
    [self routeTo:@"/page/main"];
    [window makeKeyAndVisible];
    return YES;
}

- (BOOL)handleURL:(NSURL *)url {
    return [self.routes routeURL:url withParameters:nil];
}

- (BOOL)handleShortcut:(NSString *)url {
    BOOL res = NO;
    if (url.length > 0) {
        if ([url isEqualToString:@"ScanAction"]) {
            res = [self routeTo:@"/page/scan?show=present"];
        }
    }
    return res;
}

- (BOOL)routeTo:(NSString *)url {
    return [self routeTo:url withParams:nil];
}

- (BOOL)routeTo:(NSString *)url withParams:(nullable NSDictionary<NSString *, id> *)params {
    return [self.routes routeURL:[NSURL URLWithString:url] withParameters:params];
}

#pragma mark - Private Methods
- (void)initRouters:(JLRoutes *)routes {
    [routes addRoute:@"/page/main" handler:^BOOL(NSDictionary<NSString *, id> *parameters) {
        if (self.window.rootViewController == nil) {
            self.window.rootViewController = [[AGMainViewController new] navigation];
        } else {
            [(UINavigationController *)self.window.rootViewController popToRootViewControllerAnimated:YES];
        }
        return YES;
    }];
    [routes addRoute:@"/page/:name" handler:^BOOL(NSDictionary<NSString *, id> *parameters) {
        BOOL res = NO;
        NSString *name = [parameters valueForKey:@"name"];
        if (name.length > 0) {
            Class clz = NSClassFromString([NSString stringWithFormat:@"AG%@ViewController", name.code]);
            if ([clz isSubclassOfClass:UIViewController.class]) {
                if (res == NO) {
                    UIViewController *vc = [clz alloc];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                    if ([vc respondsToSelector:@selector(initWithParameters:)]) {
                        vc = [vc performSelector:@selector(initWithParameters:) withObject:parameters];
                    } else {
                        vc = [vc init];
                    }
#pragma clang diagnostic pop
                    res = showViewController(vc, YES, ![[parameters valueForKey:@"show"] isEqualToString:@"present"]);
                }
            }
        }
        return res;
    }];
    routes.unmatchedURLHandler = ^(JLRoutes *routes, NSURL *url, NSDictionary<NSString *, id> *parameters) {
        NSString *scheme = url.scheme;
        if ([scheme isEqualToString:@"otpauth"]) {
            if ([AGMFAManager.shared openURL:url]) {
                return;
            }
        } else if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
            if (showViewController([[AGWebViewController alloc] initWithURL:url withParams:parameters], YES, YES)) {
                return;
            }
        }
        [self.window makeToast:@"Can't open url".localized];
    };
}

static inline BOOL showViewController(UIViewController *vc, BOOL animated, BOOL tryPush) {
    UINavigationController *nav = (UINavigationController *)AGRouter.shared.window.rootViewController;
    if (nav.presentationController != nil) {
        [nav dismissViewControllerAnimated:NO completion:nil];
    }
    if (!tryPush) {
        [nav popToRootViewControllerAnimated:NO];
    }
    nav.navigationBar.topItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeMinimal;
    [nav pushViewController:vc animated:animated];
    return YES;
}


@end
