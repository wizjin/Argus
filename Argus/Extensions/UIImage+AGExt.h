//
//  UIImage+AGExt.h
//  Argus
//
//  Created by WizJin on 2020/12/30.
//

#import <UIKit/UIImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (AGExt)

+ (instancetype)imageWithSymbol:(NSString *)name;
+ (instancetype)imageWithSymbol:(NSString *)name height:(CGFloat)height;
- (instancetype)resizeWithHeight:(CGFloat)height;
- (instancetype)barItemImage;


@end

NS_ASSUME_NONNULL_END
