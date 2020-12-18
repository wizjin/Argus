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

#define kCHiCloudSyncKey        "icloud.sync"
#define kCHiCloudLastSyncKey    "icloud.lastsync"

@interface AGMFAManager () <WCSessionDelegate>

@property (nonatomic, readonly, strong) NSHashTable<id<AGMFAManagerDelegate>> *delegates;
@property (nonatomic, readonly, strong) AGMFAStorage *storage;
@property (nonatomic, readonly, strong) NSMetadataQuery *iCloudQuery;
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
        _delegates = [NSHashTable weakObjectsHashTable];
        NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
        if ([userDefaults objectForKey:@kCHiCloudSyncKey] == nil) {
            [userDefaults setBool:YES forKey:@kCHiCloudSyncKey]; // Defalut enabled
        }
        _iCloudSyncEnabled = [userDefaults boolForKey:@kCHiCloudSyncKey];
        _storage = [[AGMFAStorage alloc] initWithURL:[NSURL URLWithString:@kAGMFAFileName relativeToURL:AGDevice.shared.docdir]];
        _session = nil;
        if (WCSession.isSupported) {
            _session = WCSession.defaultSession;
            self.session.delegate = self;
            [self.session activateSession];
        }
        _iCloudQuery = [NSMetadataQuery new];
        self.iCloudQuery.searchScopes = @[NSMetadataQueryUbiquitousDocumentsScope];
        self.iCloudQuery.predicate = [NSPredicate predicateWithValue:YES];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(queryDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(queryDidFinishGathering:) name:NSMetadataQueryDidFinishGatheringNotification object:nil];

        [self loadRecords];
        [self readFromiCloud];
    }
    return self;
}

- (void)addDelegate:(id<AGMFAManagerDelegate>)delegate {
    [self.delegates addObject:delegate];
}

