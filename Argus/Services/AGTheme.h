//
//  AGTheme.h
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGTheme : NSObject

@property (nonatomic, readonly, strong) UIColor *tintColor;
@property (nonatomic, readonly, strong) UIColor *labelColor;
@property (nonatomic, readonly, strong) UIColor *minorLabelColor;
@property (nonatomic, readonly, strong) UIColor *warnColor;
@property (nonatomic, readonly, strong) UIColor *alertColor;
@property (nonatomic, readonly, strong) UIColor *secureColor;
@property (nonatomic, readonly, strong) UIColor *backgroundColor;
@property (nonatomic, readonly, strong) UIColor *groupedBackgroundColor;
@property (nonatomic, readonly, strong) UIImage *backImage;
@property (nonatomic, readonly, strong) UIImage *clearImage;
@property (nonatomic, assign) UIUserInterfaceStyle userInterfaceStyle;

+ (instancetype)shared;


@end

NS_ASSUME_NONNULL_END
