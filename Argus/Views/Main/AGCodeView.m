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
@property (nonatomic, nullable, strong) UIViewPropertyAnimator *animator;

@end

@implementation AGCodeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _lastT = 0;
        _fontSize = 50;
        _animator = nil;
        self.layer.backgroundColor = UIColor.clearColor.CGColor;
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
    [self stopFlashAnimator];
}

- (uint64_t)update:(AGMFAModel *)model now:(time_t)now {
    uint64_t r = 0;
    uint64_t t = [model calcT:now remainder:&r];
    if (self.lastT != t) {
        _lastT = t;
        self.text = format([model calcCode:t]);
    }
    AGTheme *theme = AGTheme.shared;
    if (model.period > 0 && r <= 5) {
        self.textColor = theme.alertColor;
        [self startFlashAnimator];
    } else {
        self.textColor = theme.tintColor;
        [self stopFlashAnimator];
    }
    return r;
}

- (void)startFlashAnimator {
    if (self.animator == nil) {
        self.alpha = 1.0;
        self.animator = [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [UIView setAnimationRepeatCount:MAXFLOAT];
            [UIView setAnimationRepeatAutoreverses:YES];
#pragma clang diagnostic pop
            self.alpha = 0.4;
        } completion:^(UIViewAnimatingPosition finalPosition) {
            [self stopFlashAnimator];
        }];
    }
}

- (void)stopFlashAnimator {
    if (self.animator != nil) {
        if (self.animator.isRunning) {
            [self.animator stopAnimation:YES];
        }
        self.animator = nil;
        self.alpha = 1.0;
    }
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
