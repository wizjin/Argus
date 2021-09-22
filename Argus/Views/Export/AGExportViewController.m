//
//  AGExportViewController.m
//  Argus
//
//  Created by WizJin on 2020/12/18.
//

#import "AGExportViewController.h"
#import "AGExportTableViewCell.h"
#import "AGMFAManager.h"
#import "AGRouter.h"
#import "AGTheme.h"

#define kCHExportItemMaxN       10

static NSString *const cellIdentifier = @"cell";

@interface AGExportViewController ()  <UITableViewDelegate, UITableViewDataSource, AGMFAManagerDelegate>

@property (nonatomic, readonly, strong) UITableView *tableView;
@property (nonatomic, readonly, strong) NSHashTable<AGMFAModel *> *selectedItems;

@end

@implementation AGExportViewController

- (instancetype)init {
    if (self = [super init]) {
        _selectedItems = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)dealloc {
    [AGMFAManager.shared removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTitle:@"Export".localized target:self action:@selector(actionExport:)];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:(_tableView = tableView)];
    [tableView registerClass:AGExportTableViewCell.class forCellReuseIdentifier:cellIdentifier];
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, kAGTableCellMargin)];
    tableView.backgroundColor = AGTheme.shared.groupedBackgroundColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.allowsMultipleSelection = YES;
    tableView.rowHeight = kAGExportCellHeight + kAGTableCellMargin;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];

    [AGMFAManager.shared addDelegate:self];
    [self updateAction];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AGMFAModel *model = [[tableView cellForRowAtIndexPath:indexPath] model];
    if (model != nil) {
        if (!model.canExportPB) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [AGRouter.shared makeToast:@"This record format is not supported to export!".localized];
        } else {
            if ([self.selectedItems containsObject:model]) {
                [self.selectedItems removeObject:model];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            } else if (self.selectedItems.count >= kCHExportItemMaxN) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [AGRouter.shared makeToast:[NSString stringWithFormat:@"Export up to %@ records at a time.".localized, @(kCHExportItemMaxN)]];
            } else {
                [self.selectedItems addObject:model];
            }
        }
        [self updateAction];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return AGMFAManager.shared.itemCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AGExportTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell != nil) {
        cell.model = [AGMFAManager.shared itemAtIndex:indexPath.row];
        [cell setSelected:[self.selectedItems containsObject:cell.model] animated:NO];
    }
    return cell;
}

#pragma mark - AGMFAManagerDelegate
- (void)mfaUpdated {
    [self.tableView reloadData];
}

#pragma mark - Action Methods
- (void)actionExport:(id)sender {
    [AGRouter.shared routeTo:@"/page/export_qrcode" withParams:@{
        @"urls": [AGMFAManager.shared createExportURL:self.selectedItems.allObjects],
    }];
}

#pragma mark - Private Methods
- (void)updateAction {
    self.navigationItem.rightBarButtonItem.enabled = (self.selectedItems.count > 0);
    self.title = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)self.selectedItems.count, (unsigned long)AGMFAManager.shared.itemCount];
}


@end
