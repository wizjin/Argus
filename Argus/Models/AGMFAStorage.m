//
//  AGMFAStorage.m
//  Argus
//
//  Created by WizJin on 2020/12/12.
//

#import "AGMFAStorage.h"

@interface AGMFAStorage ()

@property (nonatomic, readonly, strong) NSURL *pathURL;
@property (nonatomic, readonly, strong) NSDate *lastUpdate;
@property (nonatomic, readonly, strong) NSMutableArray<AGMFAModel *> *items;
@property (nonatomic, readonly, strong) NSString *dataKey;

@end

@implementation AGMFAStorage

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _pathURL = url;
        _dataKey = nil;
        _items = [NSMutableArray new];
    }
    return self;
}

- (BOOL)containsItem:(AGMFAModel *)item {
    return [self.items containsObject:item];
}

- (void)removeItem:(AGMFAModel *)item {
    [self.items removeObject:item];
}

- (void)addItem:(AGMFAModel *)item {
    [self.items addObject:item];
}

- (AGMFAModel *)itemAtIndex:(NSInteger)index {
    return [self.items objectAtIndex:index];
}

- (NSUInteger)count {
    return self.items.count;
}

- (NSData *)fileData {
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:self.pathURL options:NSDataReadingUncached error:&error];
    if (error != nil) {
        data = [NSData new];
    }
    return data;
}

- (BOOL)changed {
    return ![self.fileLastUpdate isEqualToDate:self.lastUpdate];
}

- (BOOL)load {
    BOOL res = NO;
    NSDate *date = self.fileLastUpdate;
    if ([date isEqualToDate:self.lastUpdate]) {
        res = YES;
    } else {
        _lastUpdate = date;
        NSError *error = nil;
        NSData *fileData = self.fileData;
        NSData *data = [fileData decompress];
        if (data .length > 0) {
            NSDictionary *item = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:&error];
            if (error == nil && item != nil) {
                NSArray<NSDictionary *> *items = [item valueForKey:@"items"];
                NSMutableArray<AGMFAModel *> *mfaItems = [NSMutableArray arrayWithCapacity:items.count];
                for (NSDictionary *item in items) {
                    AGMFAModel *mfa = [AGMFAModel modelWithData:item];
                    if (mfa != nil) {
                        [mfaItems addObject:mfa];
                    }
                }
                _items = mfaItems;
                res = YES;
            }
        }
        _dataKey = fileData.sha1.hex;
    }
    return res;
}

- (BOOL)save {
    BOOL res = NO;
    NSMutableArray<NSDictionary *> *items = [NSMutableArray arrayWithCapacity:self.items.count];
    for (AGMFAModel *model in self.items) {
        [items addObject:model.data];
    }
    NSError *error = nil;
    NSData *data = [[NSJSONSerialization dataWithJSONObject:@{ @"items": items } options:NSJSONWritingSortedKeys error:&error] compress];
    if (error == nil && data.length > 0) {
        [data writeToURL:self.pathURL atomically:YES];
        _lastUpdate = self.fileLastUpdate;
        _dataKey = data.sha1.hex;
        res = YES;
    }
    return res;
}

- (BOOL)saveData:(NSData *)data {
    BOOL res = NO;
    if (data.length > 0 && self.dataKey != nil) {
        NSString *key = data.sha1.hex;
        if ([self.dataKey isEqualToString:key]) {
            res = YES;
        } else {
            if ([data writeToURL:self.pathURL atomically:YES]) {
                _dataKey = key;
                res = YES;
            }
        }
    }
    return res;
}

#pragma mark - Private Methods
- (NSDate *)fileLastUpdate {
    NSDate *date;
    NSError *error = nil;
    [self.pathURL getResourceValue:&date forKey:NSURLContentModificationDateKey error:&error];
    if (error != nil) {
        date = nil;
    }
    return date;
}


@end
