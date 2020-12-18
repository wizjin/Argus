//
//  AGTableViewCell.m
//  Argus
//
//  Created by WizJin on 2020/12/18.
//

#import "AGTableViewCell.h"
#import "AGTheme.h"

@implementation AGTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = UIColor.clearColor;
        UIView *mainView = [UIView new];
        [self.contentView addSubview:(_mainView = mainView)];
        mainView.backgroundColor = AGTheme.shared.cellBackgroundColor;
        [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).offset(-kAGTableCellMargin);
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [self setHighlighted:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    CGFloat alpha = (highlighted ? 0.7 : 1);
    if (self.mainView.alpha != alpha) {
        if (!animated) {
            self.mainView.alpha = alpha;
        } else {
            [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.2 delay:0 options:0 animations:^{
                self.mainView.alpha = alpha;
            } completion:nil];
        }
    }
}


@end
