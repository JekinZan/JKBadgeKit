//
//  JKBageManger.m
//  JKBageKit
//
//  Created by zhangjie on 2017/3/27.
//  Copyright © 2018年 zhangjie. All rights reserved.
//

#import "JKBadgeManager.h"
#import <pthread.h>
#import "JKBadgeModel.h"
#import "NSString+JKBadge.h"
#ifndef dispatch_queue_async_jkbk
#define dispatch_queue_async_jkbk(queue, block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) { \
block(); \
} else { \
dispatch_async(queue, block); \
}
#endif

#ifndef dispatch_main_async_jkbk
#define dispatch_main_async_jkbk(block) dispatch_queue_async_jkbk(dispatch_get_main_queue(), block)
#endif
NS_ASSUME_NONNULL_BEGIN
@implementation JKBadgeManager {
    NSMutableDictionary<NSString *, NSMutableSet<JKBadgeInfo *> *> *_objectInfosMap;
    JKBadgeModel *_root;
    dispatch_queue_t _badgeQueue;
}
#pragma mark initialize
- (void)dealloc {
   
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}
- (instancetype)init {
    if (self = [super init]) {
        _objectInfosMap = [[NSMutableDictionary alloc] initWithCapacity:0];
        _badgeQueue = dispatch_queue_create("com.badge.JKBadgeKit.queue", DISPATCH_QUEUE_CONCURRENT);
        [self jk_setupRootBadge];
    }
    return self;
}

#pragma mark privatemethod
- (void)jk_setupRootBadge {
    NSString     *badgeFile    = [NSString badgeJSONPath];
    NSDictionary *badgeFileDic = [NSDictionary dictionaryWithContentsOfFile:badgeFile];
    NSDictionary *badgeDic     = badgeFileDic ? : @{JKBadgeNameKey : @"root",
                                                    JKBadgePathKey : @"root",
                                                    JKBadgeCountKey: @(0),
                                                    JKBadgeShowKey : @(YES)};
    _root = [JKBadgeModel initWithDictionary:badgeDic];
    
    if (!badgeFileDic) [self jk_saveBadgeInfo];
}


#pragma mark publicMethod
- (BOOL)statusForKeyPath:(NSString *)keyPath {
    return [[self jk_badgeForKeyPath:keyPath] needShow];
}
- (NSUInteger)countForKeyPath:(NSString *)keyPath{
    id<JKBadge> badge = [self jk_badgeForKeyPath:keyPath];
    return badge ? badge.count : 0;
}
- (void)refreshBadgeWithInfos:(NSHashTable<JKBadgeInfo *> *)infos{
    if (0 == infos.count) return;
    for (JKBadgeInfo *bInfo in infos) {
        id<JKBadge> badge         = [self jk_badgeForKeyPath:bInfo.keyPath];
        id<JKBadgeView> badgeView = bInfo.badgeView;
        if (badgeView && [badgeView conformsToProtocol:@protocol(JKBadgeView)]) {
            NSUInteger c = badge.count;
            dispatch_main_async_jkbk(^{
                if (c > 0) {
                    [badgeView showBadgeWithValue:c];
                } else if (badge.needShow) {
                    [badgeView showBadge];
                } else {
                    [badgeView hideBadge];
                }
            });
        }
    }
}
- (void)unObserveWithInfos:(nullable NSHashTable<JKBadgeInfo *> *)infos{
    if (0 == infos.count) return;
    
    for (JKBadgeInfo *info in infos) {
        [self unObserveWithInfo:info];
    }
}
- (void)unObserveWithInfo:(nullable JKBadgeInfo *)info {
    if (!info)return;
    id<JKBadgeView> badgeView;
    @synchronized(self){
        NSString *keyPath = info.keyPath;
        
        // get observation infos
        NSMutableSet *infos = [_objectInfosMap objectForKey:keyPath];
        // lookup registered info instance
        JKBadgeInfo *registeredInfo = [infos member:info];
        badgeView  = registeredInfo.badgeView;
        if (nil != registeredInfo) {
            [infos removeObject:registeredInfo];
            
            // remove no longer used infos
            if (0 == infos.count) {
                [_objectInfosMap removeObjectForKey:keyPath];
            }
        }
    }
    if (badgeView && [badgeView conformsToProtocol:@protocol(JKBadgeView)]) {
        dispatch_main_async_jkbk(^{ [badgeView hideBadge]; });
    }
}

