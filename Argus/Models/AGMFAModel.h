//
//  AGMFAModel.h
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGMFAModel : NSObject

@property (nonatomic, readonly, strong) NSString *title;
@property (nonatomic, readonly, strong) NSString *detail;
@property (nonatomic, readonly, assign) NSInteger period;
@property (nonatomic, nullable, strong) NSDate *created;

+ (instancetype)modelWithURL:(NSURL *)url;
- (uint64_t)calcT:(time_t)now remainder:(uint64_t *)remainder;
- (NSString *)calcCode:(uint64_t)t;


@end

NS_ASSUME_NONNULL_END
