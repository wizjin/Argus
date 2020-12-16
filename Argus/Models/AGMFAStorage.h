//
//  AGMFAStorage.h
//  Argus
//
//  Created by WizJin on 2020/12/12.
//

#import <Foundation/Foundation.h>
#import "AGFile.h"
#import "AGMFAModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AGMFAStorage : AGFile

- (instancetype)initWithURL:(NSURL *)url;
- (BOOL)containsItem:(AGMFAModel *)item;
- (void)removeItem:(AGMFAModel *)item;
- (void)addItem:(AGMFAModel *)item;
- (AGMFAModel *)itemAtIndex:(NSInteger)index;
- (NSUInteger)count;
- (BOOL)load;
- (BOOL)save;
- (BOOL)saveData:(NSData *)data;


@end

NS_ASSUME_NONNULL_END
