//
//  UIBarButtonItem+AGExt.h
//  Argus
//
//  Created by WizJin on 2020/12/30.
//

#import <UIKit/UIBarButtonItem.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBarButtonItem (AGExt)

+ (instancetype)itemWithTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action;
+ (instancetype)itemWithImage:(nullable UIImage *)image target:(nullable id)target action:(nullable SEL)action;


@end

NS_ASSUME_NONNULL_END
