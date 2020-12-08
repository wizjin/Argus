//
//  AGDevice.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGDevice.h"

@implementation AGDevice

+ (instancetype)shared {
    static AGDevice *device;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        device = [AGDevice new];
    });
    return device;
}

- (instancetype)init {
    if (self = [super init]) {
        NSBundle *bundle = NSBundle.mainBundle;
        _name = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        _version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        _build = [[bundle objectForInfoDictionaryKey:@"CFBundleVersion"] intValue];
        _docdir = [[NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    }
    return self;
}


@end
