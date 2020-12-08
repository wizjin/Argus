//
//  AGCodeView.m
//  Argus
//
//  Created by WizJin on 2020/12/8.
//

#import "AGCodeView.h"
#import "AGTheme.h"

@interface AGCodeView ()

@property (nonatomic, readonly, assign) uint64_t lastT;

@end

@implementation AGCodeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _lastT = 0;
        _fontSize = 50;
        self.font = [UIFont fontWithName:@"Helvetica Neue" size:self.fontSize];
        self.textColor = AGTheme.shared.tintColor;
    }
    return self;
}

- (void)setFontSize:(CGFloat)fontSize {
    if (_fontSize != fontSize) {
        _fontSize = fontSize;
        self.font = [UIFont fontWithName:@"Helvetica Neue" size:self.fontSize];
    }
}

- (void)reset {
    _lastT = 0;
}

- (uint64_t)update:(AGMFAModel *)model now:(time_t)now {
    uint64_t r = 0;
    uint64_t t = [model calcT:now remainder:&r];
    if (self.lastT != t) {
        _lastT = t;
        self.text = format([model calcCode:t]);
    }
    AGTheme *theme = AGTheme.shared;
    self.textColor = ((model.period > 0 && r <= 5) ? theme.alertColor : theme.tintColor);
    return r;
}

static inline NSString *format(NSString *code) {
    NSMutableString *res = [[NSMutableString alloc] initWithCapacity:code.length + code.length/3];
    for (int i = 0; i < code.length; i++) {
        if (i%3 == 0 && i != 0) {
            [res appendString:@" "];
        }
        unichar c = [code characterAtIndex:i];
        [res appendFormat:@"%C", c];
    }
    return res;
}


@end
