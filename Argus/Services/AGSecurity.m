//
//  AGSecurity.m
//  Argus
//
//  Created by WizJin on 2020/12/10.
//

#import "AGSecurity.h"
#import <Security/Security.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "AGDevice.h"

#define kAGSecKeyCommon \
    (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,      \
    (__bridge id)kSecAttrAccount: AGDevice.shared.name,                 \
    (__bridge id)kSecAttrService: @"com.wizjin.argus.lock",             \

@interface AGSecurity ()

@property (nonatomic, assign) time_t lastUpdate;

@end

@implementation AGSecurity

+ (instancetype)shared {
    static AGSecurity *security;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        security = [AGSecurity new];
    });
    return security;
}

- (instancetype)init {
    if (self = [super init]) {
        _lastUpdate = 0;
        _hasLocker = [NSUserDefaults.standardUserDefaults boolForKey:@"hasLocker"];
        if (_hasLocker && !self.isKeyExist) {
            _hasLocker = NO;
            [NSUserDefaults.standardUserDefaults setBool:_hasLocker forKey:@"hasLocker"];
        }
    }
    return self;
}

- (void)setHasLocker:(BOOL)hasLocker {
    if (self.hasLocker != hasLocker) {
        if (!hasLocker) {
            OSStatus err = SecItemDelete((__bridge CFDictionaryRef)@{ kAGSecKeyCommon });
            if (err != errSecSuccess && err != errSecItemNotFound) {
                return;
            }
        } else {
            if (!self.isKeyExist) {
                hasLocker = NO;
                LAContext *context = [LAContext new];
                context.touchIDAuthenticationAllowableReuseDuration = 10;
                NSMutableData *data = [NSMutableData dataWithLength:sizeof(uuid_t)];
                [NSUUID.UUID getUUIDBytes:data.mutableBytes];
                SecAccessControlRef access = SecAccessControlCreateWithFlags(NULL, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, kSecAccessControlUserPresence, NULL);
                if (access != NULL) {
                    OSStatus err = SecItemAdd((__bridge CFDictionaryRef)@{
                        kAGSecKeyCommon
                        (__bridge id)kSecAttrAccessControl: (__bridge id)access,
                        (__bridge id)kSecUseAuthenticationContext: context,
                        (__bridge id)kSecValueData: data,
                    }, NULL);
                    if (err == errSecSuccess) {
                        hasLocker = YES;
                    }
                    CFRelease(access);
                }
            }
            if (!hasLocker) {
                return;
            }
        }
        _hasLocker = hasLocker;
        [NSUserDefaults.standardUserDefaults setBool:hasLocker forKey:@"hasLocker"];
    }
}

- (BOOL)checkLocker {
    BOOL res = YES;
    if (self.isLocking) {
        res = NO;
        LAContext *context = [LAContext new];
        context.interactionNotAllowed = NO;
        context.touchIDAuthenticationAllowableReuseDuration = 10;
        context.localizedReason = @"Use password to unlock".localized;
        if (findSecItem(context) == errSecSuccess) {
            self.lastUpdate = time(NULL);
            res = YES;
        }
    }
    return res;
}

- (BOOL)isLocking {
    return (self.hasLocker && self.lastUpdate < time(NULL) - 10);
}

#pragma mark - Private Methods
- (BOOL)isKeyExist {
    LAContext *context = [LAContext new];
    context.interactionNotAllowed = YES;
    OSStatus err = findSecItem(context);
    return (err == errSecSuccess || err == errSecInteractionNotAllowed);
}

static inline OSStatus findSecItem(LAContext *context) {
    return SecItemCopyMatching((__bridge CFDictionaryRef)@{
        kAGSecKeyCommon
        (__bridge id)kSecUseAuthenticationContext: context,
        (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne,
        (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanFalse,
        (__bridge id)kSecReturnData: (__bridge id)kCFBooleanFalse,
    }, NULL);
}


@end
