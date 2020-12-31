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

+ (UIContextualAction *)actionEdit:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
+ (UIContextualAction *)actionDelete:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (void)setModel:(AGMFAModel *)model;
- (void)update:(time_t)now;


@end

NS_ASSUME_NONNULL_END
