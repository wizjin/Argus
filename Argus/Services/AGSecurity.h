//
//  AGSecurity.h
//  Argus
//
//  Created by WizJin on 2020/12/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGSecurity : NSObject

@property (nonatomic, assign) BOOL hasLocker;

+ (instancetype)shared;
- (BOOL)checkLocker;
- (BOOL)isLocking;


@end

NS_ASSUME_NONNULL_END
