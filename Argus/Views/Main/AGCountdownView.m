//
//  AGCountdownView.m
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGCountdownView.h"
#import "AGTheme.h"

@interface AGCountdownView ()

@property (nonatomic, readonly, assign) CGFloat rate;

@end

@implementation AGCountdownView

- (instancetype)init {
    if (self = [super init]) {
        _rate = 0;
        _tintColor = AGTheme.shared.minorLabelColor;
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

- (void)update:(AGMFAModel *)model remainder:(uint64_t)r {
    CGFloat rate = 0;
    CGFloat period = model.period;
    if (period > 0) {
        rate = (double)r/period;
    }
    if (self.rate != rate) {
        _rate = rate;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    CGRect rc = self.bounds;
    CGFloat redius = MIN(rc.size.width, rc.size.height) * 0.5;
    CGFloat rate = MIN(MAX(self.rate, 0), 1);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, self.tintColor.CGColor);
    CGContextMoveToPoint(ctx, redius, redius);
    CGContextAddLineToPoint(ctx, redius, 0);
    CGContextAddArc(ctx, redius, redius, redius, -M_PI_2, -M_PI_2 - (M_PI * 2) * rate, 1);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
}


@end
