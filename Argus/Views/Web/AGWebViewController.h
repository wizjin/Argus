//
//  AGWebViewController.h
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import "AGViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AGWebViewController : AGViewController

@property (nonatomic, readonly, strong) NSURL *url;

- (instancetype)initWithURL:(NSURL *)url withParams:(NSDictionary<NSString *, id> *)params;


@end

NS_ASSUME_NONNULL_END
