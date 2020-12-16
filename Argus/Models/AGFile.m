//
//  AGFile.m
//  Argus
//
//  Created by WizJin on 2020/12/16.
//

#import "AGFile.h"

@interface AGFile ()

@property (nonatomic, readonly, strong) NSDate *lastUpdate;

@end

@implementation AGFile

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _pathURL = url;
        _dataKey = nil;
    }
    return self;
}

- (BOOL)changed {
    return ![self.pathURL.modificationDate isEqualToDate:self.lastUpdate];
}

- (NSData *)fileData {
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:self.pathURL options:NSDataReadingUncached error:&error];
    if (error != nil) {
        data = [NSData new];
        _lastUpdate = nil;
    } else {
        _lastUpdate = self.pathURL.modificationDate;
    }
    _dataKey = data.sha1.hex;
    return data;
}

- (BOOL)write:(NSData *)data updateStatus:(BOOL)update {
    BOOL res = YES;
    if (data.length > 0) {
        res = [data writeToURL:self.pathURL atomically:YES];
        if (res) {
            if (update) {
                _lastUpdate = self.pathURL.modificationDate;
            }
            _dataKey = data.sha1.hex;
        }
    }
    return res;
}


@end
