//
//  AGMFATableViewCell.h
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import <UIKit/UIKit.h>
#import "AGMFAModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AGMFATableViewCell : UITableViewCell

- (void)setModel:(AGMFAModel *)model;
- (void)update:(time_t)now;


@end

NS_ASSUME_NONNULL_END
