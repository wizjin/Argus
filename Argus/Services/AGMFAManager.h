//
//  AGMFAManager.h
//  Argus
//
//  Created by WizJin on 2020/11/30.
//

#import <Foundation/Foundation.h>
#import "AGMFAModel.h"
#import "AGMFAModel+GPB.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AGMFAManagerDelegate <NSObject>
@optional
- (void)mfaUpdated;
- (void)watchStatusChanged;
@end

@interface AGMFAManager : NSObject

@property (nonatomic, readonly, assign) BOOL iCloudSyncEnabled;

+ (instancetype)shared;
- (void)addDelegate:(id<AGMFAManagerDelegate>)delegate;
- (void)removeDelegate:(id<AGMFAManagerDelegate>)delegate;
- (BOOL)canOpenURL:(NSURL *)url;
- (BOOL)openURL:(NSURL *)url;
- (AGMFAModel *)itemAtIndex:(NSInteger)index;
- (NSUInteger)itemCount;
- (void)deleteItem:(AGMFAModel *)item completion:(void (^ __nullable)(void))completion;
- (NSArray<NSString *> *)createExportURL:(NSArray<AGMFAModel *> *)models;
- (void)copyToPasteboard:(nullable AGMFAModel *)item;
- (void)active;
- (void)deactive;
- (BOOL)iCloudEnabled;
- (void)setICloudSyncEnabled:(BOOL)iCloudSyncEnabled cleanup:(BOOL)cleanup;
- (BOOL)hasWatch;
- (BOOL)isWatchAppInstalled;
- (BOOL)syncWatch:(BOOL)focus;


@end

NS_ASSUME_NONNULL_END
