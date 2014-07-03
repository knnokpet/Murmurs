//
//  MBUserIDManager.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBUser;
@interface MBUserIDManager : NSObject

@property (nonatomic) NSNumber *cursor;
@property (nonatomic, readonly) NSString *screenName;
@property (nonatomic, readonly) NSMutableDictionary *requireLoadingIDs;
@property (nonatomic, readonly) NSMutableDictionary *userIDs;

- (void)setScreenName:(NSString *)screenName;

- (NSArray *)requireLoadingIDs:(NSUInteger)countOfIDs;
- (void)addRequireLoadingIDs:(NSNumber *)userID;
//- (void)storeUserID:(NSNumber *)userID;
- (NSArray *)storedUserIDs;

@end
