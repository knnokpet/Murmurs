//
//  MBListManager.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBListManager.h"

@implementation MBListManager
- (id)init
{
    self = [super init];
    if (self) {
        _lists = [NSMutableArray array];
    }
    return self;
}

- (void)addLists:(NSArray *)lists
{
    self.lists = lists.mutableCopy;
}

- (void)removeListAtIndex:(NSInteger)index
{
    [self.lists removeObjectAtIndex:index];
}

@end
