//
//  UIImage+AGExt.m
//  Argus
//
//  Created by WizJin on 2020/12/30.
//

#import "UIImage+AGExt.h"

@implementation UIImage (AGExt)

+ (instancetype)imageWithSymbol:(NSString *)name {
    if (@available(iOS 13.0, *)) {
        return [UIImage systemImageNamed:name];
    } else {
        return [UIImage imageNamed:name];
    }
}

+ (instancetype)imageWithSymbol:(NSString *)name height:(CGFloat)height {
    if (@available(iOS 13.0, *)) {
        return [UIImage systemImageNamed:name];
    } else {
        return [[UIImage imageNamed:name] resizeWithHeight:height];
    }
}

- (instancetype)resizeWithHeight:(CGFloat)height {
    UIImage *image = nil;
    if (self != nil) {
        CGSize size = self.size;
        size.width = size.width*height / size.height;
        size.height = height;
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

- (instancetype)barItemImage {
    if (@available(iOS 13.0, *)) {
        return self;
    } else {
        return [self resizeWithHeight:22.0];
    }
}


@end
