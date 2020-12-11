//
//  InterfaceController.m
//  Watch Extension
//
//  Created by WizJin on 2020/12/11.
//

#import "InterfaceController.h"
#import "AGMFAModel.h"
#import "CodeRowType.h"

@interface InterfaceController ()

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *emptyTitle;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *emptyBody;
@property (weak, nonatomic) IBOutlet WKInterfaceTable *codeTable;
@property (nonatomic, readonly, strong) NSArray<AGMFAModel *> *items;
@property (nonatomic, nullable, strong) NSTimer *refreshTimer;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    uint64_t ts = (uint64_t)(NSDate.now.timeIntervalSince1970 * 1000);
    _items = @[
        [AGMFAModel modelWithData:@{
            @"created": @(ts),
            @"url": @"otpauth://totp/Example:alice@google.com?secret=JBSWY3DPEHPK3PXP&issuer=Example",
        }],
        [AGMFAModel modelWithData:@{
            @"created": @(ts+1),
            @"url": @"otpauth://totp/Github:alice@google.com?secret=JBSWY3DPEHPK3PXT&issuer=Github",
        }],
        [AGMFAModel modelWithData:@{
            @"created": @(ts+1),
            @"url": @"otpauth://totp/Docker:alice@google.com?secret=JBSWY3DPEHPK3QXT&issuer=Github",
        }],
    ];
    
    [self.emptyTitle setText:@"NoMFATitle".localized];
    [self.emptyBody setText:@"NoMFAWatch".localized];

    if (self.items.count <= 0) {
        [self.emptyTitle setHidden:NO];
        [self.emptyBody setHidden:NO];
        [self.codeTable setHidden:YES];
    } else {
        [self.emptyTitle setHidden:YES];
        [self.emptyBody setHidden:YES];
        [self.codeTable setHidden:NO];
        [self.codeTable setNumberOfRows:self.items.count withRowType:@"CodeRowType"];
        for(NSInteger i = 0; i < self.codeTable.numberOfRows; i++) {
            [[self.codeTable rowControllerAtIndex:i] setModel:[self.items objectAtIndex:i]];
        }
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
}

- (void)didAppear {
    [self startRefreshTimer];
}

- (void)willDisappear {
    [self stopRefreshTimer];
}

#pragma mark - Private Methods
- (void)startRefreshTimer {
    if (self.refreshTimer == nil) {
        _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(actionRefresh:) userInfo:nil repeats:YES];
    }
}

- (void)stopRefreshTimer {
    if (self.refreshTimer != nil) {
        [self.refreshTimer invalidate];
        _refreshTimer = nil;
    }
}

- (void)actionRefresh:(id)sender {
    time_t now = time(NULL);
    for(NSInteger i = 0; i < self.codeTable.numberOfRows; i++) {
        [[self.codeTable rowControllerAtIndex:i] update:now];
    }
}


@end
