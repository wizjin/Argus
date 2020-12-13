//
//  CodeRowType.m
//  Watch Extension
//
//  Created by WizJin on 2020/12/11.
//

#import "CodeRowType.h"
#import "Theme.h"

@interface CodeRowType ()

@property (nonatomic, readonly, assign) uint64_t lastT;

@end

@implementation CodeRowType

- (void)setModel:(AGMFAModel *)model {
    if (_model != model) {
        _model = model;
        
        _lastT = 0;
        [self.titleLabel setText:model.title];
        [self.accountLabel setText:model.detail];
        [self.timerLabel setText:@""];
        [self.codeLabel setText:@"--- ---"];
        [self.codeLabel setTextColor:Theme.tintColor];
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
        [self.codeLabel setTextColor:Theme.tintColor];
    }
    [self.timerLabel setText:[@(r) stringValue]];
}


@end
