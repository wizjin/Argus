//
//  AGMainViewController.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGMainViewController.h"
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
    [AGMFAManager.shared removeDelegate:self];
    [self stopRefreshTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = AGDevice.shared.name;

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageWithSymbol:@"gear"] target:self action:@selector(actionSettings:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageWithSymbol:@"qrcode.viewfinder"] target:self action:@selector(actionScan:)];
    
    AGMFATableView *tableView = [AGMFATableView new];
    [self.view addSubview:(_tableView = tableView)];
    [tableView registerClass:AGMFATableViewCell.class forCellReuseIdentifier:cellIdentifier];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [AGMFAManager.shared addDelegate:self];
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
    [AGMFAManager.shared copyToPasteboard:[AGMFAManager.shared itemAtIndex:indexPath.row]];
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UISwipeActionsConfiguration configurationWithActions:@[[AGMFATableViewCell actionEdit:tableView indexPath:indexPath]]];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UISwipeActionsConfiguration configurationWithActions:@[[AGMFATableViewCell actionDelete:tableView indexPath:indexPath]]];
}

- (UIView *)tableViewEmptyView:(UITableView *)tableView {
    return [[AGMFAEmptyView alloc] initWithTarget:self action:@selector(actionAdd:)];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return AGMFAManager.shared.itemCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AGMFATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell != nil) {
        cell.model = [AGMFAManager.shared itemAtIndex:indexPath.row];
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

- (void)actionScan:(id)sender {
    [AGRouter.shared routeTo:@"/page/scan"];
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
