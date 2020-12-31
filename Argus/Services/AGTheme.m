//
//  AGTheme.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGTheme.h"
#import "AGRouter.h"

@implementation AGTheme

+ (instancetype)shared {
    static AGTheme *theme;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        theme = [AGTheme new];
    });
    return theme;
}

- (instancetype)init {
    if (self = [super init]) {
        if (@available(iOS 13.0, *)) {
            _labelColor = UIColor.labelColor;
            _minorLabelColor = UIColor.secondaryLabelColor;
            _backgroundColor = UIColor.systemBackgroundColor;
            _groupedBackgroundColor = UIColor.systemGroupedBackgroundColor;
            _backImage = [UIImage imageWithSymbol:@"chevron.backward"];

            self.userInterfaceStyle = [NSUserDefaults.standardUserDefaults integerForKey:@"userInterfaceStyle"];
        } else {
            _labelColor = UIColor.blackColor;
            _minorLabelColor = [UIColor colorWithRGBA:0x3c3c4399];
            _backgroundColor = UIColor.whiteColor;
            _groupedBackgroundColor = [UIColor colorWithRGBA:0xf2f2f7ff];
            _backImage = [UIImage imageWithSymbol:@"chevron.backward"].barItemImage;
        }
        
        _tintColor = [UIColor colorNamed:@"AccentColor"];
        _infoColor = UIColor.systemGreenColor;
        _warnColor = UIColor.systemYellowColor;
        _alertColor = UIColor.systemRedColor;
        _secureColor = UIColor.systemGreenColor;
        _cellBackgroundColor = [UIColor colorNamed:@"CellColor"];
        _clearImage = [UIImage new];

        // Appearance
        UINavigationBar *navigationBar = UINavigationBar.appearance;
        navigationBar.shadowImage = self.clearImage;
        navigationBar.tintColor = self.labelColor;
        navigationBar.barTintColor = self.backgroundColor;
        navigationBar.backgroundColor = self.backgroundColor;
        navigationBar.backIndicatorImage = self.backImage;
        navigationBar.backIndicatorTransitionMaskImage = self.backImage;

        UISwitch.appearance.onTintColor = self.tintColor;
        UIProgressView.appearance.tintColor = self.tintColor;
    }
    return self;
}

- (UIUserInterfaceStyle)userInterfaceStyle API_AVAILABLE(ios(13.0)) {
    return AGRouter.shared.window.overrideUserInterfaceStyle;
}

- (void)setUserInterfaceStyle:(UIUserInterfaceStyle)userInterfaceStyle API_AVAILABLE(ios(13.0)) {
    if (userInterfaceStyle != self.userInterfaceStyle) {
        AGRouter.shared.window.overrideUserInterfaceStyle = userInterfaceStyle;
        [NSUserDefaults.standardUserDefaults setInteger:userInterfaceStyle forKey:@"userInterfaceStyle"];
    }
}


@end
