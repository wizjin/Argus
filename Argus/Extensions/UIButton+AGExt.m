//
//  UIButton+AGExt.m
//  Argus
//
//  Created by WizJin on 2020/12/30.
//

#import "UIButton+AGExt.h"

@interface AGImageButton : UIButton

- (instancetype)initImage:(UIImage *)image target:(nullable id)target action:(nullable SEL)action;

@end

@implementation AGImageButton

- (instancetype)initImage:(UIImage *)image target:(nullable id)target action:(nullable SEL)action {
    if (self = [super init]) {
        [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [self setImage:image forState:UIControlStateNormal];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect rc = self.bounds;
    rc.origin.x = floor(contentRect.size.width * 0.22);
    rc.origin.y = floor(contentRect.size.height * 0.22);
    rc.size.width -= rc.origin.x * 2;
    rc.size.height -= rc.origin.y * 2;
    return rc;
}

@end

@implementation UIButton (AGExt)

+ (instancetype)buttonWithImage:(UIImage *)image target:(nullable id)target action:(nullable SEL)action {
    if (@available(iOS 13.0, *)) {
        return [UIButton systemButtonWithImage:image target:target action:action];
    } else {
        return [[AGImageButton alloc] initImage:image target:target action:action];
    }
}


@end
