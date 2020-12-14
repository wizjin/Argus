//
//  AGCodeView.h
//  Argus
//
//  Created by WizJin on 2020/12/8.
//

#import <UIKit/UIKit.h>
#import "AGMFAModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AGCodeView : UILabel

@property (nonatomic, assign) CGFloat fontSize;

- (void)reset;
- (uint64_t)update:(AGMFAModel *)model now:(time_t)now;


@end

NS_ASSUME_NONNULL_END
