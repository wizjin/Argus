//
//  AGMFATableViewCell.h
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import <UIKit/UIKit.h>
#import "AGMFAModel.h"

NS_ASSUME_NONNULL_BEGIN

#define kAGMFACellHeight    120
#define kAGMFACellMargin    8

@interface AGMFATableViewCell : UITableViewCell

+ (UIContextualAction *)actionDelete:(UITableView *)tableView;
- (void)setModel:(AGMFAModel *)model;
- (void)update:(time_t)now;


@end

NS_ASSUME_NONNULL_END
