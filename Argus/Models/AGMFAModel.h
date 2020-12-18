//
//  AGMFAModel.h
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGMFAModel : NSObject

@property (nonatomic, readonly, strong) NSDictionary *data;
@property (nonatomic, readonly, strong) NSString *title;
@property (nonatomic, readonly, strong) NSString *detail;
@property (nonatomic, readonly, strong) NSData *secret;
@property (nonatomic, readonly, assign) NSInteger period;
@property (nonatomic, readonly, assign) uint64_t digits;
@property (nonatomic, readonly, assign) CCHmacAlgorithm algorithm;
@property (nonatomic, readonly, assign) uint64_t created;

+ (instancetype)modelWithData:(NSDictionary *)data;
- (BOOL)isEqual:(AGMFAModel *)other;
- (uint64_t)calcT:(time_t)now remainder:(uint64_t *)remainder;
- (NSString *)calcCode:(uint64_t)t;
- (NSString *)url;
- (BOOL)canExportPB API_UNAVAILABLE(watchos);


@end

NS_ASSUME_NONNULL_END
