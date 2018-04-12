//
//  JKBadge.h
//  JKBageKit
//
//  Created by zhangjie on 2017/3/27.
//  Copyright © 2018年 zhangjie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JKBadge <NSObject,NSCopying>
//e.g: "badge"
@property (nonatomic,strong,readonly) NSString *name;
//e.g: "root.jk.badge"
@property (nonatomic,strong,readonly) NSString *keyPath;
/**
 1. non-leaf node, sum of children
 2. terminal node: return  'count'
 3. setter valid for terminal node
 */
@property (nonatomic,assign)NSUInteger count; // badge value
/**
 1. non-leaf node: has any children?
 2. terminal node: return 'needShow'
 */
@property (nonatomic,assign) BOOL needShow; // red dot

// immediate children of current badge
@property (strong, nonatomic, readonly) NSMutableArray<id<JKBadge>> *children;
// all linked children, including children's children
@property (strong, nonatomic, readonly) NSMutableArray<id<JKBadge>> *allLinkChildren;

@property (weak, nonatomic) id<JKBadge> parent;

// regist nodes in terms of key path
+ (id<JKBadge>)initWithDictionary:(NSDictionary *)dic;

/**
 convert id <JKBadge> object to dictionary,
 useful for, e.g. Data Persistence / Archive
 */
- (NSDictionary *)dictionaryFormat;

- (void)addChild:(id<JKBadge>)child;     // add leaf
- (void)removeChild:(id<JKBadge>)child;  // cut leaf
- (void)clearAllChildren;                // clearAll
- (void)removeFromParent; // [parent removeChild:self]
@end
