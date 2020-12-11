//
//  CodeRowType.m
//  Watch Extension
//
//  Created by WizJin on 2020/12/11.
//

#import "CodeRowType.h"

@interface CodeRowType ()

@property (nonatomic, readonly, assign) uint64_t lastT;

@end

@implementation CodeRowType

+ (UIColor *)tinColor {
    static UIColor *color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorNamed:@"AccentColor"];
    });
    return color;
}

- (void)setModel:(AGMFAModel *)model {
    if (_model != model) {
        _model = model;
        
        _lastT = 0;
        [self.titleLabel setText:model.title];
        [self.accountLabel setText:model.detail];
        [self.timerLabel setText:@""];
        [self.codeLabel setText:@"--- ---"];
        [self.codeLabel setTextColor:CodeRowType.tinColor];
    }
}

- (void)update:(time_t)now {
    uint64_t r = 0;
    uint64_t t = [self.model calcT:now remainder:&r];
    if (self.lastT != t) {
        _lastT = t;
        [self.codeLabel setText:[self.model calcCode:t].formatSpace];
    }
    if (self.model.period > 0 && r <= 5) {
        [self.codeLabel setTextColor:UIColor.redColor];
    } else {
        [self.codeLabel setTextColor:CodeRowType.tinColor];
    }
    [self.timerLabel setText:[@(r) stringValue]];
}


@end
