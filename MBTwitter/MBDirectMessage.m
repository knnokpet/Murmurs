//
//  MBDirectMessage.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDirectMessage.h"
#import "MBUser.h"
#import "MBEntity.h"

@implementation MBDirectMessage

- (id)initWithDictionary:(NSDictionary *)tweet
{
    self = [super init];
    if (self) {
        [self initializeWithDictionary:tweet];
    }
    
    return self;
}

- (void)initializeWithDictionary:(NSDictionary *)message
{
    self.tweetText = [message stringForKey:KEY_TWEET_TEXT];
    self.tweetID = [message numberForKey:KEY_TWEET_ID];
    self.tweetIDStr = [message stringForKey:KEY_TWEET_ID_STR];
    NSString *createDate = [message stringForKey:KEY_CREATED_AT_TIME];
    self.createdDate = [NSDate parseDateUsingStrptime:createDate];    
    self.entity = [[MBEntity alloc] initWithDictionary:[message dictionaryForKey:KEY_ENTITY]];
    _recipient = [[MBUser alloc] initWithDictionary:[message dictionaryForKey:KEY_RECIPIENT]];
    _sender = [[MBUser alloc] initWithDictionary:[message dictionaryForKey:KEY_SENDEER]];
}

@end
