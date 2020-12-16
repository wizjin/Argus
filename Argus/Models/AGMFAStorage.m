//
//  AGMFAStorage.m
//  Argus
//
//  Created by WizJin on 2020/12/12.
//

#import "AGMFAStorage.h"

@interface AGMFAStorage ()

@property (nonatomic, readonly, strong) NSMutableArray<AGMFAModel *> *items;

@end

@implementation AGMFAStorage

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super initWithURL:url]) {
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

- (BOOL)load {
    BOOL res = NO;
    if (!self.changed) {
        res = YES;
    } else {
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
        [self write:data updateStatus:YES];
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
            if ([self write:data updateStatus:NO]) {
                res = YES;
            }
        }
    }
    return res;
}


@end
