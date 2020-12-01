//
//  AGMainViewController.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGMainViewController.h"
#import <Toast/Toast.h>
#import "AGMFATableViewCell.h"
#import "AGMFATableView.h"
#import "AGMFAEmptyView.h"
#import "AGMFAManager.h"
#import "AGRouter.h"
#import "AGDevice.h"
#import "AGTheme.h"

static NSString *const cellIdentifier = @"cell";

@interface AGMainViewController () <UITableViewDelegate, UITableViewDataSource, AGMFAManagerDelegate>

@property (nonatomic, readonly, strong) AGMFATableView *tableView;
@property (nonatomic, readonly, strong) NSTimer *refreshTimer;
@property (nonatomic, readonly, strong) NSHashTable<AGMFATableViewCell *> *refreshItems;
@property (nonatomic, readonly, strong) UISwipeActionsConfiguration *trailingSwipeActions;

@end

@implementation AGMainViewController

- (instancetype)init {
    if (self = [super init]) {
        _refreshTimer = nil;
        _refreshItems = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)dealloc {
    AGMFAManager.shared.delegate = nil;
    [self stopRefreshTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = AGDevice.shared.name;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:@selector(actionSettings:)];

    UIAction *scan = [UIAction actionWithTitle:@"Scan QR code".localized image:[UIImage systemImageNamed:@"qrcode.viewfinder"] identifier:nil handler:^(UIAction *action) {
        [AGRouter.shared routeTo:@"/page/scan"];
    }];
    UIAction *edit = [UIAction actionWithTitle:@"Manual entry".localized image:[UIImage systemImageNamed:@"square.and.pencil"] identifier:nil handler:^(UIAction *action) {
        [AGRouter.shared routeTo:@"/page/editor"];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"plus"] menu:[UIMenu menuWithChildren:@[scan, edit]]];
    
    AGMFATableView *tableView = [AGMFATableView new];
    [self.view addSubview:(_tableView = tableView)];
    [tableView registerClass:AGMFATableViewCell.class forCellReuseIdentifier:cellIdentifier];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    UIContextualAction *deleteAction = [AGMFATableViewCell actionDelete:tableView];
    _trailingSwipeActions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    self.trailingSwipeActions.performsFirstActionWithFullSwipe = NO;
    
    AGMFAManager.shared.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startRefreshTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopRefreshTimer];
    [super viewWillDisappear:animated];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AGMFAModel *model = [AGMFAManager.shared.items objectAtIndex:indexPath.row];
    if (model != nil) {
        UIPasteboard.generalPasteboard.string = [model calcCode:time(NULL)];
        [self.view makeToast:@"Code copied".localized];
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.trailingSwipeActions;
}

- (UIView *)tableViewEmptyView:(UITableView *)tableView {
    return [[AGMFAEmptyView alloc] initWithTarget:self action:@selector(actionAdd:)];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return AGMFAManager.shared.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AGMFATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell != nil) {
        cell.model = [AGMFAManager.shared.items objectAtIndex:indexPath.row];
        [self.refreshItems addObject:cell];
    }
    return cell;
}

#pragma mark - AGMFAManagerDelegate
- (void)mfaUpdated {
    [self.tableView reloadData];
}

#pragma mark - Private Methods
- (void)actionSettings:(id)sender {
    [AGRouter.shared routeTo:@"/page/settings"];
}

- (void)actionRefresh:(id)sender {
    time_t now = time(NULL);
    for (AGMFATableViewCell *cell in self.refreshItems) {
        [cell update:now];
    }
}

- (void)actionAdd:(id)sender {
    [AGRouter.shared routeTo:@"/page/scan"];
}

- (void)startRefreshTimer {
    if (self.refreshTimer == nil) {
        _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(actionRefresh:) userInfo:nil repeats:YES];
    }
}

- (void)stopRefreshTimer {
    if (self.refreshTimer != nil) {
        [self.refreshTimer invalidate];
        _refreshTimer = nil;
    }
}


@end
