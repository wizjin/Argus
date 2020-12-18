//
//  AGTableViewCell.h
//  Argus
//
//  Created by WizJin on 2020/12/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kAGTableCellMargin    8

@interface AGTableViewCell : UITableViewCell

@property (nonatomic, readonly, strong) UIView *mainView;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier;


@end

NS_ASSUME_NONNULL_END
