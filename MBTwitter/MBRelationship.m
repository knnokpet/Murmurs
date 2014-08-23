//
//  MBRelationship.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/12.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBRelationship.h"

#define KEY_FOLLOWING               @"following"
#define KEY_FOLLOWING_REQUESTED     @"following_requested"
#define KEY_FOLLOWD_BY              @"followed_by"
#define KEY_NONE                    @"none"
#define KEY_BLOCKING                @"blocking"
#define KEY_MUTING                  @"muting"

@implementation MBRelationship

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        
        _userID = [dictionary numberForKey:@"id"];
        _userIDStr = [dictionary stringForKey:@"id_str"];
        NSArray *connections = [dictionary arrayForKey:@"connections"];
        [self initializeWithArray:connections];
    }
    
    return self;
}

- (void)initializeWithArray:(NSArray *)connections
{
    _isFollowing = NO;
    _sentFollowRequest = NO;
    _followdByTheUser = NO;
    _none = NO;
    _isBlocking = NO;
    _isMuting = NO;
    
    for (NSString *value in connections) {
        if ([value isEqualToString:KEY_FOLLOWING]) {
            _isFollowing = YES;
        } else if ([value isEqualToString:KEY_FOLLOWING_REQUESTED]) {
            _sentFollowRequest = YES;
        } else if ([value isEqualToString:KEY_FOLLOWD_BY]) {
            _followdByTheUser = YES;
        } else if ([value isEqualToString:KEY_NONE]) {
            _none = YES;
        } else if ([value isEqualToString:KEY_BLOCKING]) {
            _isBlocking = NO;
        } else if ([value isEqualToString:KEY_MUTING]) {
            _isMuting = YES;
        }
    }
}

#pragma mark -
#pragma mark Setter 
- (void)setIsFollowing:(BOOL)isFollowing
{
    _isFollowing = isFollowing;
}

- (void)setSentFollowRequest:(BOOL)sentFollowRequest
{
    _sentFollowRequest = sentFollowRequest;
}

- (void)setIsBlocking:(BOOL)isBlocking
{
    _isBlocking = isBlocking;
}

- (void)setIsMuting:(BOOL)isMuting
{
    _isMuting = isMuting;
}

@end
