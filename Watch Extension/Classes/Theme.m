//
//  Theme.m
//  Watch Extension
//
//  Created by WizJin on 2020/12/13.
//

#import "Theme.h"

@implementation Theme

+ (UIColor *)tintColor {
    static UIColor *color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorNamed:@"AccentColor"];
    });
    return color;
}


@end
