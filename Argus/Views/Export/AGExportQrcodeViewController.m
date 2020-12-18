//
//  AGExportQrcodeViewController.m
//  Argus
//
//  Created by WizJin on 2020/12/18.
//

#import "AGExportQrcodeViewController.h"
#import "AGCreatedLabel.h"
#import "AGQRCodeView.h"
#import "AGRouter.h"
#import "AGTheme.h"

@interface AGExportQrcodeViewController ()

@property (nonatomic, readonly, strong) NSString *url;

@end

@implementation AGExportQrcodeViewController

- (instancetype)initWithParameters:(NSDictionary *)params {
    if (self = [super init]) {
        NSArray<NSString *> *urls = [params valueForKey:@"urls"];
        if (urls.count > 0) {
            _url = urls.firstObject;
        } else {
            _url = @"";
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AGTheme *theme = AGTheme.shared;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"square.and.arrow.up"] style:UIBarButtonItemStylePlain target:self action:@selector(actionExport:)];

    UIScrollView *view = [UIScrollView new];
    [self.view addSubview:view];
    view.alwaysBounceVertical = YES;
    view.showsVerticalScrollIndicator = NO;
    view.showsHorizontalScrollIndicator = NO;
    view.backgroundColor = theme.backgroundColor;
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    CGSize size = UIScreen.mainScreen.bounds.size;
    size.width = MIN(MAX(MIN(size.width, size.height) - 60, 300), 600);
    size.height = size.width;

    AGQRCodeView *qrCodeView = [AGQRCodeView new];
    [view addSubview:qrCodeView];
    [qrCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view).offset(80);
        make.centerX.equalTo(view);
        make.size.mas_equalTo(size);
    }];
    qrCodeView.url = self.url;
    
    UILabel *titleLabel = [UILabel new];
    [view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(qrCodeView.mas_bottom).offset(30);
        make.left.right.equalTo(qrCodeView);
    }];
    titleLabel.textColor = theme.labelColor;
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"TOTPInfoTitle".localized;
    
    UILabel *detailLabel = [UILabel new];
    [view addSubview:detailLabel];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(16);
        make.left.right.equalTo(titleLabel);
    }];
    detailLabel.numberOfLines = 0;
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentCenter;
    style.lineSpacing = 8;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"TOTPInfoDetail".localized];
    [text addAttributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:16],
        NSForegroundColorAttributeName: theme.labelColor,
        NSParagraphStyleAttributeName:style,
    } range:NSMakeRange(0, text.length)];
    detailLabel.attributedText = text;
    
    AGCreatedLabel *createdLabel = [AGCreatedLabel new];
    [view addSubview:createdLabel];
    [createdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view).offset(10);
        make.right.equalTo(qrCodeView);
    }];
    createdLabel.font = [UIFont systemFontOfSize:12];
    createdLabel.created = NSDate.now.timeIntervalSince1970*1000;
}

#pragma mark - Action Methods
- (void)actionExport:(UIBarButtonItem *)sender {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, UIScreen.mainScreen.scale);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[image, [NSURL URLWithString:self.url]] applicationActivities:nil];
    vc.completionWithItemsHandler = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        if (activityError != nil) {
            [AGRouter.shared makeToast:@"Export failed!".localized];
        } else if (completed) {
            [AGRouter.shared makeToast:@"Export success!".localized];
        }
    };
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        vc.popoverPresentationController.barButtonItem = sender;
    }
    [AGRouter.shared presentViewController:vc animated:YES];
}


@end
