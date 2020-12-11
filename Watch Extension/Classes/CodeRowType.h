//
//  CodeRowType.h
//  Watch Extension
//
//  Created by WizJin on 2020/12/11.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "AGMFAModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CodeRowType : NSObject

@property (nonatomic, weak) AGMFAModel *model;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *codeLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *accountLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *timerLabel;

- (void)update:(time_t)now;


@end

NS_ASSUME_NONNULL_END
