//
//  MBListManager.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBListManager.h"
#import "MBList.h"
#import "MBUser.h"

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


@end
