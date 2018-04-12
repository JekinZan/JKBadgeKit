//
//  JKBadgeController.h
//  JKBageKit
//
//  Created by zhangjie on 2017/3/27.
//  Copyright © 2018年 zhangjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKBadgeView.h"
NS_ASSUME_NONNULL_BEGIN
extern NSString *const JKBadgePathKey;
extern NSString *const JKBadgeCountKey;
extern NSString *const JKBadgeShowKey;
typedef void (^JKBadgeNotificationBlock)(id _Nullable observer, NSDictionary<NSString *, id>*info);

@interface JKBadgeController : NSObject
@property (nonatomic,weak,readonly) id observer;
- (instancetype)initWithObserver:(nullable id)observer NS_DESIGNATED_INITIALIZER;
+ (instancetype)controllerWithObserver:(nullable id)observer;




/**
 @abstract Initializes a new instance.
 @warning  This method is unavaialble. Use 'initWithObserver:' instead.
 */
+ (instancetype)new NS_UNAVAILABLE;

/**
 @abstract Initializes a new instance.
 @warning  This method is unavaialble. Use 'initWithObserver:' instead.
 */
- (instancetype)init NS_UNAVAILABLE;


#pragma mark Observe

/**
 observe the correspondingKeyPath

 @param keyPath keyPath description
 @param block block description
 */
- (void)observePath:(NSString *)keyPath block:(JKBadgeNotificationBlock)block;
- (void)observePath:(NSString *)keyPath badgeView:(nullable id<JKBadgeView>)badgeView block:(nullable JKBadgeNotificationBlock)block;
- (void)observePaths:(NSArray<NSString *> *)keyPaths block:(JKBadgeNotificationBlock)block;

#pragma mark - Unobserve
- (void)unobservePath:(NSString *)keyPath;
- (void)unobserveAll;
#pragma mark Operation
+ (void)setBadgeForKeyPath:(NSString *)keyPath;
+ (void)setBadgeForKeyPath:(NSString *)keyPath count:(NSUInteger)count;
+ (void)clearBadgeForKeyPath:(NSString *)keyPath;
+ (void)clearBadgeForKeyPath:(NSString *)keyPath forced:(BOOL)forced;
+ (BOOL)statusForKeyPath:(NSString *)keyPath;
- (void)refreshBadgeView;
+ (NSUInteger)countForKeyPath:(NSString *)keyPath;
@end
NS_ASSUME_NONNULL_END
