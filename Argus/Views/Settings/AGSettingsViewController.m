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

@interface AGFormSelectorCell : XLFormSelectorCell
@end

@implementation AGFormSelectorCell

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    if (self.rowDescriptor.action.formBlock) {
        self.rowDescriptor.action.formBlock(self.rowDescriptor);
    }
    UITableView *tableView = controller.tableView;
    if (tableView != nil) {
        NSIndexPath *index = tableView.indexPathForSelectedRow;
        if (index != nil) {
            [tableView deselectRowAtIndexPath:index animated:YES];
        }
    }
}

@end

@interface AGSettingsViewController () <XLFormDescriptorDelegate>

@end

@implementation AGSettingsViewController

- (instancetype)init {
    if (self = [super init]) {
        [self initializeForm];
    }
    return self;
}

#pragma mark - XLFormDescriptorDelegate
-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    if ([formRow.tag isEqualToString:@"locker"]) {
        AGSecurity.shared.hasLocker = [newValue boolValue];
        if (AGSecurity.shared.hasLocker != [newValue boolValue]) {
            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                formRow.value = @(AGSecurity.shared.hasLocker);
                [self reloadFormRow:formRow];
            });
        }
    }
}

#pragma mark - Private Methods
- (void)initializeForm {
    self.title = @"Settings".localized;
    
    AGTheme *theme = AGTheme.shared;
    
    XLFormRowDescriptor *row;
    XLFormSectionDescriptor *section;
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:self.title];
    form.delegate = self;

    // GENERAL
    [form addFormSection:(section = [XLFormSectionDescriptor formSectionWithTitle:@"GENERAL".localized])];
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

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"locker" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Locker".localized];
    row.value = @(AGSecurity.shared.hasLocker);
    [section addFormRow:row];

    // WATCH
    [form addFormSection:(section = [XLFormSectionDescriptor formSectionWithTitle:@"WATCH".localized])];
    section.hidden = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary<NSString *,id> *binds) {
        return !AGMFAManager.shared.hasWatch;
    }];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"appinstall" rowType:XLFormRowDescriptorTypeInfo title:@"No watch app installed".localized];
    [row.cellConfig setObject:theme.minorLabelColor forKey:@"textLabel.textColor"];
    row.hidden = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary<NSString *,id> *binds) {
        return AGMFAManager.shared.isWatchAppInstalled;
    }];
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"syncwatch" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Force data sync".localized];
    [row.cellConfig setObject:@(UITableViewCellAccessoryNone) forKey:@"accessoryType"];
    row.cellClass = AGFormSelectorCell.class;
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
    row.cellClass = AGFormSelectorCell.class;
    row.action.formBlock = ^(XLFormRowDescriptor *row) {
        [AGRouter.shared routeTo:@kAGPrivacyURL withParams:@{ @"title": @"Privacy Policy".localized }];
    };
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"acknowledgements" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Acknowledgements".localized];
    row.cellClass = AGFormSelectorCell.class;
    row.action.formBlock = ^(XLFormRowDescriptor *row) {
        [AGRouter.shared routeTo:@"/page/acknowledgements"];
    };
    [section addFormRow:row];
    
    self.form = form;
}


@end
