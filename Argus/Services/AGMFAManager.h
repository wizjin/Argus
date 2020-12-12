//
//  AGMFAManager.h
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import <Foundation/Foundation.h>
#import "AGMFAModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AGMFAManagerDelegate <NSObject>
- (void)mfaUpdated;
@end

@interface AGMFAManager : NSObject

@property (nonatomic, nullable, weak) id<AGMFAManagerDelegate> delegate;

+ (instancetype)shared;
- (BOOL)canOpenURL:(NSURL *)url;
- (BOOL)openURL:(NSURL *)url;
- (AGMFAModel *)itemAtIndex:(NSInteger)index;
- (NSUInteger)itemCount;
- (void)deleteItem:(AGMFAModel *)item completion:(void (^ __nullable)(void))completion;
- (void)copyToPasteboard:(nullable AGMFAModel *)item;
- (void)active;
- (void)deactive;
- (BOOL)hasWatch;
- (BOOL)isWatchAppInstalled;
- (BOOL)syncWatch;


@end

NS_ASSUME_NONNULL_END
