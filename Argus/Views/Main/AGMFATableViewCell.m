//
//  AGMFATableViewCell.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGMFATableViewCell.h"
#import "AGCountdownView.h"
#import "AGMFAManager.h"
#import "AGTheme.h"

@interface AGMFATableViewCell () {
@private
    uint64_t    lastT;
}

@property (nonatomic, readonly, strong) UIView *mainView;
@property (nonatomic, readonly, strong) UILabel *titleLabel;
@property (nonatomic, readonly, strong) UILabel *detailLabel;
@property (nonatomic, readonly, strong) UILabel *createdLabel;
@property (nonatomic, readonly, strong) UILabel *codeLabel;
@property (nonatomic, readonly, strong) AGCountdownView * countdown;
@property (nonatomic, nullable, strong) AGMFAModel *model;

@end

@implementation AGMFATableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        AGTheme *theme = AGTheme.shared;
        self.backgroundColor = UIColor.clearColor;
        
        UIView *mainView = [UIView new];
        [self.contentView addSubview:(_mainView = mainView)];
        mainView.backgroundColor = theme.cellBackgroundColor;
        [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).offset(-kAGMFACellMargin);
        }];

        UILabel *titleLabel = [UILabel new];
        [mainView addSubview:(_titleLabel = titleLabel)];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(mainView).offset(10);
            make.left.equalTo(mainView).offset(12);
        }];
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        titleLabel.textColor = theme.labelColor;
        
        UILabel *detailLabel = [UILabel new];
        [mainView addSubview:(_detailLabel = detailLabel)];
        [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(mainView).offset(-10);
            make.left.equalTo(titleLabel);
        }];
        detailLabel.font = [UIFont systemFontOfSize:12];
        detailLabel.textColor = theme.labelColor;

        UILabel *createdLabel = [UILabel new];
        [mainView addSubview:(_createdLabel = createdLabel)];
        [createdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel);
            make.right.equalTo(mainView).offset(-12);
        }];
        createdLabel.font = [UIFont systemFontOfSize:10];
        createdLabel.textColor = theme.minorLabelColor;

        AGCountdownView * countdown = [AGCountdownView new];
        [mainView addSubview:(_countdown = countdown)];
        [countdown mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.right.equalTo(createdLabel);
            make.bottom.equalTo(detailLabel);
        }];
        countdown.tintColor = theme.minorLabelColor;
    
        UILabel *codeLabel = [UILabel new];
        [mainView addSubview:(_codeLabel = codeLabel)];
        [codeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(mainView);
            make.left.equalTo(titleLabel);
        }];
        codeLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:50];
        codeLabel.textColor = theme.tintColor;

        lastT = 0;
        _model = nil;
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

+ (UIContextualAction *)actionDelete:(UITableView *)tableView {
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:nil handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {
        NSIndexPath *indexPath = [sourceView.superview valueForKeyPath:@"_delegate._indexPath"];
        AGMFAModel *model = [[tableView cellForRowAtIndexPath:indexPath] model];
        if (model != nil) {
            [AGMFAManager.shared deleteItem:model completion:^{
                AGMFAModel *project = [[tableView cellForRowAtIndexPath:indexPath] model];
                if ([project.created isEqual:model.created]) {
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }];
        }
        completionHandler(YES);
    }];
    action.image = [UIImage systemImageNamed:@"trash.fill"];
    return action;
}

- (void)setModel:(AGMFAModel *)model {
    if (self.model != model) {
        _model = model;
        lastT = 0;
        self.titleLabel.text = model.title;
        self.detailLabel.text = model.detail;
        NSString *created = @"";
        if (model.created != nil) {
            NSDateFormatter *dateFormat = [NSDateFormatter new];
            [dateFormat setDateFormat:@"YYYY/MM/dd HH:mm"];
            created = [NSString stringWithFormat:@"Created at %@".localized, [dateFormat stringFromDate:model.created]];
        }
        self.createdLabel.text = created;
        [self update:time(NULL)];
    }
}

- (void)update:(time_t)now {
    AGTheme *theme = AGTheme.shared;

    uint64_t r = 0;
    uint64_t t = [self.model calcT:now remainder:&r];
    if (lastT != t) {
        lastT = t;
        self.codeLabel.text = format([self.model calcCode:t]);
    }
    CGFloat rate = 0;
    CGFloat period = self.model.period;
    BOOL warn = NO;
    if (period > 0) {
        rate = (double)r/period;
        warn = (r <= 5);
    }
    self.countdown.rate = rate;
    self.codeLabel.textColor = (warn ? theme.alertColor : theme.tintColor);
}

static inline NSString *format(NSString *code) {
    NSMutableString *res = [[NSMutableString alloc] initWithCapacity:code.length + code.length/3];
    for (int i = 0; i < code.length; i++) {
        if (i%3 == 0 && i != 0) {
            [res appendString:@" "];
        }
        unichar c = [code characterAtIndex:i];
        [res appendFormat:@"%C", c];
    }
    return res;
}


@end

