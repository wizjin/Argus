//
//  InterfaceController.m
//  Watch Extension
//
//  Created by WizJin on 2020/12/11.
//

#import "InterfaceController.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "CodeRowType.h"
#import "AGMFAStorage.h"
#import "AGDevice.h"

@interface InterfaceController () <WCSessionDelegate>

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *emptyTitle;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *emptyBody;
@property (weak, nonatomic) IBOutlet WKInterfaceTable *codeTable;

@property (nonatomic, readonly, strong) AGMFAStorage *storage;
@property (nonatomic, readonly, strong) WCSession *session;
@property (nonatomic, nullable, strong) NSTimer *refreshTimer;

@end


@implementation InterfaceController

- (instancetype)init {
    if (self = [super init]) {
        _storage = [[AGMFAStorage alloc] initWithURL:[NSURL URLWithString:@kAGMFAFileName relativeToURL:AGDevice.shared.docdir]];
        _refreshTimer = nil;
        if (!WCSession.isSupported) {
            _session = nil;
        } else {
            _session = WCSession.defaultSession;
            self.session.delegate = self;
            [self.session activateSession];
        }
    }
    return self;
}

- (void)awakeWithContext:(id)context {
    [self.emptyTitle setText:@"NoMFATitle".localized];
    [self.emptyBody setText:@"NoMFAWatch".localized];
    [self.emptyTitle setHidden:NO];
    [self.emptyBody setHidden:NO];
    [self.codeTable setHidden:YES];
}

- (void)willActivate {
    [self updateContext];
}

- (void)didDeactivate {
}

- (void)didAppear {
    [self startRefreshTimer];
}

- (void)willDisappear {
    [self stopRefreshTimer];
}

#pragma mark - WCSessionDelegate
- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *, id> *)applicationContext {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self updateContext];
    });
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

- (void)updateContext {
    if (self.session != nil && self.session.receivedApplicationContext != nil) {
        id data = [self.session.receivedApplicationContext objectForKey:@"data"];
        if (data != nil && [data isKindOfClass:NSData.class]) {
            [self reloadData]; // TODO: fix cache
            if ([self.storage saveData:data]) {
                [self reloadData];
            }
        }
    }
}

- (void)reloadData {
    if (self.storage.changed && [self.storage load]) {
        if (self.storage.count <= 0) {
            [self.emptyTitle setHidden:NO];
            [self.emptyBody setHidden:NO];
            [self.codeTable setHidden:YES];
        } else {
            [self.emptyTitle setHidden:YES];
            [self.emptyBody setHidden:YES];
            [self.codeTable setHidden:NO];
            [self.codeTable setNumberOfRows:self.storage.count withRowType:@"CodeRowType"];
            for(NSInteger i = 0; i < self.codeTable.numberOfRows; i++) {
                [[self.codeTable rowControllerAtIndex:i] setModel:[self.storage itemAtIndex:i]];
            }
        }
    }
}


@end
