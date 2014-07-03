//
//  MBAccount.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/26.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBAccount.h"
#import "OAToken.h"
#import "MBRelationshipManager.h"
#import "MBTimeLineManager.h"
#import "MBListManager.h"
#import "MBUserIDManager.h"

@implementation MBAccount

- (id)initWithDictionary:(NSDictionary *)accountData
{
    self = [super init];
    if (self) {
        _screenName = [accountData stringForKey:@"screen_name"];
        _userID = [accountData stringForKey:@"user_id"];
        _accessToken = [[OAToken alloc] initWithKey:[accountData stringForKey:@"oauth_token"] secret:[accountData stringForKey:@"oauth_token_secret"]];
        
        _relationshipManger = [[MBRelationshipManager alloc] init];
        _timelineManager = [[MBTimeLineManager alloc] init];
        _replyTimelineManager = [[MBTimeLineManager alloc] init];
        _listManager = [[MBListManager alloc] init];
        _followerIDManager = [[MBUserIDManager alloc] init];
        [self.followerIDManager setScreenName:self.screenName];
    }
    
    return self;
}


@end
