//
//  MBTweet.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+Objects.h"
#import "NSDate+strptime.h"


#define KEY_TWEET_TEXT @"text"
#define KEY_TWEET_ID @"id"
#define KEY_TWEET_ID_STR @"id_str"
#define KEY_CREATED_AT_TIME @"created_at"
#define KEY_ENTITY @"entities"

@class MBUser;
@class MBEntity;
@class MBPlace;
@interface MBTweet : NSObject <NSCoding>

@property (nonatomic, assign, readonly) BOOL requireLoading;

@property (nonatomic) NSString *tweetText;
@property (nonatomic) NSNumber *tweetID; // 64bit integer = s unsigned long long
@property (nonatomic) NSString *tweetIDStr;
@property (nonatomic, readonly) MBUser *tweetUser;
@property (nonatomic) NSDate *createdDate;
@property (nonatomic) MBEntity *entity;
@property (nonatomic, readonly) MBPlace *place;// NULLable

@property (nonatomic, readonly) NSInteger favoritedCount; // NULLable
@property (nonatomic) NSInteger retweetedCount;

@property (nonatomic, assign, readonly) BOOL isFavorited; // NULLable
@property (nonatomic, assign, readonly) BOOL isRetweeted;
@property (nonatomic, assign, readonly) BOOL isTruncated;
@property (nonatomic, assign, readonly) BOOL isContainedTweetLink;// NULLable

@property (nonatomic, readonly) MBTweet *tweetOfOriginInRetweet;

@property (nonatomic, readonly) NSString *screenNameOfOriginInReply;// NULLable
@property (nonatomic, readonly) NSNumber *tweetIDOfOriginInReply;// NULLable
@property (nonatomic, readonly) NSString *tweetIDStrOfOriginInReply;// NULLable
@property (nonatomic, readonly) NSNumber *userIDOfOriginInReply;// NULLable
@property (nonatomic, readonly) NSString *userIDStrOfOriginInReply;// NULLable

@property (nonatomic, readonly) NSString *language;// NULLable
@property (nonatomic, readonly) NSString *filterLebel;
@property (nonatomic, readonly) NSDictionary *contributors; // NULLable
@property (nonatomic, readonly) NSDictionary *coordinates; // NULLable
@property (nonatomic, readonly) NSDictionary *currentUserRetweetedTweet;
@property (nonatomic, readonly) NSDictionary *scopes;
@property (nonatomic, readonly) NSString *webSource;


@property (nonatomic, assign, readonly) BOOL isWithheldCopyright;
@property (nonatomic, readonly) NSArray *withheldCountries;
@property (nonatomic, readonly) NSString *withheldScope;


- (void)setIsRetweeted:(BOOL)isRetweeted;

- (id)initWithDictionary:(NSDictionary *)tweet;

@end
