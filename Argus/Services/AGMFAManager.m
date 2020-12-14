//
//  AGMFAManager.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGMFAManager.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "AGModel.pbobjc.h"
#import "AGMFAStorage.h"
#import "AGDevice.h"
#import "AGRouter.h"

@interface AGMFAManager () <WCSessionDelegate>

@property (nonatomic, readonly, strong) AGMFAStorage *storage;
@property (nonatomic, readonly, strong) WCSession *session;

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
        _storage = [[AGMFAStorage alloc] initWithURL:[NSURL URLWithString:@kAGMFAFileName relativeToURL:AGDevice.shared.docdir]];
        [self loadRecords];
        _session = nil;
        if (WCSession.isSupported) {
            _session = WCSession.defaultSession;
            self.session.delegate = self;
            [self.session activateSession];
        }
    }
    return self;
}

- (BOOL)canOpenURL:(NSURL *)url {
    return [url.scheme isEqualToString:@"otpauth"] || [url.scheme isEqualToString:@"otpauth-migration"];
}

- (BOOL)openURL:(NSURL *)url {
    BOOL res = NO;
    if ([url.scheme isEqualToString:@"otpauth"]) {
        AGMFAModel *model = [AGMFAModel modelWithData:@{
            @"created": @(NSDate.now.timeIntervalSince1970 * 1000),
            @"url": url.absoluteString,
        }];
        if ([self insertItems:@[model]]) {
            [AGRouter.shared makeToast:@"Add record success".localized];
        } else {
            [AGRouter.shared makeToast:@"Record already exists".localized];
        }
        [AGRouter.shared routeTo:@"/page/main"];
        res = YES;
    } else if ([url.scheme isEqualToString:@"otpauth-migration"]) {
        NSURLComponents *componemts = [NSURLComponents componentsWithString:url.absoluteString];
        if ([componemts.host isEqualToString:@"offline"]) {
            for (NSURLQueryItem *item in componemts.queryItems) {
                if ([item.name isEqualToString:@"data"]) {
                    NSData *data = [[NSData alloc] initWithBase64EncodedString:item.value options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    if (data.length > 0) {
                        NSError *error = nil;
                        AGMMigrationPayload *payload = [AGMMigrationPayload parseFromData:data error:&error];
                        if (error == nil) {
                            uint64_t ts = (uint64_t)(NSDate.now.timeIntervalSince1970 * 1000);
                            NSMutableArray<AGMFAModel *> *items = [NSMutableArray new];
                            for (AGMOtpParameters *item in payload.parametersArray) {
                                NSString *url = buildURLWithParams(item);
                                if (url.length > 0) {
                                    AGMFAModel *model = [AGMFAModel modelWithData:@{
                                        @"created": @(ts++),
                                        @"url": url,
                                    }];
                                    if (model != nil) {
                                        [items addObject:model];
                                    }
                                }
                            }
                            [self insertItems:items];
                            [AGRouter.shared routeTo:@"/page/main"];
                            res = YES;
                        }
                    }
                    break;
                }
            }
        }
    }
    return res;
}

- (AGMFAModel *)itemAtIndex:(NSInteger)index {
    return [self.storage itemAtIndex:index];
}

- (NSUInteger)itemCount {
    return self.storage.count;
}

- (void)deleteItem:(AGMFAModel *)item completion:(void (^ __nullable)(void))completion {
    if (item != nil) {
        [self.storage removeItem:item];
        [self saveRecords];
    }
    if (completion != nil) {
        completion();
    }
}

- (void)copyToPasteboard:(nullable AGMFAModel *)item {
    if (item != nil) {
        [UIPasteboard.generalPasteboard setString:[item calcCode:time(NULL)]];
        [AGRouter.shared makeToast:@"Code copied".localized];
    }
}

- (void)active {
    [self loadRecords];
}

- (void)deactive {
}

- (BOOL)hasWatch {
    return (self.session != nil && self.session.isPaired);
}

- (BOOL)isWatchAppInstalled {
    return (self.hasWatch && self.session.isWatchAppInstalled);
}

- (BOOL)syncWatch:(BOOL)focus {
    BOOL res = NO;
    if (self.hasWatch) {
        res = [self.session updateApplicationContext:@{
            @"last": @(focus ? NSDate.now.timeIntervalSince1970 : 0),
            @"data": self.storage.fileData
        } error:nil];
    }
    return res;
}

#pragma mark - WCSessionDelegate
- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {

}

- (void)sessionDidBecomeInactive:(WCSession *)session {

}

- (void)sessionDidDeactivate:(WCSession *)session {

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

- (BOOL)insertItems:(NSArray<AGMFAModel *> *)models {
    BOOL res = NO;
    for (AGMFAModel *model in models) {
        if (![self.storage containsItem:model]) {
            [self.storage addItem:model];
            res = YES;
        }
    }
    if (res) {
        [self saveRecords];
        [self notifyUpdated];
    }
    return res;
}

- (void)loadRecords {
    if (self.storage.changed && [self.storage load]) {
        [self notifyUpdated];
    }
}

- (void)saveRecords {
    [self.storage save];
    [self syncWatch:NO];
}

static inline NSString *buildURLWithParams(AGMOtpParameters *params) {
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"otpauth";
    if (params.type == AGMOtpType_OtpTypeTotp) {
        components.host = @"totp";
        if (params.issuer.length <= 0) {
            components.path = [NSString stringWithFormat:@"/%@", params.name];
        } else {
            if (params.name.length <= 0) {
                components.path = [NSString stringWithFormat:@"/%@", params.name];
            } else {
                components.path = [NSString stringWithFormat:@"/%@:%@", params.issuer, params.name];
            }
        }
        NSMutableArray<NSURLQueryItem *> *items = [NSMutableArray new];
        switch (params.algorithm) {
            case AGMAlgorithm_AlgorithmSha1:
                break;
            case AGMAlgorithm_AlgorithmSha256:
                [items addObject:[NSURLQueryItem queryItemWithName:@"algorithm" value:@"sha256"]];
                break;
            case AGMAlgorithm_AlgorithmSha512:
                [items addObject:[NSURLQueryItem queryItemWithName:@"algorithm" value:@"sha512"]];
                break;
            case AGMAlgorithm_AlgorithmMd5:
                [items addObject:[NSURLQueryItem queryItemWithName:@"algorithm" value:@"md5"]];
                break;
            default:
                return nil;
        }
        switch (params.digits) {
            case AGMDigitCount_DigitCountSix:
                break;
            case AGMDigitCount_DigitCountEight:
                [items addObject:[NSURLQueryItem queryItemWithName:@"digits" value:@"8"]];
                break;
            default:
                return nil;
        }
        if (params.secret.length > 0) {
            [items addObject:[NSURLQueryItem queryItemWithName:@"secret" value:params.secret.base32EncodedString]];
        }
        if (params.issuer.length > 0) {
            [items addObject:[NSURLQueryItem queryItemWithName:@"issuer" value:params.issuer]];
        }
        components.queryItems = items;
        return components.URL.absoluteString;
    }
    return nil;
}


@end
