//
//  AGSettingsViewController.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGSettingsViewController.h"
#import <XLForm/XLForm.h>
#import "AGMFAManager.h"
#import "AGSecurity.h"
#import "AGDevice.h"
#import "AGRouter.h"
#import "AGTheme.h"

@interface AGSettingsViewController () <AGMFAManagerDelegate>

@end

@implementation AGSettingsViewController

- (instancetype)init {
    if (self = [super init]) {
        [self initializeForm];
        [AGMFAManager.shared addDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [AGMFAManager.shared removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    XLFormRowDescriptor *row = [self.form formRowAtIndex:indexPath];
    if (row.rowType == XLFormRowDescriptorTypeSelectorPush && row.action.formBlock != nil) {
        row.action.formBlock(row);
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - AGMFAManagerDelegate
- (void)watchStatusChanged {
    XLFormRowDescriptor *row = [self.form formRowWithTag:@"appinstall"];
    [row setHidden:row.hidden];
    [self.tableView reloadData];
}

#pragma mark - Private Methods
- (void)initializeForm {
    @weakify(self);
    
    self.title = @"Settings".localized;
    
    AGTheme *theme = AGTheme.shared;
    
    XLFormRowDescriptor *row;
    XLFormSectionDescriptor *section;
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:self.title];

    // GENERAL
    [form addFormSection:(section = [XLFormSectionDescriptor formSectionWithTitle:@"GENERAL".localized])];
    if (@available(iOS 13.0, *)) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"appearance" rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Appearance".localized];
        row.cellConfig[@"accessoryType"] = @(UITableViewCellAccessoryDisclosureIndicator);
        row.selectorOptions = @[
            [XLFormOptionsObject formOptionsObjectWithValue:@(UIUserInterfaceStyleUnspecified) displayText:@"Default".localized],
            [XLFormOptionsObject formOptionsObjectWithValue:@(UIUserInterfaceStyleLight) displayText:@"Light".localized],
            [XLFormOptionsObject formOptionsObjectWithValue:@(UIUserInterfaceStyleDark) displayText:@"Dark".localized],
        ];
        for (XLFormOptionsObject *option in row.selectorOptions) {
            if ([option.formValue integerValue] == theme.userInterfaceStyle) {
                [row setValue:option];
                row.value = option;
                [self reloadFormRow:row];
                break;
            }
        }
        row.onChangeBlock = ^(id oldValue, XLFormOptionsObject *newValue, XLFormRowDescriptor *rowDescriptor) {
            AGTheme.shared.userInterfaceStyle = [newValue.formValue integerValue];
        };
        [section addFormRow:row];
    }

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"locker" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Locker".localized];
    row.value = @(AGSecurity.shared.hasLocker);
    row.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor *formRow) {
        AGSecurity.shared.hasLocker = [newValue boolValue];
        if (AGSecurity.shared.hasLocker != [newValue boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                formRow.value = @(AGSecurity.shared.hasLocker);
                [self reloadFormRow:formRow];
            });
        }
    };
    [section addFormRow:row];
    
    // DATA Manager
    [form addFormSection:(section = [XLFormSectionDescriptor formSectionWithTitle:@"DATA MANAGER".localized])];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"icloudwarn" rowType:XLFormRowDescriptorTypeInfo title:@"iCloud has been disabled".localized];
    [row.cellConfig setObject:theme.minorLabelColor forKey:@"textLabel.textColor"];
    row.hidden = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary<NSString *,id> *binds) {
        return AGMFAManager.shared.iCloudEnabled;
    }];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"icloud" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Backup to iCloud".localized];
    row.value = @(AGMFAManager.shared.iCloudSyncEnabled);
    row.onChangeBlock = ^(id oldValue, id newValue, XLFormRowDescriptor *formRow) {
        [AGMFAManager.shared setICloudSyncEnabled:[newValue boolValue] cleanup:NO];
        if (AGMFAManager.shared.iCloudSyncEnabled != [newValue boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                formRow.value = @(AGMFAManager.shared.iCloudSyncEnabled);
                [self reloadFormRow:formRow];
            });
        }
    };
    row.hidden = @"$icloudwarn.isHidden=NO";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"export-qrcode" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Export with QR code".localized];
    [row.cellConfigIfDisabled setObject:theme.minorLabelColor forKey:@"textLabel.textColor"];
    row.disabled = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary<NSString *,id> *binds) {
        return AGMFAManager.shared.itemCount <= 0;
    }];
    row.action.formBlock = ^(XLFormRowDescriptor *row) {
        [AGRouter.shared routeTo:@"/page/export"];
    };
    [section addFormRow:row];
    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"export-text" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Export into text file".localized];
//    [row.cellConfigIfDisabled setObject:theme.minorLabelColor forKey:@"textLabel.textColor"];
//    row.disabled = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary<NSString *,id> *binds) {
//        return AGMFAManager.shared.itemCount <= 0;
//    }];
//    row.action.formBlock = ^(XLFormRowDescriptor *row) {
//        [AGRouter.shared routeTo:@"/page/export-text"];
//    };
//    [section addFormRow:row];

    // WATCH
    [form addFormSection:(section = [XLFormSectionDescriptor formSectionWithTitle:@"WATCH".localized])];
    section.hidden = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary<NSString *,id> *binds) {
        return !AGMFAManager.shared.hasWatch;
    }];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"appinstall" rowType:XLFormRowDescriptorTypeSelectorPush title:@"No watch app installed".localized];
    [row.cellConfig setObject:theme.minorLabelColor forKey:@"textLabel.textColor"];
    row.hidden = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary<NSString *,id> *binds) {
        return AGMFAManager.shared.isWatchAppInstalled;
    }];
    row.action.formBlock = ^(XLFormRowDescriptor *row) {
        [AGRouter.shared routeTo:@"/action/openurl" withParams:@{ @"url": @kAGWatchLinkURL }];
    };
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"syncwatch" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Force data sync".localized];
    [row.cellConfig setObject:@(UITableViewCellAccessoryNone) forKey:@"accessoryType"];
    row.hidden = @"$appinstall.isHidden=NO";

    row.action.formBlock = ^(XLFormRowDescriptor *row) {
        if ([AGMFAManager.shared syncWatch:YES]) {
            [AGRouter.shared makeToast:@"Sync data success!".localized];
        } else {
            [AGRouter.shared makeToast:@"Sync data failed!".localized];
        }
    };
    [section addFormRow:row];

    // ABOUT
    [form addFormSection:(section = [XLFormSectionDescriptor formSectionWithTitle:@"ABOUT".localized])];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"version" rowType:XLFormRowDescriptorTypeInfo title:@"Version".localized];
    AGDevice *device = AGDevice.shared;
    row.value = device.version;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"privacy" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Privacy Policy".localized];
    row.action.formBlock = ^(XLFormRowDescriptor *row) {
        [AGRouter.shared routeTo:@kAGPrivacyURL withParams:@{ @"title": @"Privacy Policy".localized }];
    };
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"acknowledgements" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Acknowledgements".localized];
    row.action.formBlock = ^(XLFormRowDescriptor *row) {
        [AGRouter.shared routeTo:@"/page/acknowledgements"];
    };
    [section addFormRow:row];
    
    self.form = form;
}


@end
