//
//  AGMFAManager.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGMFAManager.h"

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

- (NSArray<AGMFAModel *> *)items {
    return self.mfaItems;
}


@end
