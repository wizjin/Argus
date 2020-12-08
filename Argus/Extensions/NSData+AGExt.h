//
//  NSData+AGExt.h
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import <Foundation/NSData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (AGExt)

+ (nullable instancetype)dataWithBase32EncodedString:(NSString *)base32String;
- (NSString *)base32EncodedString;
- (NSData *)compress;
- (NSData *)decompress;


@end

NS_ASSUME_NONNULL_END
