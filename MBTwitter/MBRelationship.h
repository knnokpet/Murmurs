//
//  MBRelationship.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/12.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+Objects.h"

@interface MBRelationship : NSObject

@property (nonatomic, readonly) NSNumber *userID;
@property (nonatomic, readonly) NSString *userIDStr;

@property (nonatomic, readonly, assign) BOOL isFollowing;
@property (nonatomic, readonly, assign) BOOL sentFollowRequest;
@property (nonatomic, readonly, assign) BOOL followdByTheUser;
@property (nonatomic, readonly, assign) BOOL none;
@property (nonatomic, readonly, assign) BOOL isBlocking;
@property (nonatomic, readonly, assign) BOOL isMuting;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)setIsFollowing:(BOOL)isFollowing;
- (void)setSentFollowRequest:(BOOL)sentFollowRequest;
- (void)setIsBlocking:(BOOL)isBlocking;
- (void)setIsMuting:(BOOL)isMuting;

@end
