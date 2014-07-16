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
@class MBTimeLineManager;
@interface MBListManager : NSObject

@property (nonatomic, readonly) MBUser *owner;

@property (nonatomic, readonly) NSMutableArray *lists;
@property (nonatomic, readonly) NSMutableArray *ownerShipLists;
@property (nonatomic, readonly) NSMutableArray *subscriptionLists;

@property (nonatomic) NSNumber *ownerNextCursor;
@property (nonatomic) NSNumber *subscriveNextCursor;

- (instancetype)initWithUser:(MBUser *)user;
- (void)setOwner:(MBUser *)owner;

- (void)addLists:(NSArray *)lists;
- (void)removeListOfOwner:(NSInteger)index;
- (void)removeListOfSubscrive:(NSInteger)index;
- (void)removeAllLists;

- (MBTimeLineManager *)timelineManagerForListID:(NSNumber *)listID;/* マルチアカウント用 */


@end
