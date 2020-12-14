//
//  AGBlurViewController.m
//  Argus
//
//  Created by WizJin on 2020/12/11.
//

#import "AGBlurViewController.h"

@implementation AGBlurViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
}


@end
