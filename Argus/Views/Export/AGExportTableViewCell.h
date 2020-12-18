//
//  AGExportTableViewCell.h
//  Argus
//
//  Created by WizJin on 2020/12/18.
//

#import <UIKit/UIKit.h>
#import "AGTableViewCell.h"
#import "AGMFAModel.h"

NS_ASSUME_NONNULL_BEGIN

#define kAGExportCellHeight    80

@interface AGExportTableViewCell : AGTableViewCell

@property (nonatomic, nullable, strong) AGMFAModel *model;

- (void)setModel:(AGMFAModel *)model;


@end

NS_ASSUME_NONNULL_END
