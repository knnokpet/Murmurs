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
    _tweetText = [tweet objectForKey:@"text"];
    _tweetID = [[tweet objectForKey:@"id"] integerValue];
    _tweetIDStr = [tweet objectForKey:@"id_str"];
    _tweetUser = [[MBUser alloc] initWithDictionary:[tweet objectForKey:@"user"]];
    NSString *dateStr = [tweet objectForKey:@"created_at"];
    _createdDate = [[[NSDateFormatter alloc] init] dateFromString:dateStr];
    _entity = [[MBEntity alloc] initWithDictionary:[tweet objectForKey:@"entities"]];
    
    NSDictionary *placeDict = [tweet objectForKey:@"place"];
    _place =  (placeDict == (id)[NSNull null]) ? nil : [[MBPlace alloc] initWithDictionary:placeDict];
}

@end
