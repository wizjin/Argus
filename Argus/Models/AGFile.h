//
//  AGFile.h
//  Argus
//
//  Created by WizJin on 2020/12/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGFile : NSObject

@property (nonatomic, readonly, strong) NSURL *pathURL;
@property (nonatomic, readonly, strong) NSString *dataKey;

- (instancetype)initWithURL:(NSURL *)url;
- (BOOL)changed;
- (NSData *)fileData;
- (BOOL)write:(NSData *)data updateStatus:(BOOL)update;


@end

NS_ASSUME_NONNULL_END
