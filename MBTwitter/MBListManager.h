//
//  MBListManager.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBList;
@class MBUser;
@interface MBListManager : NSObject

@property (nonatomic, readonly) MBUser *owner;

@property (nonatomic, readonly) NSMutableArray *lists;
@property (nonatomic, readonly) NSMutableArray *ownerShipLists;
@property (nonatomic, readonly) NSMutableArray *subscriptionLists;

- (instancetype)initWithUser:(MBUser *)user;
- (void)setOwner:(MBUser *)owner;

- (void)addLists:(NSArray *)lists;
- (void)removeListOfOwner:(NSInteger)index;
- (void)removeListOfSubscrive:(NSInteger)index;

@end
