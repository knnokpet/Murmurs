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
        _screenName = [accountData objectForKey:@"screen_name"];
        _userID = [accountData objectForKey:@"user_id"];
        _accessToken = [[OAToken alloc] initWithKey:[accountData objectForKey:@"oauth_token"] secret:[accountData objectForKey:@"oauth_token_secret"]];
    }
    
    return self;
}

@end
