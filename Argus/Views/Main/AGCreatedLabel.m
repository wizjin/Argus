//
//  AGCreatedLabel.m
//  Argus
//
//  Created by WizJin on 2020/12/8.
//

#import "AGCreatedLabel.h"
#import "AGTheme.h"

@implementation AGCreatedLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _created = 0;
        self.font = [UIFont systemFontOfSize:10];
        self.textColor = AGTheme.shared.minorLabelColor;
    }
    return self;
}

- (void)setCreated:(uint64_t)created {
    if (_created != created) {
        _created = created;
        if (created <= 0) {
            self.text = @"";
        } else {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:created/1000];
            NSDateFormatter *dateFormat = [NSDateFormatter new];
            [dateFormat setDateFormat:@"YYYY/MM/dd HH:mm"];
            self.text = [NSString stringWithFormat:@"Created at %@".localized, [dateFormat stringFromDate:date]];
        }
    }
}


@end
