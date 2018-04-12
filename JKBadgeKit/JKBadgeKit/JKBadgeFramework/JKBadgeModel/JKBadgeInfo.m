//
//  JKBageModel.m
//  JKBageKit
//
//  Created by zhangjie on 2017/3/27.
//  Copyright © 2018年 zhangjie. All rights reserved.
//

#import "JKBadgeInfo.h"

@implementation JKBadgeInfo
- (instancetype)initWithController:(JKBadgeController *)controller
                           keyPath:(NSString *)keyPath
                         badgeView:(nullable id<JKBadgeView>)badgeView
                             block:(nullable JKBadgeNotificationBlock)block
                            action:(nullable SEL)action {
    if (self = [super init]) {
        _controller = controller;
        _badgeView  = badgeView;
        _block      = block;
        _keyPath    = keyPath;
    }
    return self;
}
- (instancetype)initWithController:(JKBadgeController *)controller keyPath:(NSString *)keyPath {
    return [self initWithController:controller keyPath:keyPath badgeView:nil block:nil];
}

- (instancetype)initWithController:(JKBadgeController *)controller keyPath:(NSString *)keyPath
                             block:(nullable JKBadgeNotificationBlock)block {
    return [self initWithController:controller keyPath:keyPath badgeView:NULL block:block action:NULL];
}

- (instancetype)initWithController:(JKBadgeController *)controller
                           keyPath:(NSString *)keyPath
                         badgeView:(nullable id<JKBadgeView>)badgeView
                             block:(nullable JKBadgeNotificationBlock)block {
    return [self initWithController:controller keyPath:keyPath badgeView:badgeView block:block action:NULL];
}

- (NSUInteger)hash {
    return _keyPath.hash^_controller.hash;
}

- (BOOL)isEqual:(id)object {
    if (!object)return NO;
    if (self == object)return YES;
    if (![object isKindOfClass:self.class])return NO;
    return [self isEqualToBadgeInfo:(JKBadgeInfo *)object];
}
- (BOOL)isEqualToBadgeInfo:(JKBadgeInfo *)info {
    if ([info.keyPath isEqualToString:self.keyPath]&&(info->_controller == self.controller))return YES;
    return NO;
}
- (NSString *)debugDescription{
    NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p keyPath:%@",
                          NSStringFromClass([self class]), self, _keyPath];
    if (NULL != _block) {
        [s appendFormat:@" block:%p", _block];
    }    
    [s appendString:@">"];
    
    return s;
}
@end
