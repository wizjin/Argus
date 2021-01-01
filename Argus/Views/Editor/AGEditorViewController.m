//
//  AGEditorViewController.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGEditorViewController.h"
#import "AGCountdownView.h"
#import "AGCreatedLabel.h"
#import "AGQRCodeView.h"
#import "AGCodeView.h"
#import "AGMFAManager.h"
#import "AGRouter.h"
#import "AGTheme.h"

@interface AGEditorViewController ()

@property (nonatomic, readonly, strong) NSTimer *refreshTimer;
@property (nonatomic, readonly, strong) AGMFAModel *model;
@property (nonatomic, readonly, strong) AGCountdownView * countdown;
@property (nonatomic, readonly, strong) AGCodeView *codeLabel;
@property (nonatomic, readonly, strong) AGQRCodeView *qrCodeView;
@property (nonatomic, readonly, strong) UITapGestureRecognizer *recognizer;

@end

@implementation AGEditorViewController

- (instancetype)initWithModel:(AGMFAModel *)model {
    if (self = [super init]) {
        _model = model;
        self.title = model.title;
    }
    return self;
}

- (void)dealloc {
    [self stopRefreshTimer];
    [self.view removeGestureRecognizer:self.recognizer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AGTheme *theme = AGTheme.shared;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageWithSymbol:@"square.and.arrow.up"] target:self action:@selector(actionExport:)];

    UIScrollView *view = [UIScrollView new];
    [self.view addSubview:view];
    view.alwaysBounceVertical = YES;
    view.showsVerticalScrollIndicator = NO;
    view.showsHorizontalScrollIndicator = NO;
    view.backgroundColor = theme.groupedBackgroundColor;
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    UILabel *detailLabel = [UILabel new];
    [view addSubview:detailLabel];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view).offset(20);
        make.left.equalTo(view).offset(20);
    }];
    detailLabel.font = [UIFont boldSystemFontOfSize:18];
    detailLabel.textColor = theme.labelColor;
    detailLabel.text = self.model.detail;

    AGCountdownView * countdown = [AGCountdownView new];
    [view addSubview:(_countdown = countdown)];
    [countdown mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.top.equalTo(detailLabel);
        make.right.equalTo(self.view).offset(-20);
    }];
    
    AGCodeView *codeLabel = [AGCodeView new];
    [view addSubview:(_codeLabel = codeLabel)];
    [codeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(detailLabel.mas_bottom).offset(40);
        make.centerX.equalTo(self.view);
    }];
    codeLabel.fontSize = 60;

    AGQRCodeView *qrCodeView = [AGQRCodeView new];
    [view addSubview:(_qrCodeView = qrCodeView)];
    [qrCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(codeLabel.mas_bottom).offset(40);
        make.centerX.equalTo(codeLabel);
        make.size.mas_equalTo(CGSizeMake(260, 260));
    }];
    qrCodeView.url = self.model.url;
    
    AGCreatedLabel *createdLabel = [AGCreatedLabel new];
    [view addSubview:createdLabel];
    [createdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(qrCodeView.mas_bottom).offset(30);
        make.centerX.equalTo(qrCodeView);
    }];
    createdLabel.font = [UIFont systemFontOfSize:12];
    createdLabel.created = self.model.created;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionDoCopy:)];
    [self.view addGestureRecognizer:(_recognizer = recognizer)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startRefreshTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopRefreshTimer];
    [super viewWillDisappear:animated];
}

#pragma mark - Actions Methods
- (void)actionExport:(UIBarButtonItem *)sender {
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[self.qrCodeView.snapshotImage, [NSURL URLWithString:self.model.url]] applicationActivities:nil];
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

- (void)actionDoCopy:(id)sender {
    [AGMFAManager.shared copyToPasteboard:self.model];
}

- (void)actionRefresh:(id)sender {
    [self update:time(NULL)];
}

- (void)update:(time_t)now {
    [self.countdown update:self.model remainder:[self.codeLabel update:self.model now:now]];
}

#pragma mark - Private Methods
- (void)startRefreshTimer {
    if (self.refreshTimer == nil) {
        _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(actionRefresh:) userInfo:nil repeats:YES];
    }
}

- (void)stopRefreshTimer {
    if (self.refreshTimer != nil) {
        [self.refreshTimer invalidate];
        _refreshTimer = nil;
    }
}


@end