- (void)removeDelegate:(id<AGMFAManagerDelegate>)delegate {
    [self.delegates removeObject:delegate];
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
                                NSString *url = [AGMFAModel URLWithParams:item];
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

- (NSArray<NSString *> *)createExportURL:(NSArray<AGMFAModel *> *)models {
    NSMutableArray<NSString *> *urls = [NSMutableArray new];
    AGMMigrationPayload *payload = [AGMMigrationPayload new];
    payload.version = 1;
    for (AGMFAModel *model in models) {
        AGMOtpParameters *item = model.pbParams;
        if (item != nil) {
            [payload.parametersArray addObject:item];
        }
    }
    [urls addObject:[@"otpauth-migration://offline?data=" stringByAppendingString:[payload.data base64EncodedStringWithOptions:0]]];
    return urls;
}

- (void)copyToPasteboard:(nullable AGMFAModel *)item {
    if (item != nil) {
        [UIPasteboard.generalPasteboard setString:[item calcCode:time(NULL)]];
        [AGRouter.shared makeToast:@"Code copied".localized];
    }
}

- (void)active {
    [self.iCloudQuery startQuery];
    [self loadRecords];
}

- (void)deactive {
    if (self.iCloudQuery.isStarted) {
        [self.iCloudQuery stopQuery];
    }
}

- (BOOL)iCloudEnabled {
    return (self.iCloudItemUrl != nil);
}

- (void)setICloudSyncEnabled:(BOOL)iCloudSyncEnabled cleanup:(BOOL)cleanup {
    if (_iCloudSyncEnabled != iCloudSyncEnabled) {
        _iCloudSyncEnabled = iCloudSyncEnabled;
        if (self.iCloudSyncEnabled) {
            [self writeToiCloud];
        } else {
            [NSUserDefaults.standardUserDefaults removeObjectForKey:@kCHiCloudLastSyncKey];
        }
        [NSUserDefaults.standardUserDefaults setBool:self.iCloudSyncEnabled forKey:@kCHiCloudSyncKey];
    }
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

#pragma mark - Query
- (void)queryDidUpdate:(NSNotification *)notification {
    [self.iCloudQuery disableUpdates];
    [self readFromiCloud];
    [self.iCloudQuery enableUpdates];
}


- (void)queryDidFinishGathering:(NSNotification *)notification {
    [self.iCloudQuery disableUpdates];
    [self readFromiCloud];
    [self.iCloudQuery enableUpdates];
}

#pragma mark - WCSessionDelegate
- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {

}

- (void)sessionWatchStateDidChange:(WCSession *)session {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        for (id<AGMFAManagerDelegate> delegate in self.delegates) {
            if (delegate != nil && [delegate respondsToSelector:@selector(watchStatusChanged)]) {
                [delegate watchStatusChanged];
            }
        }
        if (self.isWatchAppInstalled) {
            [self syncWatch:YES];
        }
    });
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
        for (id<AGMFAManagerDelegate> delegate in self.delegates) {
            if (delegate != nil && [delegate respondsToSelector:@selector(mfaUpdated)]) {
                [delegate mfaUpdated];
            }
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
    [self writeToiCloud];
    [self syncWatch:NO];
}

- (void)readFromiCloud {
    if (self.iCloudSyncEnabled) {
        NSFileManager *manager = NSFileManager.defaultManager;
        NSURL *url = self.iCloudItemUrl;
        if ([manager isUbiquitousItemAtURL:url]) {
            NSError *error = nil;
            NSString *status = nil;
            [url getResourceValue:&status forKey:NSURLUbiquitousItemDownloadingStatusKey error:&error];
            if (error == nil) {
                if ([status isEqualToString:NSURLUbiquitousItemDownloadingStatusNotDownloaded]) {
                    [manager startDownloadingUbiquitousItemAtURL:url error:&error];
                } else if ([status isEqualToString:NSURLUbiquitousItemDownloadingStatusCurrent]) {
                    NSDate *date;
                    [url getResourceValue:&date forKey:NSURLContentModificationDateKey error:&error];
                    if (error == nil) {
                        if([NSUserDefaults.standardUserDefaults integerForKey:@kCHiCloudLastSyncKey] != date.timeIntervalSince1970) {
                            NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
                            if (error == nil && data.length > 0) {
                                if ([self.storage.fileData isEqualToData:data]) {
                                    [NSUserDefaults.standardUserDefaults setInteger:date.timeIntervalSince1970 forKey:@kCHiCloudLastSyncKey];
                                } else {
                                    @weakify(self);
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if ([self.storage saveData:data]) {
                                            @strongify(self);
                                            [NSUserDefaults.standardUserDefaults setInteger:date.timeIntervalSince1970 forKey:@kCHiCloudLastSyncKey];
                                            [self loadRecords];
                                            [self syncWatch:YES];
                                        }
                                    });
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (BOOL)writeToiCloud {
    BOOL res = YES;
    if (self.iCloudSyncEnabled) {
        res = NO;
        NSURL *url = self.iCloudItemUrl;
        if (url != nil) {
            NSData *data = self.storage.fileData;
            NSError *error = nil;
            NSString *status = nil;
            [url getResourceValue:&status forKey:NSURLUbiquitousItemDownloadingStatusKey error:&error];
            if (error == nil && [status isEqualToString:NSURLUbiquitousItemDownloadingStatusCurrent]) {
                NSData *remoteData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
                if (error == nil && remoteData.length > 0) {
                    res = [remoteData isEqualToData:data];
                }
            }
            if (!res) {
                NSFileManager *manager = NSFileManager.defaultManager;
                if ([manager isUbiquitousItemAtURL:url]) {
                    [data writeToURL:url options:NSDataWritingAtomic error:&error];
                } else if (data.length > 0) {
                    [manager setUbiquitous:YES itemAtURL:self.storage.pathURL destinationURL:url error:&error];
                }
                if (error == nil) {
                    res = YES;
                }
            }
        }
    }
    return res;
}

- (NSURL *)iCloudItemUrl {
    NSURL *url = [NSFileManager.defaultManager URLForUbiquityContainerIdentifier:@kAGiCloudContainer];
    if (url != nil) {
        url = [[url URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@kAGMFAFileName];
    }
    return url;
}


@end
