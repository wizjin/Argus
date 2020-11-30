//
//  NSString+AGExt.m
//  Argus
//
//  Created by WizJin on 2020/11/29.
//

#import "NSString+AGExt.h"
#import <Foundation/Foundation.h>

@implementation NSString (AGExt)

- (NSString *)localized {
    return [NSBundle.mainBundle localizedStringForKey:self value:@"" table:nil];
}

- (NSString *)code {
    NSString *name = self;
    NSUInteger length = self.length;
    if (length > 0) {
        unichar *p = malloc(sizeof(unichar) * length);
        if (p != NULL) {
            int n = 0;
            BOOL upper = YES;
            const char *s = self.UTF8String;
            for (int i = 0; i < length; i++) {
                char c = s[i];
                if (c == '_') {
                    upper = YES;
                    continue;
                }
                if (upper) {
                    c = toupper(c);
                    upper = NO;
                }
                p[n++] = c;
            }
            name = [[NSString alloc] initWithCharactersNoCopy:p length:n freeWhenDone:YES];
        }
    }
    return name;
}

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
}


@end
