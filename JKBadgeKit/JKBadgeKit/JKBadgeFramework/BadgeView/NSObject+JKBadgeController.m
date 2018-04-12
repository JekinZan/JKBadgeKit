//
//  NSObject+JKBadgeController.m
//  JKBageKit
//
//  Created by zhangjie on 2018/3/27.
//  Copyright © 2018年 zhangjie. All rights reserved.
//

#import "NSObject+JKBadgeController.h"
#import <objc/runtime.h>
@implementation NSObject (JKBadgeController)
- (JKBadgeController *)badgeController{
    id controller = objc_getAssociatedObject(self, _cmd);
    // lazily create the badgeController
    if (nil == controller) {
        controller           = [JKBadgeController controllerWithObserver:self];
        self.badgeController = controller;
    }
    return controller;
}

- (void)setBadgeController:(JKBadgeController *)badgeController {
    objc_setAssociatedObject(self, _cmd, badgeController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
