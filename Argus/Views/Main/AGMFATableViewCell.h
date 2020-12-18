//
//  AGMFATableViewCell.h
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import <UIKit/UIKit.h>
#import "AGTableViewCell.h"
#import "AGMFAModel.h"

NS_ASSUME_NONNULL_BEGIN

#define kAGMFACellHeight    120

@interface AGMFATableViewCell : AGTableViewCell

@property (nonatomic, nullable, strong) AGMFAModel *model;

+ (UIContextualAction *)actionEdit:(UITableView *)tableView;
+ (UIContextualAction *)actionDelete:(UITableView *)tableView;
- (void)setModel:(AGMFAModel *)model;
- (void)update:(time_t)now;


@end

NS_ASSUME_NONNULL_END
