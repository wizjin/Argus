//
//  AGMFAModel.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGMFAModel.h"
#import "AGMFAModel+GPB.h"

@interface AGMFAModel () {
@private
    size_t hashlen;
}

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, assign) uint64_t created;
@property (nonatomic, assign) BOOL canExportPB;

@end

@implementation AGMFAModel

+ (instancetype)modelWithData:(NSDictionary *)data {
    uint64_t ts = [[data valueForKey:@"created"] longLongValue];
    if (ts > 0) {
        NSString *url = [data valueForKey:@"url"];
        if (url.length > 0) {
            NSURLComponents *componemts = [NSURLComponents componentsWithString:url];
            if ([componemts.scheme isEqualToString:@"otpauth"] && [componemts.host isEqualToString:@"totp"]) {
                AGMFAModel *model = [[self.class alloc] initWithURLComponents:componemts];
                if (model != nil) {
                    model.created = ts;
                    model.data = data;
                    return model;
                }
            }
        }
    }
    return nil;
}

- (instancetype)initWithURLComponents:(NSURLComponents *)componemts {
    if (self = [super init]) {
        _created = 0;

        // Note: https://github.com/google/google-authenticator/wiki/Key-Uri-Format
        _digits = 6;
        _period = 0;
        hashlen = CC_SHA1_DIGEST_LENGTH;
        _algorithm = kCCHmacAlgSHA1;
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
                _digits = [item.value integerValue];
            } else if ([item.name isEqualToString:@"algorithm"]) {
                if ([item.value caseInsensitiveCompare:@"SHA1"] == NSOrderedSame) {
                    hashlen = CC_SHA1_DIGEST_LENGTH;
                    _algorithm = kCCHmacAlgSHA1;
                } else if ([item.value caseInsensitiveCompare:@"SHA224"] == NSOrderedSame) {
                    hashlen = CC_SHA224_DIGEST_LENGTH;
                    _algorithm = kCCHmacAlgSHA224;
                } else if ([item.value caseInsensitiveCompare:@"SHA256"] == NSOrderedSame) {
                    hashlen = CC_SHA256_DIGEST_LENGTH;
                    _algorithm = kCCHmacAlgSHA256;
                } else if ([item.value caseInsensitiveCompare:@"SHA384"] == NSOrderedSame) {
                    hashlen = CC_SHA384_DIGEST_LENGTH;
                    _algorithm = kCCHmacAlgSHA384;
                } else if ([item.value caseInsensitiveCompare:@"SHA512"] == NSOrderedSame) {
                    hashlen = CC_SHA512_DIGEST_LENGTH;
                    _algorithm = kCCHmacAlgSHA512;
                } else if ([item.value caseInsensitiveCompare:@"MD5"] == NSOrderedSame) {
                    hashlen = CC_MD5_DIGEST_LENGTH;
                    _algorithm = kCCHmacAlgMD5;
                }
            }
        }
        if (_secret == nil) _secret = [NSData new];
        if (_period <= 0) _period = 30;
        if (_digits <= 0 || _digits > 8) _digits = 6;
        
        if ([self respondsToSelector:@selector(calcCanExportPB)]) {
            _canExportPB = [self calcCanExportPB];
        } else {
            _canExportPB = NO;
        }
    }
    return self;
}

- (BOOL)isEqual:(AGMFAModel *)other {
    return (self.created == other.created || [self.url isEqual:other.url]
            || ([self.secret isEqualToData:other.secret] && [self.title isEqualToString:other.title] && [self.detail isEqualToString:other.detail] && self.period == other.period));
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
    CCHmac(self.algorithm, self.secret.bytes, self.secret.length, &t, sizeof(t), hmac);
    uint8_t offset = hmac[hashlen - 1] & 0x0f;
    int64_t value = ((hmac[offset] & 0x7f) << 24)
                    | ((hmac[offset+1] & 0xff) << 16)
                    | ((hmac[offset+2] & 0xff) << 8)
                    | (hmac[offset+3] & 0xff);
    unichar *res = malloc((size_t)self.digits * sizeof(unichar));
    if (res != NULL) {
        for (int i = 0; i < self.digits; i++) {
            res[self.digits-i-1] = value%10 + '0';
            value /= 10;
        }
        return [[NSString alloc] initWithCharactersNoCopy:res length:(size_t)self.digits freeWhenDone:YES];
    }
    return @"";
}

- (NSString *)url {
    return [self.data valueForKey:@"url"];
}

@end
