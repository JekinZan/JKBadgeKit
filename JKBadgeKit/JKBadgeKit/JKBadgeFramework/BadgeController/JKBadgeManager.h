//
//  JKBageManger.h
//  JKBageKit
//
//  Created by zhangjie on 2017/3/27.
//  Copyright © 2018年 zhangjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKBadgeInfo.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const JKBadgeRootPath;
extern NSString * const JKBadgeNameKey;

@interface JKBadgeManager : NSObject
+ (instancetype _Nonnull)sharedInstance;
//addObserve
- (void)addObserveWithInfo:(nullable JKBadgeInfo *)info;

//unObserve
- (void)unObserveWithInfo:(nullable JKBadgeInfo *)info;
- (void)unObserveWithInfos:(nullable NSHashTable<JKBadgeInfo *>*)infos;

//Operation
- (void)refreshBadgeWithInfos:(NSHashTable<JKBadgeInfo *>*)infos;
- (void)setBadgeForKeyPath:(NSString *)keyPath;
- (void)setBadgeForKeyPath:(NSString *)keyPath count:(NSUInteger)count;
- (void)clearBadgeForKeyPath:(NSString *)keyPath;
- (void)clearBadgeForKeyPath:(NSString *)keyPath forced:(BOOL)forced;
- (BOOL)statusForKeyPath:(NSString *)keyPath;
- (NSUInteger)countForKeyPath:(NSString *)keyPath;
NS_ASSUME_NONNULL_END
@end
