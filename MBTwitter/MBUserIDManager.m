//
//  MBUserIDManager.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUserIDManager.h"
#import "MBUser.h"

@interface MBUserIDManager()


@end
@implementation MBUserIDManager
- (id)init
{
    self = [super init];
    if (self) {
        
        _requireLoadingIDs = [NSMutableDictionary dictionary];
        _userIDs = [NSMutableDictionary dictionary];
        _cursor = [NSNumber numberWithInteger:-1];
    }
    
    return self;
}

- (void)setScreenName:(NSString *)screenName
{
    _screenName = screenName;
}

#pragma mark

#pragma mark
- (NSArray *)requireLoadingIDs:(NSUInteger)countOfIDs
{
    NSMutableArray *userIDs = [NSMutableArray array];
    NSInteger i = 0;
    for (NSNumber *userID in [self.requireLoadingIDs allValues]) {
        if (i < countOfIDs) {
            [userIDs addObject:userID];
            i ++;
        } else {
            break;
        }
    }
    
    return userIDs;
}

- (void)addRequireLoadingIDs:(NSNumber *)userID
{
    if (!userID) {
        return;
    }
    
    [self.requireLoadingIDs setObject:userID forKey:userID];
}

- (NSArray *)storedUserIDs
{
    return [self.userIDs allValues];
}

@end
