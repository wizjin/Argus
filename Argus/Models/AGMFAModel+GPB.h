//
//  AGMFAModel+GPB.h
//  Argus
//
//  Created by WizJin on 2020/12/18.
//

#import "AGMFAModel.h"

NS_ASSUME_NONNULL_BEGIN

@class AGMOtpParameters;

@interface AGMFAModel (GPB)

+ (nullable NSString *)URLWithParams:(AGMOtpParameters *)params API_UNAVAILABLE(watchos);
- (BOOL)calcCanExportPB API_UNAVAILABLE(watchos);
- (AGMOtpParameters *)pbParams API_UNAVAILABLE(watchos);


@end

NS_ASSUME_NONNULL_END
