//
//  JKBageModel.m
//  JKBageKit
//
//  Created by zhangjie on 2017/3/27.
//  Copyright © 2018年 zhangjie. All rights reserved.
//

#import "JKBadgeModel.h"
NSString * const JKBadgeRootPath    = @"root";
NSString * const JKBadgeNameKey     = @"JKBadgeNameKey";
NSString * const JKBadgePathKey     = @"JKBadgePathKey";
NSString * const JKBadgeChildrenKey = @"JKBadgeChildrenKey";
NSString * const JKBadgeShowKey     = @"JKBadgeShowKey";
NSString * const JKBadgeCountKey    = @"JKBadgeCountKey";
@interface JKBadgeModel()
@property (nonatomic,strong,readwrite)NSString *name;
@property (nonatomic,strong,readwrite) NSString *keyPath;
@property (strong, nonatomic,readwrite) NSMutableArray<id<JKBadge>> *children;
@end
@implementation JKBadgeModel
@synthesize name = _name,keyPath = _keyPath,count = _count,needShow = _needShow,children = _children,allLinkChildren = _allLinkChildren,parent = _parent;

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        self.name = dic[JKBadgeNameKey];
        self.keyPath  = dic[JKBadgePathKey];
        self.needShow = [dic[JKBadgeShowKey] boolValue];
        self.count    = [dic[JKBadgeCountKey] unsignedIntegerValue];
        self.children = [[NSMutableArray alloc] init];
        NSArray *children = dic[JKBadgeChildrenKey];
        if (children && [children isKindOfClass:NSArray.class]) {
            [children enumerateObjectsUsingBlock:^(NSDictionary *child,
                                                   NSUInteger   idx,
                                                   BOOL         *stop) {
                JKBadgeModel *obj  = [JKBadgeModel initWithDictionary:child];
                if (obj) {obj.parent = self; [self.children addObject:obj];}
            }];
        }
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone {
    JKBadgeModel *model = [[[self class] alloc] init];
    model.name     = self.name;
    model.keyPath  = self.keyPath;
    model.count    = self.count;
    model.needShow = self.needShow;
    model.parent   = self.parent;
    model.children = [self.children mutableCopy];
    return model;
}
- (NSString *)debugDescription{
    NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p keyPath:%@", NSStringFromClass([self class]),
                          self, _keyPath];
    [s appendFormat:@" count:%@", [@(_count) stringValue]];
    [s appendFormat:@" needShow:%@", [@(_needShow) stringValue]];
    
    if (_name) {
        [s appendFormat:@" name:%@", _name];
    }
    if (_parent) {
        [s appendFormat:@" parent.path:%@", _parent.keyPath];
    }
    if ([_children count]) {
        NSMutableArray *subPaths = [NSMutableArray array];
        for (JKBadgeModel *child in _children) {
            [subPaths addObject:child.keyPath];
        }
        [s appendFormat:@" children.path:%@", subPaths];
    }
    [s appendString:@">"];
    
    return s;
}

#pragma mark PROTOCOL
+ (id<JKBadge>)initWithDictionary:(NSDictionary *)dic {
    if (!dic)return nil;
    return [[self alloc]initWithDictionary:dic];
}
- (void)addChild:(id<JKBadge>)child {
    @synchronized(self){
        if (child)[self.children addObject:child];
    };
}
- (void)removeChild:(id<JKBadge>)child {
    @synchronized(self){
        if ([self.children containsObject:child]) {
            [self.children removeObject:child];
            if (!self.children.count) {
                self.needShow = NO;
                self.count = 0;
            }
        }
    };
}
- (void)clearAllChildren {
    @synchronized(self){
        NSArray *children = [self.children copy];
        [self.children removeAllObjects];
        for (id<JKBadge> child in children) {
            child.needShow = NO;
            child.count = 0;
            [child clearAllChildren];
        }
    }
}

- (void)removeFromParent {
    if (_parent) {
        [_parent removeChild:self];
        _parent = nil;
    }
}

- (NSDictionary *)dictionaryFormat {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (_name) dic[JKBadgeNameKey] = _name;
    if (_keyPath)dic[JKBadgePathKey] = _keyPath;
    if (_count)dic[JKBadgeCountKey] = @(_count);
    if (_needShow)dic[JKBadgeShowKey]  = @(_needShow);
    if (self.children.count) {
        NSMutableArray *children = [NSMutableArray new];
        dic[JKBadgeChildrenKey] = children;
        [self.children enumerateObjectsUsingBlock:^(id<JKBadge> obj,
                                                    NSUInteger  idx,
                                                    BOOL       *stop) {
            [children addObject:[obj dictionaryFormat]];
        }];
    }
    return dic;
}

#pragma mark SET/GET
- (BOOL)needShow {
    if (self.children.count) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"needShow == 1"];
        NSArray *array = [self.children filteredArrayUsingPredicate:predicate];
        return array.count;
    }
    return _needShow;
}

- (NSUInteger)count {
    if (self.children.count) {
       __block int i = 0;
        dispatch_apply(self.children.count, dispatch_get_global_queue(0, 0), ^(size_t index) {
            i++;
        });
        _count = i;
    }
    return _count;
}

- (NSMutableArray<id<JKBadge>> *)allLinkChildren {
    NSMutableArray *links = self.children.mutableCopy;
    if (self.children.count) {
    [self.children enumerateObjectsUsingBlock:^(id<JKBadge> obj,
                                                    NSUInteger  idx,
                                                    BOOL       *stop) {
            [links addObjectsFromArray:obj.allLinkChildren];
        }];
    }
    return links;
}

@end
