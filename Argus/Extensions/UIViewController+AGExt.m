//
//  UIViewController+AGExt.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "UIViewController+AGExt.h"

@implementation UIViewController (AGExt)

- (UINavigationController *)navigation {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    return navigationController;
}


@end
