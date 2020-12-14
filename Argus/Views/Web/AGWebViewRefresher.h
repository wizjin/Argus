//
//  AGWebViewRefresher.h
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGWebViewRefresher : UIRefreshControl

@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) BOOL hasOnlySecureContent;


@end

NS_ASSUME_NONNULL_END
