//
//  AGMFAEmptyView.m
//  Argus
//
//  Created by WizJin on 2020/12/1.
//

#import "AGMFAEmptyView.h"
#import "AGTheme.h"

@interface AGMFAEmptyView ()

@property (nonatomic, readonly, strong) UITapGestureRecognizer *recognizer;

@end

@implementation AGMFAEmptyView

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    if (self = [super init]) {
        AGTheme *theme = AGTheme.shared;
        self.backgroundColor = theme.groupedBackgroundColor;
        self.alwaysBounceVertical = YES;
        self.alwaysBounceHorizontal = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 13.0, *)) {
            self.automaticallyAdjustsScrollIndicatorInsets = NO;
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithSymbol:@"rectangle.stack.badge.plus"]];
        [self addSubview:imageView];
        imageView.tintColor = theme.minorLabelColor;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 80));
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(UIScreen.mainScreen.bounds.size.height * 0.25);
        }];

        UILabel *titleLabel = [UILabel new];
        [self addSubview:titleLabel];
        titleLabel.numberOfLines = 0;
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.alignment = NSTextAlignmentCenter;
        style.lineSpacing = 16;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"NoMFA".localized];
        [text addAttributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:18],
            NSForegroundColorAttributeName: theme.minorLabelColor,
            NSParagraphStyleAttributeName:style,
        } range:NSMakeRange(0, text.length)];
        titleLabel.attributedText = text;
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(imageView);
            make.top.equalTo(imageView.mas_bottom).offset(40);
        }];
        
        _recognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:self.recognizer];
    }
    return self;
}

- (void)dealloc {
    [self removeGestureRecognizer:self.recognizer];
}


@end
