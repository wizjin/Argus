//
//  AGMFATableViewCell.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGMFATableViewCell.h"
#import "AGEditorViewController.h"
#import "AGCountdownView.h"
#import "AGCreatedLabel.h"
#import "AGCodeView.h"
#import "AGMFAManager.h"
#import "AGRouter.h"
#import "AGTheme.h"

@interface AGMFATableViewCell ()

@property (nonatomic, readonly, strong) UIView *mainView;
@property (nonatomic, readonly, strong) UILabel *titleLabel;
@property (nonatomic, readonly, strong) UILabel *detailLabel;
@property (nonatomic, readonly, strong) AGCreatedLabel *createdLabel;
@property (nonatomic, readonly, strong) AGCodeView *codeLabel;
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

        AGCreatedLabel *createdLabel = [AGCreatedLabel new];
        [mainView addSubview:(_createdLabel = createdLabel)];
        [createdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel);
            make.right.equalTo(mainView).offset(-12);
        }];

        AGCountdownView * countdown = [AGCountdownView new];
        [mainView addSubview:(_countdown = countdown)];
        [countdown mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.right.equalTo(createdLabel);
            make.bottom.equalTo(detailLabel);
        }];
    
        AGCodeView *codeLabel = [AGCodeView new];
        [mainView addSubview:(_codeLabel = codeLabel)];
        [codeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(mainView);
            make.left.equalTo(titleLabel);
        }];
        codeLabel.fontSize = 50;

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

+ (UIContextualAction *)actionEdit:(UITableView *)tableView {
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {
        NSIndexPath *indexPath = [sourceView.superview valueForKeyPath:@"_delegate._indexPath"];
        AGMFAModel *model = [[tableView cellForRowAtIndexPath:indexPath] model];
        if (model != nil) {
            [AGRouter.shared showViewController:[[AGEditorViewController alloc] initWithModel:model] animated:YES];
        }
        completionHandler(YES);
    }];
    action.backgroundColor = AGTheme.shared.infoColor;
    action.image = [UIImage systemImageNamed:@"qrcode"];
    return action;
}

+ (UIContextualAction *)actionDelete:(UITableView *)tableView {
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:nil handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {
        NSIndexPath *indexPath = [sourceView.superview valueForKeyPath:@"_delegate._indexPath"];
        AGMFAModel *model = [[tableView cellForRowAtIndexPath:indexPath] model];
        if (model != nil) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete this record will NOT turn off OTP verification".localized message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel".localized style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
            UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete".localized style:UIAlertActionStyleDestructive
               handler:^(UIAlertAction * action) {
                [AGMFAManager.shared deleteItem:model completion:^{
                    AGMFAModel *project = [[tableView cellForRowAtIndexPath:indexPath] model];
                    if (project.created == model.created) {
                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                }];
            }];
            [alert addAction:cancelAction];
            [alert addAction:deleteAction];
            [AGRouter.shared presentViewController:alert animated:YES];
        }
        completionHandler(YES);
    }];
    action.image = [UIImage systemImageNamed:@"trash.fill"];
    return action;
}

- (void)setModel:(AGMFAModel *)model {
    if (self.model != model) {
        _model = model;
        [self.codeLabel reset];
        self.titleLabel.text = model.title;
        self.detailLabel.text = model.detail;
        self.createdLabel.created = model.created;
        [self update:time(NULL)];
    }
}

- (void)update:(time_t)now {
    [self.countdown update:self.model remainder:[self.codeLabel update:self.model now:now]];
}


@end

