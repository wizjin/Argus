//
//  AGMFAManager.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGMFAManager.h"
#import "AGRouter.h"

@interface AGMFAManager ()

@property (nonatomic, readonly, strong) NSMutableArray<AGMFAModel *> *mfaItems;

@end

@implementation AGMFAManager

+ (instancetype)shared {
    static AGMFAManager *manger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manger = [AGMFAManager new];
    });
    return manger;
}

- (instancetype)init {
    if (self = [super init]) {
        _mfaItems = [NSMutableArray new];
        [self.mfaItems addObject:[AGMFAModel modelWithURL:[NSURL URLWithString:@"otpauth://totp/Example:alice@google.com?secret=JBSWY3DPEHPK3PXP&issuer=Example"]]];
    }
    return self;
}

- (BOOL)openURL:(NSURL *)url {
    BOOL res = NO;
    AGMFAModel *model = [AGMFAModel modelWithURL:url];
    if (model != nil) {
        model.created = NSDate.now;
        [self.mfaItems addObject:model];
        [AGRouter.shared routeTo:@"/page/main"];
        [self notifyUpdated];
        res = YES;
    }
    return res;
}

- (NSArray<AGMFAModel *> *)items {
    return self.mfaItems;
}

- (void)deleteItem:(AGMFAModel *)item completion:(void (^ __nullable)(void))completion {
    if (item != nil) {
        [self.mfaItems removeObject:item];
    }
    if (completion != nil) {
        completion();
    }
}

- (void)active {

}

- (void)deactive {
    
}

#pragma mark - Private Methods
- (void)notifyUpdated {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (self.delegate != nil) {
            [self.delegate mfaUpdated];
        }
    });
}


@end
