//
//  AGRouter.h
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGRouter : NSObject

@property (nonatomic, readonly, strong) UIWindow *window;

+ (instancetype)shared;
- (BOOL)launchWithOptions:(NSDictionary *)options;
- (BOOL)handleURL:(NSURL *)url;
- (BOOL)handleShortcut:(NSString *)url;
- (BOOL)routeTo:(NSString *)url;
- (BOOL)routeTo:(NSString *)url withParams:(nullable NSDictionary<NSString *, id> *)params;


@end

NS_ASSUME_NONNULL_END
