//
//  UIButton+AGExt.h
//  Argus
//
//  Created by WizJin on 2020/12/30.
//

#import <UIKit/UIButton.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (AGExt)

+ (instancetype)buttonWithImage:(UIImage *)image target:(nullable id)target action:(nullable SEL)action;


@end

NS_ASSUME_NONNULL_END
