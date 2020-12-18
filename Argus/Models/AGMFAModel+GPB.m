//
//  AGMFAModel+GPB.m
//  Argus
//
//  Created by WizJin on 2020/12/18.
//

#import "AGMFAModel+GPB.h"
#import "AGModel.pbobjc.h"

@implementation AGMFAModel (GPB)

+ (nullable NSString *)URLWithParams:(AGMOtpParameters *)params {
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

- (BOOL)calcCanExportPB {
    switch (self.algorithm) {
        default: return NO;
        case kCCHmacAlgSHA1:
        case kCCHmacAlgSHA256:
        case kCCHmacAlgSHA512:
        case kCCHmacAlgMD5: break;
    }
    switch (self.digits) {
        default: return NO;
        case 6: case 8: break;
    }
    if (self.period != 30) {
        return NO;
    }
    return YES;
}

- (AGMOtpParameters *)pbParams {
    AGMOtpParameters *item = nil;
    if (self.canExportPB) {
        item = [AGMOtpParameters new];
        item.type = AGMOtpType_OtpTypeTotp;
        item.issuer = self.title;
        item.name = self.detail;
        item.secret = self.secret;
        switch (self.algorithm) {
            case kCCHmacAlgSHA1: item.algorithm = AGMAlgorithm_AlgorithmSha1; break;
            case kCCHmacAlgSHA256: item.algorithm = AGMAlgorithm_AlgorithmSha256; break;
            case kCCHmacAlgSHA512: item.algorithm = AGMAlgorithm_AlgorithmSha512; break;
            case kCCHmacAlgMD5: item.algorithm = AGMAlgorithm_AlgorithmMd5; break;
        }
        switch (self.digits) {
            case 6: item.digits = AGMDigitCount_DigitCountSix; break;
            case 8: item.digits = AGMDigitCount_DigitCountEight; break;
        }
    }
    return item;
}


@end
