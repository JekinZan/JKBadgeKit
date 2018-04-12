//
//  JKBadgeController.m
//  JKBageKit
//
//  Created by zhangjie on 2017/3/27.
//  Copyright © 2018年 zhangjie. All rights reserved.
//

#import "JKBadgeController.h"
#import "JKBadgeInfo.h"
#import <pthread.h>
#import "JKBadgeManager.h"
@implementation JKBadgeController {
    NSHashTable<JKBadgeInfo *> *_infos;
    pthread_mutex_t _lock;
}
- (void)dealloc {
    [self unobserveAll];
    pthread_mutex_destroy(&_lock);
}
- (instancetype)initWithObserver:(id)observer {
    if (self = [super init]) {
        _observer = observer;
        _infos = [[NSHashTable alloc]initWithOptions:NSPointerFunctionsStrongMemory |
        NSPointerFunctionsObjectPersonality
    capacity:0];
        pthread_mutex_init(&_lock, nil);
    }
    return self;
}
+ (instancetype)controllerWithObserver:(nullable id)observer {
    return [[self alloc] initWithObserver:observer];
}
#pragma mark privatemethod
- (void)jk_observeWithInfo:(JKBadgeInfo *)info {
    pthread_mutex_lock(&_lock);
    //comparison type has been set.
    JKBadgeInfo *existingInfo = [_infos member:info];
    if (existingInfo) {
        pthread_mutex_unlock(&_lock);
        return;
    }
    [_infos addObject:info];
    pthread_mutex_unlock(&_lock);
    //addObser
    [[JKBadgeManager sharedInstance]addObserveWithInfo:info];
}
- (void)jk_unobserveWithInfo:(JKBadgeInfo *)info {
    pthread_mutex_lock(&_lock);
    JKBadgeInfo *registeredInfo = [_infos member:info];
    if (registeredInfo)[_infos removeObject:registeredInfo];
    pthread_mutex_unlock(&_lock);
    [[JKBadgeManager sharedInstance]unObserveWithInfo:info];
}
- (void)jk_unobserveAll {
   pthread_mutex_lock(&_lock);
    [[JKBadgeManager sharedInstance]unObserveWithInfos:_infos];
    [_infos removeAllObjects];
    pthread_mutex_unlock(&_lock);
}

- (NSString *)debugDescription {
    NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p", NSStringFromClass([self class]), self];
    [s appendFormat:@" observer:<%@:%p>", NSStringFromClass([_observer class]), _observer];
    
    pthread_mutex_lock(&_lock);
    
    if (0 != _infos.count) {
        [s appendString:@"\n  "];
    }
    
    NSMutableArray *infoDescriptions = [NSMutableArray arrayWithCapacity:_infos.count];
    
    for (JKBadgeInfo *info in _infos) {
        [infoDescriptions addObject:info.debugDescription];
    }
    
    [s appendFormat:@"-> %@", infoDescriptions];
    
    pthread_mutex_unlock(&_lock);
    
    [s appendString:@">"];
    
    return s;
}
#pragma mark observe
- (void)observePath:(NSString *)keyPath block:(JKBadgeNotificationBlock)block {
    if (keyPath.length == 0||!block) {
#ifdef DEBUG
        NSAssert(NO, @"missing required parameters: keyPath:%@ block:%p", keyPath, block);
#endif
        return;
    }
    JKBadgeInfo *info = [[JKBadgeInfo alloc]initWithController:self keyPath:keyPath block:block];
    [self jk_observeWithInfo:info];
    
}
- (void)observePath:(NSString *)keyPath badgeView:(nullable id<JKBadgeView  >)badgeView block:(nullable JKBadgeNotificationBlock)block{
    
    if (keyPath.length == 0) {
#ifdef DEBUG
        NSAssert(NO, @"missing required parameters: keyPath:%@ block:%p", keyPath, block);
#endif
        return;
    }
    JKBadgeInfo *info = [[JKBadgeInfo alloc] initWithController:self keyPath:keyPath badgeView:badgeView block:block];
    
    // observe object with info
    [self jk_observeWithInfo:info];
}

- (void)observePaths:(NSArray<NSString *> *)keyPaths block:(JKBadgeNotificationBlock)block{
    if (keyPaths.count == 0||!block) {
#ifdef DEBUG
        NSAssert(NO, @"missing required parameters: keyPath:%@ block:%p", keyPaths, block);
#endif
        return;
    }
    
    for (NSString *keyPath in keyPaths) {
        [self observePath:keyPath block:block];
    }
}

#pragma mark - Unobserve
- (void)unobservePath:(NSString *)keyPath{
    // create representative info
    JKBadgeInfo *info = [[JKBadgeInfo alloc] initWithController:self keyPath:keyPath];
    [self jk_unobserveWithInfo:info];
}

- (void)unobserveAll {
    [self jk_unobserveAll];
}
#pragma mark Operation
+ (void)setBadgeForKeyPath:(NSString *)keyPath {
    if (!keyPath.length)return;
     [[JKBadgeManager sharedInstance]setBadgeForKeyPath:keyPath];
}
+ (void)setBadgeForKeyPath:(NSString *)keyPath count:(NSUInteger)count{
    if (!keyPath.length)return;
    [[JKBadgeManager sharedInstance]setBadgeForKeyPath:keyPath count:count];
}
+ (void)clearBadgeForKeyPath:(NSString *)keyPath{
    if (!keyPath.length)return;
    [self clearBadgeForKeyPath:keyPath forced:NO];
}
+ (void)clearBadgeForKeyPath:(NSString *)keyPath forced:(BOOL)forced{
    if (!keyPath.length)return;
    [[JKBadgeManager sharedInstance]clearBadgeForKeyPath:keyPath forced:forced];
}
+ (BOOL)statusForKeyPath:(NSString *)keyPath{
    if (!keyPath.length)return NO;
    return [[JKBadgeManager sharedInstance]statusForKeyPath:keyPath];
}
- (void)refreshBadgeView{
    [[JKBadgeManager sharedInstance]refreshBadgeWithInfos:_infos];
}
+ (NSUInteger)countForKeyPath:(NSString *)keyPath{
    if (!keyPath.length)return 0;
    return [[JKBadgeManager sharedInstance]countForKeyPath:keyPath];
}
@end
