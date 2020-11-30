//
//  AGMFAManager.h
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import <Foundation/Foundation.h>
#import "AGMFAModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AGMFAManager : NSObject

+ (instancetype)shared;
- (NSArray<AGMFAModel *> *)items;


@end

NS_ASSUME_NONNULL_END
