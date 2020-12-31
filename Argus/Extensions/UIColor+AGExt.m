//
//  UIColor+AGExt.m
//  Argus
//
//  Created by WizJin on 2020/12/30.
//

#import "UIColor+AGExt.h"

@implementation UIColor (AGExt)

+ (instancetype)colorWithRGBA:(uint32_t)rgba {
    return [UIColor colorWithRed:((rgba >> 24)&0x00ff)/255.0 green:((rgba >> 16)&0x00ff)/255.0 blue:((rgba >> 8)&0x00ff)/255.0 alpha:(rgba&0x00ff)/255.0];
}


@end
