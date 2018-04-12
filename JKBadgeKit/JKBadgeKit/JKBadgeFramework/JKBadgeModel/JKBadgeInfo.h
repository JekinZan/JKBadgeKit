//
//  JKBageModel.h
//  JKBageKit
//
//  Created by zhangjie on 2017/3/27.
//  Copyright © 2018年 zhangjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKBadgeController.h"
NS_ASSUME_NONNULL_BEGIN
//Used to distinguish between repeated observe, compare keypath&controller
@interface JKBadgeInfo : NSObject
@property (nonatomic,copy,readonly)NSString *keyPath;
@property (nonatomic,weak,readonly)JKBadgeController *controller;
@property (nonatomic,copy,readonly)JKBadgeNotificationBlock block;
@property (nonatomic,strong,readonly)id<JKBadgeView>badgeView;

- (instancetype)initWithController:(JKBadgeController *)controller keyPath:(NSString *)keyPath;

- (instancetype)initWithController:(JKBadgeController *)controller keyPath:(NSString *)keyPath
                             block:(nullable JKBadgeNotificationBlock)block;

- (instancetype)initWithController:(JKBadgeController *)controller
                           keyPath:(NSString *)keyPath
                         badgeView:(nullable id<JKBadgeView>)badgeView
                             block:(nullable JKBadgeNotificationBlock)block;
@end
NS_ASSUME_NONNULL_END
