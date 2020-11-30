//
//  AGMFAModel.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGMFAModel.h"
#import <CommonCrypto/CommonHMAC.h>

@interface AGMFAModel () {
@private
    uint64_t digits;
    size_t hashlen;
    CCHmacAlgorithm algorithm;
}

@property (nonatomic, readonly, strong) NSData *secret;

@end

@implementation AGMFAModel

+ (instancetype)modelWithURL:(NSURL *)url {
    NSURLComponents *componemts = [NSURLComponents componentsWithString:url.absoluteString];
    if ([componemts.scheme isEqualToString:@"otpauth"] && [componemts.host isEqualToString:@"totp"]) {
        return [[self.class alloc] initWithURLComponents:componemts];
    }
    return nil;
}

- (instancetype)initWithURLComponents:(NSURLComponents *)componemts {
    if (self = [super init]) {
        // Note: https://github.com/google/google-authenticator/wiki/Key-Uri-Format
        digits = 6;
        _period = 0;
        hashlen = CC_SHA1_DIGEST_LENGTH;
        algorithm = kCCHmacAlgSHA1;
        _title = @"";
        _detail = @"";
        if (componemts.path.length > 1) {
            NSString *path = [componemts.path substringFromIndex:1];
            NSRange range = [path rangeOfString:@":" options:0];
            if (range.location == NSNotFound) {
                _detail = path;
            } else {
                _title = [path substringToIndex:range.location].trim;
                if (range.location + 1 < path.length) {
                    _detail = [path substringFromIndex:range.location + 1].trim;
                }
            }
        }
        for (NSURLQueryItem *item in componemts.queryItems) {
            if ([item.name isEqualToString:@"issuer"]) {
                _title = item.value;
            } else if ([item.name isEqualToString:@"secret"]) {
                _secret = [NSData dataWithBase32EncodedString:item.value];
            } else if ([item.name isEqualToString:@"period"]) {
                _period = [item.value intValue];
            } else if ([item.name isEqualToString:@"digits"]) {
                digits = [item.value integerValue];
            } else if ([item.name isEqualToString:@"algorithm"]) {
                if ([item.value caseInsensitiveCompare:@"SHA1"] == NSOrderedSame) {
                    hashlen = CC_SHA1_DIGEST_LENGTH;
                    algorithm = kCCHmacAlgSHA1;
                } else if ([item.value caseInsensitiveCompare:@"SHA224"] == NSOrderedSame) {
                    hashlen = CC_SHA224_DIGEST_LENGTH;
                    algorithm = kCCHmacAlgSHA224;
                } else if ([item.value caseInsensitiveCompare:@"SHA256"] == NSOrderedSame) {
                    hashlen = CC_SHA256_DIGEST_LENGTH;
                    algorithm = kCCHmacAlgSHA256;
                } else if ([item.value caseInsensitiveCompare:@"SHA384"] == NSOrderedSame) {
                    hashlen = CC_SHA384_DIGEST_LENGTH;
                    algorithm = kCCHmacAlgSHA384;
                } else if ([item.value caseInsensitiveCompare:@"SHA512"] == NSOrderedSame) {
                    hashlen = CC_SHA512_DIGEST_LENGTH;
                    algorithm = kCCHmacAlgSHA512;
                }
            }
        }
        if (_secret == nil) _secret = [NSData new];
        if (_period <= 0) _period = 30;
        if (digits <= 0 || digits > 8) digits = 6;
    }
    return self;
}

- (uint64_t)calcT:(time_t)now remainder:(uint64_t *)remainder {
    uint64_t t = floor((double)now/self.period);
    if (remainder != NULL) *remainder = (t + 1) * self.period - now;
    return t;
}

- (NSString *)calcCode:(uint64_t)t {
    uint8_t hmac[128];
    assert(hashlen <= sizeof(hmac));
    t = CFSwapInt64BigToHost(t);
    CCHmac(algorithm, self.secret.bytes, self.secret.length, &t, sizeof(t), hmac);
    uint8_t offset = hmac[hashlen - 1] & 0x0f;
    int64_t value = ((hmac[offset] & 0x7f) << 24)
                    | ((hmac[offset+1] & 0xff) << 16)
                    | ((hmac[offset+2] & 0xff) << 8)
                    | (hmac[offset+3] & 0xff);
    char *res = malloc(digits * sizeof(char));
    if (res != NULL) {
        for (int i = 0; i < digits; i++) {
            res[digits-i-1] = value%10 + '0';
            value /= 10;
        }
        return [[NSString alloc] initWithBytes:res length:digits encoding:NSASCIIStringEncoding];
    }
    return @"";
}


@end
