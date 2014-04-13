//
//  MBAccount.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/26.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBAccount.h"
#import "OAToken.h"

@implementation MBAccount

- (id)initWithDictionary:(NSDictionary *)accountData
{
    self = [super init];
    if (self) {
        _screenName = [accountData stringForKey:@"screen_name"];
        _userID = [accountData stringForKey:@"user_id"];
        _accessToken = [[OAToken alloc] initWithKey:[accountData stringForKey:@"oauth_token"] secret:[accountData stringForKey:@"oauth_token_secret"]];
    }
    
    return self;
}

@end
