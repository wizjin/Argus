//
//  NSURL+AGExt.m
//  Argus
//
//  Created by WizJin on 2020/12/16.
//

#import "NSURL+AGExt.h"

@implementation NSURL (AGExt)

- (nullable NSDate *)modificationDate {
    NSDate *date = nil;
    if (self.isFileURL) {
        NSError *error = nil;
        [self getResourceValue:&date forKey:NSURLContentModificationDateKey error:&error];
        if (error != nil) {
            date = nil;
        }
    }
    return date;
}


@end
