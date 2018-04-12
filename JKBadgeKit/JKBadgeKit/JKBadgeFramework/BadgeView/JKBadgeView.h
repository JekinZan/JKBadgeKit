//
//  JKBadgeView.h
//  JKBageKit
//
//  Created by zhangjie on 2017/3/27.
//  Copyright © 2018年 zhangjie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JKBadgeView <NSObject>
@required
@property (nonatomic, strong) UILabel *badge;
@property (nonatomic, strong) UIFont  *badgeFont;      // default bold size 9
@property (nonatomic, strong) UIColor *badgeTextColor; // default white color
@property (nonatomic, assign) CGFloat badgeRadius;
@property (nonatomic, assign) CGPoint badgeOffset;     // offset from right-top

- (void)showBadge; // badge with red dot
- (void)hideBadge;

// badge with number, pass zero to hide badge
- (void)showBadgeWithValue:(NSUInteger)value;

@optional
@property (nonatomic, strong) UIView  *customView;
/**
 convenient interface:
 create 'cusomView' (UIImageView) using badgeImage
 view's size would simply be set as half of image.
 */
@property (nonatomic, strong) UIImage *badgeImage;
@end
