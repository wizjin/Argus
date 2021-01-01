//
//  UIView+AGExt.h
//  Argus
//
//  Created by WizJin on 2020/12/1.
//

#import <UIKit/UIView.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (AGExt)

- (UIView *)findWithClassName:(NSString *)name;
- (nullable UIImage *)snapshotImage;


@end

NS_ASSUME_NONNULL_END
