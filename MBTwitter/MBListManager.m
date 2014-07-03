//
//  MBListManager.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBListManager.h"

#import "MBTimeLineManager.h"
#import "MBList.h"
#import "MBUser.h"

@interface MBListManager()

@property (nonatomic, readonly) NSMutableDictionary *timelineManagers;

@end

@implementation MBListManager
- (id)init
{
    self = [super init];
    if (self) {
        [self common];
    }
    return self;
}

- (instancetype)initWithUser:(MBUser *)user
{
    self = [super init];
    if (self) {
        [self common];
        _owner = user;
    }
    
    return self;
}

- (void)common
{
    _ownerShipLists = [NSMutableArray array];
    _subscriptionLists = [NSMutableArray array];
    _lists = [NSMutableArray arrayWithObjects:self.ownerShipLists, self.subscriptionLists, nil];
    
    _timelineManagers = [NSMutableDictionary dictionary]; /* 自身のアカウント使用時でしか使われないため、普遍的ではない。 */
}

#pragma mark - Setter & Accesser
- (void)setOwner:(MBUser *)owner
{
    _owner = owner;
}

#pragma mark -InstanceMethods
- (void)addLists:(NSArray *)lists
{
    MBList *addingList = [lists firstObject];
    MBUser *ownerOfList = [addingList user];
    
    if (NSOrderedSame == [self.owner.userID compare:ownerOfList.userID]) {
        [self.ownerShipLists addObjectsFromArray:lists];
    } else {
        [self.subscriptionLists addObjectsFromArray:lists];
    }
}

- (void)removeListOfOwner:(NSInteger)index
{
    [self removeListFrom:self.ownerShipLists atIndex:index];
}

- (void)removeListOfSubscrive:(NSInteger)index
{
    [self removeListFrom:self.subscriptionLists atIndex:index];
}

- (void)removeListFrom:(NSMutableArray *)fromLists atIndex:(NSInteger)index
{
    [fromLists removeObjectAtIndex:index];
}

- (void)removeAllLists
{
    [self.ownerShipLists removeAllObjects];
    [self.subscriptionLists removeAllObjects];
}


#pragma mark - 
/* for Multi Accout */
- (MBTimeLineManager *)timelineManagerForListID:(NSNumber *)listID
{
    MBTimeLineManager *storedManager = [self.timelineManagers objectForKey:listID];
    
    if (!storedManager) {
        storedManager = [[MBTimeLineManager alloc] init];
        [self.timelineManagers setObject:storedManager forKey:listID];
    }
    
    return storedManager;
}

@end
