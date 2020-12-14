//
//  UIView+AGExt.m
//  Argus
//
//  Created by WizJin on 2020/12/1.
//

#import "UIView+AGExt.h"

@implementation UIView (AGExt)

- (UIView *)findWithClassName:(NSString *)name {
    if (name.length > 0) {
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass([subview class]) isEqualToString:name]) {
                return subview;
            }
        }
    }
    return nil;
}


@end
