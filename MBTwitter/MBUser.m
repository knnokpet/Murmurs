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
    _screenName = [user objectForKey:@"user_name"];
    _userID = [[user objectForKey:@"id"] integerValue];
    _userIDStr = [user objectForKey:@"id_str"];
    NSString *description = [user objectForKey:@"description"];
    _desctiprion = (description == (id)[NSNull null]) ? nil : description;
    _tweetCount = [[user objectForKey:@"status_count"] integerValue];
    _listedCount = [[user objectForKey:@"listed_count"] integerValue];
    _favoritesCount = [[user objectForKey:@"favorites_count"] integerValue];
    _followersCount = [[user objectForKey:@"followers_count"] integerValue];
    _followsCount = [[user objectForKey:@"following"] integerValue];
    NSString *location = [user objectForKey:@"location"];
    _location = (location == (id)[NSNull null]) ? nil : location;
    _characterName = [user objectForKey:@"name"];
    NSString *createdDateStr = [user objectForKey:@"created_at"];
    _createdDate = [[[NSDateFormatter alloc] init] dateFromString:createdDateStr];
    _entity = [[MBEntity alloc] initWithDictionary:[[user objectForKey:@"entities"] objectForKey:@"url"]];
    // バグる。多分、延々と潜り続けて初期化するから。
    NSDictionary *currentTweetDict = [user objectForKey:@"status"];
    //_currentTweet = (currentTweetDict == (id)[NSNull null]) ? nil : [[MBTweet alloc] initWithDictionary:currentTweetDict];
    NSString *timeZone = [user objectForKey:@"time_zone"];
    _timeZone = (timeZone == (id)[NSNull null]) ? nil : timeZone;
    NSString *language = [user objectForKey:@"lang"];
    _language = (language == (id)[NSNull null]) ? nil : language;
}

@end
