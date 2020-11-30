//
//  AGDevice.h
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGDevice : NSObject

@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, readonly, strong) NSString *version;
@property (nonatomic, readonly, assign) uint32_t build;

+ (instancetype)shared;


@end

NS_ASSUME_NONNULL_END
