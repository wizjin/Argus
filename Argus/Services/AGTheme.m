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
        _tintColor = [UIColor colorNamed:@"AccentColor"];
        _labelColor = UIColor.labelColor;
        _minorLabelColor = UIColor.secondaryLabelColor;
        _infoColor = UIColor.systemGreenColor;
        _warnColor = UIColor.systemYellowColor;
        _alertColor = UIColor.systemRedColor;
        _secureColor = UIColor.systemGreenColor;
        _backgroundColor = UIColor.systemBackgroundColor;
        _cellBackgroundColor = [UIColor colorNamed:@"CellColor"];
        _groupedBackgroundColor = UIColor.systemGroupedBackgroundColor;
        _backImage = [UIImage systemImageNamed:@"chevron.backward"];
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
        
        self.userInterfaceStyle = [NSUserDefaults.standardUserDefaults integerForKey:@"userInterfaceStyle"];
    }
    return self;
}

- (UIUserInterfaceStyle)userInterfaceStyle {
    return AGRouter.shared.window.overrideUserInterfaceStyle;
}

- (void)setUserInterfaceStyle:(UIUserInterfaceStyle)userInterfaceStyle {
    if (userInterfaceStyle != self.userInterfaceStyle) {
        AGRouter.shared.window.overrideUserInterfaceStyle = userInterfaceStyle;
        [NSUserDefaults.standardUserDefaults setInteger:userInterfaceStyle forKey:@"userInterfaceStyle"];
    }
}


@end
