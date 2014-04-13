//
//  MBTweet.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTweet.h"
#import "MBUser.h"
#import "MBEntity.h"
#import "MBPlace.h"

@implementation MBTweet

- (id)initWithDictionary:(NSDictionary *)tweet
{
    self = [super init];
    if (self) {
        [self initializeWithDictionary:tweet];
    }
    
    return self;
}

- (void)initializeWithDictionary:(NSDictionary *)tweet
{
    _tweetText = [tweet stringForKey:@"text"];
    _tweetID = [tweet numberForKey:@"id"];
    _tweetIDStr = [tweet stringForKey:@"id_str"];
    _tweetUser = [[MBUser alloc] initWithDictionary:[tweet dictionaryForKey:@"user"]];
    NSString *dateStr = [tweet stringForKey:@"created_at"];
    _createdDate = [[[NSDateFormatter alloc] init] dateFromString:dateStr];
    _entity = [[MBEntity alloc] initWithDictionary:[tweet dictionaryForKey:@"entities"]];
    
    NSDictionary *placeDict = [tweet dictionaryForKey:@"place"];
    _place = [[MBPlace alloc] initWithDictionary:placeDict];
}

@end
