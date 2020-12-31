//
//  UIBarButtonItem+AGExt.m
//  Argus
//
//  Created by WizJin on 2020/12/30.
//

#import "UIBarButtonItem+AGExt.h"

@implementation UIBarButtonItem (AGExt)

+ (instancetype)itemWithTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action {
    return [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
}

+ (instancetype)itemWithImage:(nullable UIImage *)image target:(nullable id)target action:(nullable SEL)action {
    return [[UIBarButtonItem alloc] initWithImage:image.barItemImage style:UIBarButtonItemStylePlain target:target action:action];
}


@end