- (void)addObserveWithInfo:(nullable JKBadgeInfo *)info {
    if (!info)return;
    NSString *keyPath = info.keyPath;
    @synchronized(self){
        NSMutableSet *infos = [_objectInfosMap objectForKey:keyPath];
        if (!infos) {
            infos = [NSMutableSet set];
            [_objectInfosMap setObject:infos forKey:keyPath];
        }
        [infos addObject:info];
    }
    
    id<JKBadge> badge = [self jk_badgeForKeyPath:keyPath];
    if (badge && [badge needShow]) {
        [self jk_statusChangeForBadges:@[badge]];
    }
}
- (void)clearBadgeForKeyPath:(NSString *)keyPath {
    [self clearBadgeForKeyPath:keyPath forced:NO];
}
- (void)clearBadgeForKeyPath:(NSString *)keyPath forced:(BOOL)forced{
    if (!keyPath) return;
    NSArray *keyPathArray        = [keyPath componentsSeparatedByString:@"."];
    NSMutableArray *notifyBadges = [NSMutableArray array];    
    @synchronized(self){
        id<JKBadge> bParent   = _root;
        for (NSString *name in keyPathArray) {
            if ([name isEqualToString:@"root"]) continue;
            id<JKBadge> objFind = nil;
            for (id<JKBadge> obj in bParent.children) {
                if ([obj.name isEqualToString:name]) {
                    objFind = obj;
                    bParent = objFind;
                    break;
                }
            }
            if (!objFind)return;
            if ([name isEqualToString:[keyPathArray lastObject]]) {
                objFind.needShow = NO;
                if ([objFind.children count] == 0 || forced) {
                    if ([objFind.children count]  && forced) {
                        NSArray *bs = [objFind.allLinkChildren mutableCopy];
                        [notifyBadges addObjectsFromArray:bs];
                        [objFind clearAllChildren];
                    }
                    objFind.count = 0;
                    [objFind removeFromParent];
                }
                [self jk_saveBadgeInfo];
            }
            [notifyBadges addObject:objFind];
        }
    }
    [self  jk_statusChangeForBadges:[notifyBadges mutableCopy]];
}
- (void)setBadgeForKeyPath:(NSString *)keyPath {
    [self setBadgeForKeyPath:keyPath count:0];
}
- (void)setBadgeForKeyPath:(NSString *)keyPath count:(NSUInteger)count{
    if (!keyPath) return;
    NSArray *keyPathArray        = [keyPath componentsSeparatedByString:@"."];
    NSMutableArray *notifyBadges = [NSMutableArray array];
    @synchronized(self){
        id<JKBadge> bParent = _root;
        for (NSString *name in keyPathArray) {
            if ([name isEqualToString:@"root"]) continue;
            id<JKBadge> objFind = nil;
            for (id<JKBadge> obj in bParent.children) {
                if ([obj.name isEqualToString:name]) {
                    objFind = obj; break;
                }
            }
            NSString *namePath   = [NSString stringWithFormat:@".%@",name];
            NSString *subKeyPath = [bParent.keyPath stringByAppendingString:namePath];
            if (!objFind) {
                BOOL set = ([name isEqualToString:[keyPathArray lastObject]]);
                objFind  = [JKBadgeModel initWithDictionary:@{JKBadgeNameKey : name,
                                                              JKBadgePathKey : subKeyPath,
                                                              JKBadgeCountKey: @(0),
                                                              JKBadgeShowKey : @(set)}];
                objFind.parent   = bParent;
                [bParent addChild:objFind];
            }
            bParent              = objFind;
            if ([subKeyPath isEqualToString:keyPath]) {
                objFind.needShow = YES;
                objFind.count    = count;
            }
            [notifyBadges addObject:objFind];
        }
        [self jk_saveBadgeInfo];
    }

    [self jk_statusChangeForBadges:[notifyBadges mutableCopy]];
}


#pragma mark PRIVATEMETHOD
- (void)jk_saveBadgeInfo {
    [[_root dictionaryFormat] writeToFile:[NSString badgeJSONPath]
                               atomically:YES];
}
- (void)jk_statusChangeForBadges:(NSArray<id<JKBadge>> *)badges{
    if (![badges count]) return;
    
    for (id<JKBadge> badge in badges) {
        NSString *path = badge.keyPath;
        if ([path isEqualToString:JKBadgeRootPath]) continue;
        NSMutableSet *infos;
        @synchronized(self){
           infos = [[_objectInfosMap objectForKey:path] copy];
             NSLog(@"info1%@",infos);
        }
        NSLog(@"info2%@",infos);
        [infos enumerateObjectsUsingBlock:^(JKBadgeInfo *bInfo, BOOL * _Nonnull stop) {
            id<JKBadgeView> badgeView = bInfo.badgeView;
            if (badgeView && [badgeView conformsToProtocol:@protocol(JKBadgeView)]) {
                NSUInteger c = badge.count;
                dispatch_main_async_jkbk(^{
                    if (c > 0) {
                        [badgeView showBadgeWithValue:c];
                    } else if (badge.needShow) {
                        [badgeView showBadge];
                    } else {
                        [badgeView hideBadge];
                    }
                });
            }
            if (bInfo.block) {
                id observer = bInfo.controller.observer;
                bInfo.block(observer, @{ JKBadgePathKey :   badge.keyPath,
                                         JKBadgeShowKey : @(badge.needShow),
                                         JKBadgeCountKey: @(badge.count) });
            }
        }];
    }
}
- (id<JKBadge>)jk_badgeForKeyPath:(NSString *)keyPath{
    NSArray *kPaths   = [keyPath componentsSeparatedByString:@"."];
    id<JKBadge> badge = nil;
    @synchronized(self){
        id<JKBadge> bParent = _root;
        for (NSString *name in kPaths) {
            if ([name isEqualToString:JKBadgeRootPath]) {
                continue;
            }
            id<JKBadge> objFind = nil;
            for (id<JKBadge> obj in bParent.children) {
                if ([obj.name isEqualToString:name]) {
                    objFind = obj; bParent = objFind;
                    break;
                }
            }
            
            if (!objFind)return nil;
            badge = objFind;
        }
    }
    return badge;
}
@end
NS_ASSUME_NONNULL_END
