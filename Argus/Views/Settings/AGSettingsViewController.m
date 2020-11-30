//
//  AGSettingsViewController.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGSettingsViewController.h"
#import <XLForm/XLForm.h>
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


@interface AGSettingsViewController ()

@end

@implementation AGSettingsViewController

- (instancetype)init {
    if (self = [super init]) {
        [self initializeForm];
    }
    return self;
}

#pragma mark - Private Methods
- (void)initializeForm {
    self.title = @"Settings".localized;
    
    XLFormRowDescriptor *row;
    XLFormSectionDescriptor *section;
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:self.title];
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
        if ([option.formValue integerValue] == AGTheme.shared.userInterfaceStyle) {
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

    // ABOUT
    [form addFormSection:(section = [XLFormSectionDescriptor formSectionWithTitle:@"ABOUT".localized])];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"version" rowType:XLFormRowDescriptorTypeInfo title:@"Version".localized];
    AGDevice *device = AGDevice.shared;
    row.value = [NSString stringWithFormat:@"%@ (%d)", device.version, device.build];
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
