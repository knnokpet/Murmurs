//
//  MBTweet.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBUser;
@class MBEntity;
@class MBPlace;
@interface MBTweet : NSObject

@property (nonatomic, readonly) NSString *tweetText;
@property (nonatomic, readonly) NSInteger tweetID;
@property (nonatomic, readonly) NSString *tweetIDStr;
@property (nonatomic, readonly) MBUser *tweetUser;
@property (nonatomic, readonly) NSDate *createdDate;
@property (nonatomic, readonly) MBEntity *entity;
@property (nonatomic, readonly) MBPlace *place;// NULLable

@property (nonatomic, readonly) NSInteger favoritedCount; // NULLable
@property (nonatomic, readonly) NSInteger retweetedCount;

@property (nonatomic, assign, readonly) BOOL isFavorited; // NULLable
@property (nonatomic, assign, readonly) BOOL isRetweeted;
@property (nonatomic, assign, readonly) BOOL isTruncated;
@property (nonatomic, assign, readonly) BOOL isContainedTweetLink;// NULLable

@property (nonatomic, readonly) MBTweet *tweetOfOriginInRetweet;

@property (nonatomic, readonly) NSString *screenNameOfOriginInReply;// NULLable
@property (nonatomic, readonly) NSInteger tweetIDOfOriginInReply;// NULLable
@property (nonatomic, readonly) NSString *tweetIDStrOfOriginInReply;// NULLable
@property (nonatomic, readonly) NSInteger userIDOfOriginInReply;// NULLable
@property (nonatomic, readonly) NSString *userIDStrOfOriginInReply;// NULLable

@property (nonatomic, readonly) NSString *language;// NULLable
@property (nonatomic, readonly) NSString *filterLebel;
@property (nonatomic, readonly) NSDictionary *contributors; // NULLable
@property (nonatomic, readonly) NSDictionary *coordinates; // NULLable
@property (nonatomic, readonly) NSDictionary *currentRetweetedTweet;
@property (nonatomic, readonly) NSDictionary *scopes;
@property (nonatomic, readonly) NSString *webSource;


@property (nonatomic, assign, readonly) BOOL isWithheldCopyright;
@property (nonatomic, readonly) NSArray *withheldCountries;
@property (nonatomic, readonly) NSString *withheldScope;

- (id)initWithDictionary:(NSDictionary *)tweet;

@end
