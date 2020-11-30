//
//  NSString+AGExt.h
//  Argus
//
//  Created by WizJin on 2020/11/29.
//

#import <Foundation/NSString.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (AGExt)

- (NSString *)localized;
- (NSString *)code;
- (NSString *)trim;


@end

NS_ASSUME_NONNULL_END
