//
//  MBUser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUser.h"
#import "MBTweet.h"
#import "MBEntity.h"

@implementation MBUser
- (id)initWithDictionary:(NSDictionary *)user
{
    self = [super init];
    if (self) {
        [self initializeWithDictionary:user];
    }
    
    return self;
}

- (void)initializeWithDictionary:(NSDictionary *)user
{
    _screenName = [user stringForKey:@"user_name"];
    _userID = [user numberForKey:@"id"];
    _userIDStr = [user stringForKey:@"id_str"];
    _desctiprion = [user stringForKey:@"description"];
    _tweetCount = [user integerForKey:@"status_count"];
    _listedCount = [user integerForKey:@"listed_count"];
    _favoritesCount = [user integerForKey:@"favorites_count"];
    _followersCount = [user integerForKey:@"followers_count"];
    _followsCount = [user integerForKey:@"following"];
    _location = [user stringForKey:@"location"];
    _characterName = [user stringForKey:@"name"];
    NSString *createdDateStr = [user stringForKey:@"created_at"];
    _createdDate = [[[NSDateFormatter alloc] init] dateFromString:createdDateStr];
    _entity = [[MBEntity alloc] initWithDictionary:[[user dictionaryForKey:@"entities"] dictionaryForKey:@"url"]];
    // バグる。多分、延々と潜り続けて初期化するから。
    NSDictionary *currentTweetDict = [user dictionaryForKey:@"status"];
    //_currentTweet = (currentTweetDict == (id)[NSNull null]) ? nil : [[MBTweet alloc] initWithDictionary:currentTweetDict];
    _timeZone = [user stringForKey:@"time_zone"];
    _language = [user stringForKey:@"lang"];
    
    _isDefaultProfileImage = [user boolForKey:@"default_profile_image"];
    
    _urlHTTPSAtProfileImage = [user stringForKey:@"profile_image_url_https"];
}

@end
