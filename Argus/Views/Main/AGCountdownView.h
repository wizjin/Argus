//
//  AGCountdownView.h
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import <UIKit/UIKit.h>
#import "AGMFAModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AGCountdownView : UIView

@property (nonatomic, strong) UIColor *tintColor;

- (void)update:(AGMFAModel *)model remainder:(uint64_t)r;


@end

NS_ASSUME_NONNULL_END
