//
//  AGExportTableViewCell.m
//  Argus
//
//  Created by WizJin on 2020/12/18.
//

#import "AGExportTableViewCell.h"
#import "AGCreatedLabel.h"
#import "AGTheme.h"

@interface AGExportTableViewCell ()

@property (nonatomic, readonly, strong) UIImageView *checkImage;
@property (nonatomic, readonly, strong) UILabel *titleLabel;
@property (nonatomic, readonly, strong) UILabel *detailLabel;
@property (nonatomic, readonly, strong) AGCreatedLabel *createdLabel;

@end

@implementation AGExportTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        AGTheme *theme = AGTheme.shared;
        
        UIImageView *checkImage = [UIImageView new];
        [self.mainView addSubview:(_checkImage = checkImage)];
        [checkImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mainView);
            make.left.equalTo(self.mainView).offset(20);
            make.size.mas_equalTo(CGSizeMake(32, 32));
        }];
        
        UILabel *titleLabel = [UILabel new];
        [self.mainView addSubview:(_titleLabel = titleLabel)];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mainView).offset(16);
            make.left.equalTo(checkImage.mas_right).offset(16);
        }];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.textColor = theme.labelColor;
        
        UILabel *detailLabel = [UILabel new];
        [self.mainView addSubview:(_detailLabel = detailLabel)];
        [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mainView).offset(-16);
            make.left.equalTo(titleLabel);
        }];
        detailLabel.font = [UIFont systemFontOfSize:14];
        detailLabel.textColor = theme.labelColor;

        AGCreatedLabel *createdLabel = [AGCreatedLabel new];
        [self.mainView addSubview:(_createdLabel = createdLabel)];
        [createdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(titleLabel);
            make.right.equalTo(self.mainView).offset(-16);
        }];
        
        _model = nil;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (self.model.canExportPB) {
        [UIView animateWithDuration:(animated ? 0.2 : 0) animations:^{
            if (selected) {
                self.checkImage.tintColor = AGTheme.shared.tintColor;
                self.checkImage.image = [UIImage imageWithSymbol:@"checkmark.circle.fill"];
            } else {
                self.checkImage.tintColor = AGTheme.shared.minorLabelColor;
                self.checkImage.image = [UIImage imageWithSymbol:@"circle"];
            }
        }];
    }
}

- (void)setModel:(AGMFAModel *)model {
    if (_model != model) {
        _model = model;
        self.titleLabel.text = model.title;
        self.detailLabel.text = model.detail;
        self.createdLabel.created = model.created;
        if (!self.model.canExportPB) {
            self.checkImage.tintColor = AGTheme.shared.alertColor;
            self.checkImage.image = [UIImage imageWithSymbol:@"exclamationmark.circle.fill"];
        }
    }
}


@end
