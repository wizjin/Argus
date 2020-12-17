//
//  AGRouter.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGRouter.h"
#import <JLRoutes/JLRoutes.h>
#import "AGMainViewController.h"
#import "AGBlurViewController.h"
#import "AGWebViewController.h"
#import "AGMFAManager.h"
#import "AGSecurity.h"
#import "AGTheme.h"

@interface AGRouter ()

@property (nonatomic, readonly, strong) JLRoutes *routes;
@property (nonatomic, nullable, strong) UIWindow *maskScreen;

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
        _maskScreen = nil;
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

- (void)active {
    if (!AGSecurity.shared.isLocking) {
        [self hideMaskView];
    } else {
        [self showMaskView];
        if (AGSecurity.shared.checkLocker) {
            [self hideMaskView];
        }
    }
    [AGMFAManager.shared active];
}

- (void)deactive {
    if (AGSecurity.shared.hasLocker) {
        [self showMaskView];
    }
    UIViewController *vc = self.window.rootViewController;
    if(vc.presentationController != nil) {
        [vc dismissViewControllerAnimated:YES completion:nil];
    }
    [AGMFAManager.shared deactive];
}

- (BOOL)launchWithOptions:(NSDictionary *)options {
    UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window = window;
    window.backgroundColor = AGTheme.shared.backgroundColor;
    [self routeTo:@"/page/main"];
    if (!AGSecurity.shared.isLocking) {
        [self.window makeKeyAndVisible];
    }
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

- (void)showViewController:(UIViewController *)vc animated:(BOOL)animated {
    showViewController(vc, animated, YES);
}

- (void)presentViewController:(UIViewController *)vc animated:(BOOL)animated {
    [self.window.rootViewController presentViewController:vc animated:animated completion:nil];
}

- (void)makeToast:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        showToast(message);
    });
}

#pragma mark - Private Methods
- (void)showMaskView {
    if (self.maskScreen == nil) {
        self.maskScreen = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        self.maskScreen.windowLevel = UIWindowLevelStatusBar;
        self.maskScreen.rootViewController = [AGBlurViewController new];
    }
    [self.window setHidden:YES];
    [self.maskScreen makeKeyAndVisible];
}

- (void)hideMaskView {
    if (self.maskScreen != nil) {
        [self.maskScreen setHidden:YES];
        [self.window makeKeyAndVisible];
        self.maskScreen = nil;
    }
}

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
    [routes addRoute:@"/action/openurl" handler:^BOOL(NSDictionary<NSString *,id> *parameters) {
        BOOL res = NO;
        NSString *url = [parameters valueForKey:@"url"];
        if (url.length > 0) {
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
            res = YES;
        }
        return res;
    }];
    routes.unmatchedURLHandler = ^(JLRoutes *routes, NSURL *url, NSDictionary<NSString *, id> *parameters) {
        BOOL res = NO;
        if ([AGMFAManager.shared canOpenURL:url]) {
            res = [AGMFAManager.shared openURL:url];
        } else {
            NSString *scheme = url.scheme;
            if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
                res = showViewController([[AGWebViewController alloc] initWithURL:url withParams:parameters], YES, YES);
            }
        }
        if (!res) {
            [self makeToast:@"Can't open url".localized];
        }
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

static inline void showToast(NSString *message) {
    NSTimeInterval delay = 0;

    static UILabel *lastToast = nil;
    if (lastToast != nil) {
        delay += 0.2;
        closeToast(lastToast, 0);
        lastToast = nil;
    }

    CGFloat radius = 14.0;
    UIView *view = AGRouter.shared.window;
    UILabel *toast = [UILabel new];
    [view addSubview:(lastToast = toast)];
    toast.text = message;
    toast.alpha = 0;
    toast.numberOfLines = 1;
    toast.textAlignment = NSTextAlignmentCenter;
    toast.font = [UIFont systemFontOfSize:14];
    toast.textColor = UIColor.whiteColor;
    toast.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
    toast.layer.cornerRadius = radius;
    toast.clipsToBounds = YES;
    [toast mas_makeConstraints:^(MASConstraintMaker *make) {
        CGSize size = [toast sizeThatFits:CGSizeMake(UIScreen.mainScreen.bounds.size.width * 0.8, radius * 2)];
        size.height = radius * 2;
        size.width += floor(radius * 2);
        size.width = fmax(size.width, radius * 4);
        make.size.mas_equalTo(size);
        make.centerX.equalTo(view);
        make.bottom.equalTo(view.mas_safeAreaLayoutGuideBottom).offset(-60);
    }];
    openToast(toast, delay);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        closeToast(toast, delay);
    });
}

static inline void openToast(UILabel *toast, NSTimeInterval delay) {
    [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.2 delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        toast.alpha = 1;
    } completion:nil];
}

static inline void closeToast(UILabel *toast, NSTimeInterval delay) {
    [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.2 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
        toast.alpha = 0;
    } completion:^(UIViewAnimatingPosition finalPosition) {
        [toast removeFromSuperview];
    }];
}


@end
