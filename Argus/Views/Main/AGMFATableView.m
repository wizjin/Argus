//
//  AGMFATableView.m
//  Argus
//
//  Created by WizJin on 2020/12/1.
//

#import "AGMFATableView.h"
#import "AGMFATableViewCell.h"
#import "AGTheme.h"

@interface AGMFATableView ()

@property (nonatomic, nullable, strong) UIView *emptyView;

@end

@implementation AGMFATableView

- (instancetype)init {
    if (self = [super initWithFrame:CGRectZero style:UITableViewStylePlain]) {
        self.backgroundColor = AGTheme.shared.groupedBackgroundColor;
        self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, kAGMFACellMargin)];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.showsHorizontalScrollIndicator = NO;
        self.rowHeight = kAGMFACellHeight + kAGMFACellMargin;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *subview in self.subviews) {
        if ([NSStringFromClass(subview.class) isEqualToString:@"_UITableViewCellSwipeContainerView"]) {
            UIView *button = [subview findWithClassName:@"UISwipeActionPullView"];
            if (button != nil) {
                NSIndexPath *indexPath = [button valueForKeyPath:@"_delegate._indexPath"];
                if (indexPath != nil) {
                    AGMFATableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
                    if (cell != nil) {
                        CGRect frame = button.frame;
                        frame.size.height = kAGMFACellHeight;
                        button.frame = frame;
                    }
                }
            }
        }
    }
}

- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [super deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self updateDataUI];
}

- (void)reloadData {
    [super reloadData];
    [self updateDataUI];
}

#pragma mark - Private Methods
- (void)updateDataUI {
    if ([self numberOfRowsInSection:0] > 0) {
        if (_emptyView != nil) {
            [_emptyView removeFromSuperview];
            _emptyView = nil;
        }
    } else {
        if (_emptyView == nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([self.delegate respondsToSelector:@selector(tableViewEmptyView:)]) {
                UIView *emptyView = [self.delegate performSelector:@selector(tableViewEmptyView:) withObject:self];
                if (emptyView != nil) {
                    [emptyView removeFromSuperview];
                    [self.superview addSubview:(_emptyView = emptyView)];
                    [emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.edges.equalTo(self);
                    }];
                }
            }
#pragma clang diagnostic pop
        }
    }
}


@end
